module Models::MapHstore

  def convert_hstore_to(to_type, *methods)
    methods.each do |meth|
      alias_method :"old_#{meth}", meth
      define_method meth do
        send(:"old_#{meth}").try(to_type)
      end
    end
  end

  def convert_hstore_to_decimal(*methods)
    convert_hstore_to(:to_d, *methods)
  end

  def convert_hstore_to_time(*methods)
    convert_hstore_to(:to_time, *methods)
  end

  def convert_hstore_to_time(*methods)
    convert_hstore_to(:to_date, *methods)
  end

  def convert_hstore_to_integer(*methods)
    convert_hstore_to(:to_i, *methods)
  end

  def convert_hstore_to_boolean(*methods)
    methods.each do |meth|
      define_method :"#{meth}" do
        if %w{true false}.include? send(meth)
          send(meth) == "true" ? true : false
        else
          send(meth)
        end
      end

      define_method :"#{meth}?" do
        !!send(meth)
      end
    end
  end
end
