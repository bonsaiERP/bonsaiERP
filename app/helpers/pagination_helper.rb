module PaginationHelper
  def page_disabled_css(val)
    val ? 'disabled' : ''
  end

  def page_current_css(val)
    val ? 'active' : ''
  end
end
