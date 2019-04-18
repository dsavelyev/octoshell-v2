module Quotas
  module Semantics
    # Common methods for semantics classes

    def quotas_where(h)
      case h[:scope]
      when :specific
        quotas_with_specific_scope
      when :default
        quotas_with_default_scope
      end
    end
  end
end
