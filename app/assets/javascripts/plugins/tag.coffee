Tag = {
  getTagsById: (tag_ids) ->
    tags = _(tag_ids).map( (id) ->
      tag = bonsai.tags_hash[id.toString()]
      tag.color = _b.idealTextColor(tag.bgcolor)  if tag and tag.bgcolor?
      tag
    ).compact().value()
 updateTags: ->
}


@Plugin.Tag

Plugin.Tag = Tag
