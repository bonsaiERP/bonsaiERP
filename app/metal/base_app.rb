# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BaseApp < ActionController::Metal

  protected
  def set_search_path
    PgTools.set_search_path PgTools.get_schema_name(session[:organisation][:id])
  end
end
