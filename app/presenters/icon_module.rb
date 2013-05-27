module IconModule
  def icon(ico, title = '')
    if title.present?
      "<i class=\"#{ico}\" title=\"#{ title }\" data-toggle=\"tooltip\"></i>"
    else
      "<i class=\"#{ico}\"></i>"
    end
  end
  module_function :icon
end
