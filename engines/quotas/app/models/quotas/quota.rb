# Note that quotas are intended to be looked up by subject, kind, and domain,
# not id, because a quota with nil {current,desired}_value that isn't being
# synced is represented by not having a record in the DB at all. id and
# lock_version essentially act as a "major.minor" version value.

module Quotas
  class Quota < ActiveRecord::Base
    belongs_to :subject, polymorphic: true
    belongs_to :kind, class_name: 'ClusterQuotaKind', inverse_of: :quotas
    belongs_to :domain, polymorphic: true

    validates :kind, :domain, presence: true
    validates :syncing, inclusion: { in: [false, true] }

    validate on: :create do |quota|
      next unless quota.consistent?

      if quota.class.exists? subject: subject, kind: kind, domain: domain
        errors[:base] << I18n.t('quotas.quota.already_exists')
      end

      if quota.potential?
        errors[:desired_value] << I18n.t('quotas.quota.both_values_nil')
      end
    end

    validate do |quota|
      next unless quota.consistent?

      dom_id = quota.domain_id
      cluster_id =
        case quota.domain_type
        when 'Core::Cluster'
          dom_id
        when 'Core::Partition'
          quota.domain.cluster_id
        end

      if kind.cluster_id != cluster_id
        errors[:kind] << I18n.t('quotas.quota.invalid_for_cluster')
      end

      if kind.applies_to_partitions != (quota.domain_type == 'Core::Partition')
        errors[:kind] << I18n.t('quotas.quota.invalid_for_domain_type')
      end
    end

    before_save do
      # Rails uses subject_id and subject_type for determining the subject, but
      # those can be NULL, making them unsuitable for DB-level uniqueness checking. So
      # instead, additional "_uniq" columns are used in the unique index and set here.
      self._uniq_subject_id = subject_id || 0
      self._uniq_subject_type = subject_type || ''

      nil
    end

    # XXX: these do unnecessary joins
    ransack_alias :project_id, 'subject_of_Core::Project_type_id_or_subject_of_Core::Member_type_project_id'
    ransack_alias :direct_project_id, 'subject_of_Core::Project_type_id'
    ransack_alias :member_id, 'subject_of_Core::Member_type_id'
    ransack_alias :user_id, 'subject_of_Core::Member_type_user_id'

    ransack_alias :cluster_id, 'domain_of_Core::Cluster_type_id_or_domain_of_Core::Partition_type_cluster_id'
    ransack_alias :direct_cluster_id, 'domain_of_Core::Cluster_type_id'
    ransack_alias :partition_id, 'domain_of_Core::Partition_type_id'

    def project
      case subject
      when Core::Project
        subject
      when Core::Member
        subject.project
      end
    end

    ENTITY_ID_ATTRS = %i[subject_id subject_type kind_id domain_id domain_type].freeze

    def entity_ids
      ENTITY_ID_ATTRS
        .map { |v| [v, send(v)] }
        .to_h
    end

    def consistent?
      (!subject_id || subject) && kind && domain && [false, true].include?(syncing)
    end

    def potential?
      !current_value && !desired_value && !syncing
    end

    def persist!
      if potential?
        destroy! if persisted?
      elsif new_record? || changed?
        save!
      end

      self
    end

    # Will raise an exception on conflict
    def synchronize!
      self.syncing = true
      persist!

      QuotaSynchronizer.perform_async([entity_ids])
    end

    def self.synchronize!(which)
      all_entity_ids = which.map do |params|
        with_quota_by(params) do |q|
          q.syncing = true

          q.entity_ids
        end
      end

      QuotaSynchronizer.perform_async(all_entity_ids)
    end

    def verify!
      QuotaVerifier.perform_async([entity_ids])
    end

    def self.verify!(which)
      all_entity_ids = which.map do |params|
        with_quota_by(params, &:entity_ids)
      end

      QuotaVerifier.perform_async(all_entity_ids)
    end

    # A "transactional" wrapper around operations with quotas, will
    # insert/update/delete as appropriate. Returns the value returned by the
    # block
    def self.with_quota_by(params)
      Retry.with_retries on: [ActiveRecord::RecordNotUnique, ActiveRecord::StaleObjectError] do
        q = find_or_initialize_by(params)
        ret = yield q

        q.persist!

        ret
      end
    end
  end
end
