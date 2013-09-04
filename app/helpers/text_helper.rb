module TextHelper
  {red: 'red',
   green: 'bonsai-dark',
   green_dark: 'bonsai-darker',
   blue: 'blue',
   black: 'black',
   dark: 'dark',
   gray: 'gray'
  }.each do |meth, col|
    define_method :"text_#{meth}" do |txt, title = ''|
      title = "title='#{title}' data-toggle='tooltip'"
      "<span class='#{col}' #{title}>#{txt}</span>".html_safe
    end
  end
end
