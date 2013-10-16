module SettersGetters
  def create_setters(*attrs)
    attrs.map { |k| :"#{k}=" }
  end

  def create_accessors(*attrs)
    attrs.map(&:to_sym) + create_setters(*attrs)
  end
end
