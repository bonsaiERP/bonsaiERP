module TextHelper
  {red: 'red', green: 'bonsai-dark', blue: 'blue', black: 'black'}.each do |meth, col|
    define_method :"text_#{meth}" do |txt|
      "<span class='#{col}'>#{txt}</span>".html_safe
    end
  end
end
