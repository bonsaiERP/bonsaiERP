class AutocompleteInput < SimpleForm::Inputs::Base
  include ActionView::Helpers::FormTagHelper
  enable :placeholder

  # User the input_options[:value_field for the value of the relation Model
  def input
    value_field = input_options[:value_field] || :to_s

    if object.respond_to? :reflections
      hid_name = object.reflections[attribute_name].options[:foreign_key]
      relation = attribute_name
    else
      hid_name = attribute_name
      relation = attribute_name.to_s.gsub(/\A(.+)(_id)\z/,'\1')
    end

    input_html_options['data-source'] ||= options['data-source']

    raise 'input_html_options data-source required' unless input_html_options['data-source'].present?

    value = object.send(relation)
    input_html_options[:placeholder] = input_html_options[:placeholder] || I18n.t('bonsai.autocomplete_placeholder')
    input_html_options[:size] ||= SimpleForm.default_input_size

    out = @builder.hidden_field hid_name
    out << text_field_tag("#{attribute_name}_autocomplete", value, input_html_options)

    out.html_safe
  end
end
