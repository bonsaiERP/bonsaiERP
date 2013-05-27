module LabelModule

  {
    black: 'label-inverse',
    blue: 'label-info',
    green: 'label-success',
    red: 'label-important',
    yellow: 'label-warning'
  }.each do |met, lbl|
    define_method :"label_#{met}" do |text, title = ''|
      label text, lbl, title
    end

    module_function :"label_#{met}"
  end

  def label(text, css_class = '', title = '')
    txt = " title='#{ title }' data-tooggle='tooltip'" if title.present?
    "<span class='label #{css_class}' #{txt}>#{ text }<span>".html_safe
  end
  module_function :label
end
