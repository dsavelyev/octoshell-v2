ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.plural    /(quota)$/,  '\1s'
  inflect.singular  /(quota)s$/, '\1'
end
