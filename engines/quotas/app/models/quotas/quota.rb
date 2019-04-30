module Quotas
  class Quota < ActiveRecord::Base
    belongs_to :subject, polymorphic: true
    belongs_to :kind, class_name: "ClusterQuotaKind", inverse_of: :quotas
    belongs_to :domain, polymorphic: true

    validates :kind, :domain, :state, presence: true

    validate on: :create do |quota|
      if quota.class.exists? subject: subject, kind: kind, domain: domain
        errors[:base] << t('quotas.quota.already_exists')
      end
    end

    validate do |quota|
      dom_id = quota.domain_id
      cluster_id =
        case quota.domain_type
        when 'Core::Cluster'
          dom_id
        when 'Core::Partition'
          quota.domain.cluster_id
        end

      if kind.cluster_id != cluster_id
        errors[:kind] << t('quotas.quota.invalid_for_cluster')
      end

      if kind.applies_to_partitions != (quota.domain_type == 'Core::Partition')
        errors[:kind] << t('quotas.quota.invalid_for_domain_type')
      end
    end

    attr_readonly :_uniq_subject_id, :_uniq_subject_type
    attr_readonly :subject_id, :subject_type
    attr_readonly :kind_id
    attr_readonly :domain_id, :domain_type

    before_save do
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
  end
end
