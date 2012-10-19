# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BaseApp < ActionController::Metal
  private
    def set_search_path
      PgTools.change_schema request.subdomain if request.subdomain.present?
    end
end
