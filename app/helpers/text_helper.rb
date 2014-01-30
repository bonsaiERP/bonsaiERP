module TextHelper
  {red: 'red',
   green: 'bonsai-dark',
   green_dark: 'bonsai-darker',
   blue: 'blue',
   black: 'black',
   dark: 'dark',
   gray: 'gray',
   gray_light: 'gray-light'
  }.each do |meth, color|
    define_method :"text_#{meth}" do |txt, title = '', css=''|
      css << " #{color}"
      title = "title='#{title}' data-toggle='tooltip'"  if title.present?
      "<span class='#{css}' #{title}>#{txt}</span>".html_safe
    end
  end
end
