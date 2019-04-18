module Quotas
  class OverrideSemantics
    include Semantics

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def self.data_from_hash(h)
      OverrideSemanticsData.new(h)
    end

    def effective_current_value(subject, kind, domain)
      each_potential_quota(subject, kind, domain) do |q|
        val = q.current_value
        break [q, val] if val
      end
    end

    def active?(quota, subject)
      each_potential_quota(subject, quota.kind, quota.domain) do |q|
        val = q.current_value
        break quota == q if val
      end || false
    end

    def quotas_with_specific_scope
      Quota.where(subject_type: 'Core::Member')
    end

    def quotas_with_default_scope
      Quota.where.not(subject_type: 'Core::Member')
    end

    private

    def each_potential_quota(subject, kind, domain)
      return unless subject.is_a? Core::Member

      subjects = prio_to_subject(subject)

      @data.priority.detect do |prio|
        eff_subj = subjects[prio]

        q = Quota.find_by(subject: eff_subj, kind: kind, domain: domain)
        yield q if q
      end

      nil
    end

    def prio_to_subject(subject)
      {
        global: nil,
        project: subject.project,
        member: subject
      }
    end
  end
end
