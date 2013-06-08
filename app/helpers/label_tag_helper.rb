module LabelTagHelper
  {
    black: 'label-inverse',
    blue: 'label-info',
    green: 'label-success',
    red: 'label-important',
    yellow: 'label-warning',
    gray: ''
  }.each do |met, lbl|
    define_method :"label_#{met}" do |text, title = ''|
      LabelTagModule.label_tag text, lbl, title
    end
  end
end
