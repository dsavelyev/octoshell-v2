module Quotas
  class Quota < ActiveRecord::Base
    belongs_to :subject, polymorphic: true
    belongs_to :kind, class_name: ClusterQuotaKind
    belongs_to :object, polymorphic: true

    validates :kind, :object, :state, presence: true

    validate on: :create do |quota|
      if quota.class.exists? subject: subject, kind: kind, object: object
        errors[:base] << 'A quota already exists for this subject-kind-object combination'
      end
    end

    before_save do
      self.has_subject = !subject.nil?
      nil  # don't return false and crash the operation
    end

    def self.join_on_projects
      joins <<-SQL.squish
        LEFT OUTER JOIN core_projects
        ON quotas_quotas.subject_type = 'Core::Project' AND quotas_quotas.subject_id = core_projects.id
      SQL
    end

    def self.join_on_members
      joins <<-SQL.squish
        LEFT OUTER JOIN core_members
        ON quotas_quotas.subject_type = 'Core::Member' AND quotas_quotas.subject_id = core_members.id
      SQL
    end

    def self.join_on_subjects
      join_on_members.joins <<-SQL.squish
        LEFT OUTER JOIN core_projects
        ON quotas_quotas.subject_type = 'Core::Project' AND quotas_quotas.subject_id = core_projects.id
           OR core_members.project_id = core_projects.id
      SQL
    end
  end
end
