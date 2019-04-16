module Quotas
  class CumulativeSemantics
    attr_reader :data

    def initialize(_data)
      @data = nil
    end

    def effective_current_value(subject, kind, object)
      q = Quotas.find_by(subject: subject, kind: kind, object: object)
      val = q&.current_value
      val && [q, val]
    end

    def active?(quota, subject)
      quota.subject == subject
    end
  end
end
