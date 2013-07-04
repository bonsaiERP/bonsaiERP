# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BasePresenter < Resubject::Presenter
  include UserLogHelper
  include LabelTagHelper
  include IconsHelper
end
