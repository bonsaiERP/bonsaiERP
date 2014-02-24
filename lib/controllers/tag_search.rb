# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Controllers::TagSearch

  def self.included(base)
    base.helper_method :tag_ids
  end

  private

    def tag_ids
      @tag_ids ||= begin
                     return false  if params[:tag_ids].blank?

                     Array(params[:tag_ids]).map(&:to_i)
                   end
    end

    def has_tags?
      search_tag_params.any?
    end

    def set_search
      if params[:search].present? && params[:search] =~ /;/
        search_tag_params
      end
    end

    def search_tag_params
      @search_tag_params ||= begin
        resp = Tag.select('id,name').where(name: search_arr).to_a
        if search_arr.size === resp.size
          params[:search] = ""
        elsif resp.size > 0
          params[:search] = search_arr.last.strip
        end
        resp
      end
    end

    def search_arr
      @search_arr ||= params[:search].split(';')
    end

end
