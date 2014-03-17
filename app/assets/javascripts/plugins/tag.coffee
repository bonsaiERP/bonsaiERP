Tag = {
  getTagsById: (tag_ids) ->
    tags = _(tag_ids).map( (id) ->
      tag = bonsai.tags_hash[id.toString()]
      tag.color = Tag.textColor(tag.bgcolor)  if tag and tag.bgcolor?
      tag
    ).compact().value()
  textColor: (color) ->
    try
      Plugins.Color.idealTextColor color
    catch e
      '#ffffff'
  getHtml: (tag) ->
    """<span class="tag tag#{tag.id}" style="background: #{tag.bgcolor}; color: #{@textColor(tag.bgcolor)}">
        #{tag.name}
    </span>"""
}

@Plugins.Tag = Tag
