# encoding: utf-8
module IconsHelper
  ICONS = {new: 'plus-sign', edit: 'pencil', list: 'table', show: 'eye-open', delete: 'trash' }

  ICONS.each do |tit, icon|
    define_method :"icon_#{tit}" do |title=nil|
      title ||= I18n.t("common.#{tit}")
      t = " title='#{title}' rel='tooltip'"

      "<i class='icon-#{icon} icon-large'#{t}></i>".html_safe
    end

    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def icon_#{tit}_text
        "<i class='icon-#{icon}'></i> #{I18n.t("common.#{tit}")}".html_safe  
      end
    CODE
  end

  def icon(icon_css)
    content_tag(:i, "", class: icon_css)
  end

end
