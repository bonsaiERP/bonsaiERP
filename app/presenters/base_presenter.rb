# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BasePresenter < Resubject::Presenter
  delegate( *(
   LabelTagHelper.instance_methods +
   IconsHelper.instance_methods +
   TextHelper.instance_methods +
   ActionView::Helpers::SanitizeHelper.instance_methods
  ), to: :template)

  #includes
  include UserLogHelper
end
