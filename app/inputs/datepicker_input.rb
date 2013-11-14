class DatepickerInput < SimpleForm::Inputs::Base
  include ActionView::Helpers::FormTagHelper

  # User the input_options[:value_field for the value of the relation Model
  def input
    input_html_options[:size] ||= 10

    out = @builder.hidden_field attribute_name, input_html_options
    out << text_field_tag("#{attribute_name}_datepicker", nil, input_html_options)

    out.html_safe
  end
end
