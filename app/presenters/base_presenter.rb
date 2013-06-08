# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BasePresenter < Resubject::Presenter
  include UserLogHelper
  include LabelTagModule
  include IconsHelper

end
