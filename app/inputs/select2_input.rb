class Select2Input < SimpleForm::Inputs::Base
  include ActionView::Helpers::FormTagHelper
  #enable :placeholder

  # User the input_options[:value_field for the value of the relation Model
  def input
    if object.respond_to? :reflections
      hid_name = object.reflections[attribute_name].foreign_key || :"#{attribute_name}_id"
      relation = attribute_name
    else
      hid_name = attribute_name
      relation = attribute_name.to_s.gsub(/\A(.+)(_id)\z/,'\1')
    end

    case
    when options['data-source'].present?
      input_html_options['data-source'] = options.delete('data-source')
    when input_html_options[:data].present? && input_html_options[:data][:source].present?
      input_html_options['data-source'] = input_html_options[:data].delete(:source)
    end

    raise 'input_html_options data-source required' unless input_html_options['data-source'].present?
    input_html_options[:placeholder] = input_html_options[:placeholder] || I18n.t('bonsai.autocomplete_placeholder')
    input_html_options[:size] ||= SimpleForm.default_input_size
    input_html_options['data-value'] = object.send(relation).to_s
    input_html_options[:class] = 'select2-autocomplete'

    @builder.text_field hid_name, input_html_options
  end
end

