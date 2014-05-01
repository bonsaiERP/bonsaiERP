class ItemPresenter < BasePresenter
  def unit_tag
    "(<span title='#{unit_name}' data-toggle='tooltip'>#{sanitize unit_symbol }</span>)".html_safe
  end

  def code_tag
    to_model.code  if to_model.code.present?
  end
end
