module Quotas
  class CumulativeSemantics
    include Semantics

    def initialize(_data)
    end

    def self.data_from_hash(_h)
      nil
    end

    def data
      nil
    end

    def effective_current_value(subject, kind, domain)
      q = Quotas.find_by(subject: subject, kind: kind, domain: domain)
      val = q&.current_value
      val && [q, val]
    end

    def active?(quota, subject)
      quota.subject == subject
    end

    def quotas_with_specific_scope
      Quota.all
    end

    def quotas_with_default_scope
      Quota.none
    end
  end
end
