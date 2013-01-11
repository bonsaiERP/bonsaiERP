# encoding: utf-8
module IconsHelper
  #ICONS = {add: 'new', delete: 'delete', pencil: 'edit', table: 'list', zoom: 'Show'}
  ICONS = {new: 'plus-sign', edit: 'pencil', list: 'table', show: 'zoom', delete: 'trash' }

  ICONS.each do |tit, icon|
    define_method :"icon_#{tit}" do |title=nil|
      title ||= I18n.t("common.#{tit}")
      t = " title='#{title}' rel='tooltip'"

      "<i class='bicon-#{icon}'#{t}></i>".html_safe
    end

    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def icon_#{tit}_text
        "<i class='bicon-#{icon}'></i> #{I18n.t("common.#{tit}")}".html_safe  
      end
    CODE
  end

  def icon(icon_css)
    content_tag(:i, "", class: icon_css)
  end

  #ICON_ALIAS.each do |orig, al|
  #  class_eval <<-CODE, __FILE__, __LINE__ + 1
  #    alias :"icon_#{al}" :"icon_#{orig}"
  #    alias :"icon_#{al}_text" :"icon_#{orig}_text"
  #  CODE
  #end

end
