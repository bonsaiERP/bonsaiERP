# encoding: utf-8
module LabelTagModule
  {
    black: 'label-inverse',
    blue: 'label-info',
    green: 'label-success',
    red: 'label-important',
    yellow: 'label-warning'
  }.each do |met, lbl|
    define_method :"label_#{met}" do |text, title = ''|
      label_tag text, lbl, title
    end
    #module_function :"label_#{met}"
  end

  def label_tag(text, css_class = '', title = '')
    txt = " title='#{ title }' data-toggle='tooltip'" if title.present?
    "<span class='label #{css_class}' #{txt}>#{ text }</span>".html_safe
  end
  module_function :label_tag
end
