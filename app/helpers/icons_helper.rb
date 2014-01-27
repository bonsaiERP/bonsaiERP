# encoding: utf-8
module IconsHelper
  ICONS = {new: 'plus-circle', edit: 'pencil', list: 'table', show: 'eye', delete: 'trash' }

  ICONS.each do |tit, icon|
    define_method :"icon_#{tit}" do |title = nil|
      title ||= I18n.t("common.#{tit}")
      t = " title='#{title}' data-toggle='tooltip'"

      "<i class='icon-#{icon} icon-large'#{t}></i>".html_safe
    end

    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def icon_#{tit}_text
        "<i class='icon-#{icon}'></i> #{I18n.t("common.#{tit}")}".html_safe
      end
    CODE
  end

  def icon(ico, title = '')
    if title.present?
      "<i class=\"#{ico}\" title=\"#{ title }\" data-toggle=\"tooltip\"></i>".html_safe
    else
      "<i class=\"#{ico}\"></i>".html_safe
    end
  end

end
