# encoding: utf-8
module LabelTagHelper
  {
    black: 'label-inverse',
    blue: 'label-info',
    green: 'bg-bonsai-dark',
    red: 'label-important',
    yellow: 'label-warning',
    gray: ''
  }.each do |met, lbl|
    define_method :"label_#{met}" do |text, title = ''|
      tag_labeler text, lbl, title
    end
  end

  def tag_labeler(text, css_class = '', title = '')
    txt = " title='#{ title }' data-toggle='tooltip'" if title.present?
    "<span class='label #{css_class}' #{txt}>#{ text }</span>".html_safe
  end
end
