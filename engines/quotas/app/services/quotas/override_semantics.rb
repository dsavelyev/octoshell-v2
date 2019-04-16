module Quotas
  class OverrideSemantics
    attr_reader :data

    def self.data_class
      OverrideSemanticsData
    end

    def initialize(data)
      @data = data
    end

    def effective_current_value(subject, kind, object)
      each_potential_quota(subject, kind, object) do |q|
        val = q.current_value
        break val if val
      end
    end

    def active?(quota, subject)
      each_potential_quota(subject, quota.kind, quota.object) do |q|
        break quota == q if q.current_value
      end || false
    end

    private

    def each_potential_quota(subject, kind, object)
      return unless subject.is_a? Core::Member

      subjects = prio_to_subject(subject)

      @data.priority.detect do |prio|
        eff_subj = subjects[prio]

        q = Quota.find_by(subject: eff_subj, kind: kind, object: object)
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
