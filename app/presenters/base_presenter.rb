# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BasePresenter < Resubject::Presenter
  delegate( *(
   LabelTagHelper.instance_methods +
   IconsHelper.instance_methods +
   TextHelper.instance_methods +
   ActionView::Helpers::SanitizeHelper.instance_methods +
   [:link_to, :ntc, :text_red, :text_green, :text_dark, :content_tag, :l]
  ), to: :template)

  #includes
  include UserLogModule

  def today
    @today ||= Date.today
  end

  def code(txt)
    "<code class='gray'>#{txt}</code>"
  end

end
