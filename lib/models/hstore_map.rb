module Models::HstoreMap

  def convert_hstore_to(to_type, *methods)
    methods.each do |meth|
      alias_method :"old_#{meth}", meth
      define_method meth do
        send(:"old_#{meth}").try(to_type)
      end
    end
  end

  def convert_hstore_to_decimal(*methods)
    hstore_attributes[:decimal] = methods
    convert_hstore_to(:to_d, *methods)
  end

  def convert_hstore_to_time(*methods)
    hstore_attributes[:time] = methods
    convert_hstore_to(:to_time, *methods)
  end

  def hstore_attributes
    @hstore_attributes ||= {}
  end

  def convert_hstore_to_timezone(*methods)
    hstore_attributes[:timezone] = methods
    methods.each do |meth|
      alias_method :"old_#{meth}", meth
      class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{meth}
          return old_#{meth}  if old_#{meth}.is_a?(Time)
          Time.zone.parse(old_#{meth})
        rescue
          nil
        end
      CODE
    end
  end

  def convert_hstore_to_date(*methods)
    hstore_attributes[:date] = methods
    convert_hstore_to(:to_date, *methods)
  end

  def convert_hstore_to_integer(*methods)
    hstore_attributes[:integer] = methods
    convert_hstore_to(:to_i, *methods)
  end

  def convert_hstore_to_boolean(*methods)
    hstore_attributes[:boolean] = methods
    methods.each do |meth|
      alias_method :"old_#{meth}", meth
      define_method :"#{meth}" do
        if %w(true false).include? send(:"old_#{meth}")
          send(:"old_#{meth}") == "true" ? true : false
       elsif %w(0 1).include? send(:"old_#{meth}")
          send(:"old_#{meth}") == "1" ? true : false
        else
          send(:"old_#{meth}")
        end
      end

      define_method :"#{meth}?" do
        !!send(meth)
      end
    end
  end
end
