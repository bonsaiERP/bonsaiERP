# Create new and administrate
class TagEditor
  sel: '#btag-editor'
  constructor: ->
    @$name = $(@sel).find('#btag-name-input')
    @$bgcolor = $(@sel).find('#btag-bgcolor-input')
    @$button = $(@sel).find('button')
    $(@sel).dialog({autoOpen: false, width: 400})
    # Set minicolor
    $('#btag-bgcolor-input').minicolors({defaultValue: '#FF0000'})
    @setEvents()
  #
  setEvents: ->
    self = this
    $(@sel).on('click', '.color', ->
      col = Plugin.Color.rgbToHex($(this).css('background-color'))
      self.$bgcolor.val(col).trigger('keyup')
    )

    $(@sel).on 'click', 'button', => @createTag()

    $('#new-tag-link').on('click', =>
      @$name.val('')
      $(@sel).dialog('open')
    )
  #
  createTag: ->
    @clearErrors()
    $.post('/tags', @data(), (resp) =>
      @setAjaxResponse(resp)
    )
  data: ->
    {tag: {name: @$name.val(), bgcolor: @$bgcolor.val()}}
  #
  setAjaxResponse: (resp) ->
    if resp.id
      $(@sel).dialog('close')
      $('#tags').trigger('btags:newtag', resp)
    else if resp.errors
      @setErrors(resp)
  #
  setErrors: (resp) ->
    errors = resp.errors
    @setError('.name', errors.name)  if errors.name
    @setError('.bgcolor', errors.bgcolor)  if errors.bgcolor
  #
  setError: (sel, errors) ->
    $(@sel).find(sel).addClass('error')
    .append('<span class="error">' + errors.join(', ') + '</span>')
  #
  clearErrors: ->
    $(@sel).find('.name').removeClass('error').find('span.error').remove()
    $(@sel).find('.bgcolor').removeClass('error').find('span.error').remove()

# TagSelector to edit model tags
class TagSelector
  sel: '#btag-selector'
  constructor: (@options) ->
    @input = '#tags'

    throw 'You must set a model in options in TagSelector class'  unless @options.model?
    @model = @options.model
    throw 'You must set a data in options in TagSelector class'  unless @options.data?
    @data = @options.data
    throw 'You must set a list in options in TagSelector class'  unless @options.list?
    @list = @options.list

    @tag = @options.tag

    @$button = $(@sel).find('button')
    @setSelect2()
    @setEvents()
  #
  setSelect2: ->
    $('#tags').select2({
      data: @data,
      multiple: true,
      formatResult: TagFormater.formatResult,
      formatSelection: TagFormater.formatSelect,
      containerCssClass: 'btags',
      dropdownCssClass: 'btags',
      escapeMarkup: (t) -> t
    })
  #
  setEvents: ->
    $('.btags').on('click', 'a.remove-tag', ->
      $(this).parents('.select2-search-choice').find('a.select2-search-choice-close').trigger('click')
    )

    $(@list).on('change', 'input.row-check', =>
      console.log 'Data'
    )

    @$button.on 'click', @applyTags

    $('#tags').on 'btags:newtag', (event, tag) => @updateSelect2(tag)
  #
  updateSelect2: (tag) ->
    tag.text = tag.name
    @data.push tag
    $('#tags').select2('destroy')
    @setSelect2()
    vals = $('#tags').select2('val')
    vals.push(tag.id)
    $('#tags').select2('val', vals)
  #
  applyTags: =>
    $rows = $(@list).find('input.row-check:checked')
    if $rows.length > 0
      @updateTags(_.map($rows, (el) -> el.id ))
    else
      alert 'Debe seleccionar ítems para aplicar las etiquetas'
  #
  updateTags: (ids) ->
    data = @ajaxData(ids)
    $.post('/tags/update_models', data, (resp) =>
      if resp.success
        @updateTagView(ids, data.tag_ids)
      else
        alert 'Existio un error al actualizar las etiquetas'
    )
  #
  updateTagView: (ids, tag_ids) ->
    tagsHTML = @createTags(tag_ids)

    _.each(ids, (v) ->
      sel = "li##{v}"
      $(sel).find('input.row-check').prop('checked', false)
      $(sel).find('ul.btags').html(tagsHTML)
    )
  #
  createTags: (tag_ids) ->
    _.map(tag_ids, (id) => TagFormater.getTagHtml(id) ).join('')
  #
  ajaxData: (ids) ->
    {model: @model, ids: ids, tag_ids: $(@input).select2('val')}

# Main class
class Tag
  constructor: (@list, @model, @data) ->
    @formatTags()
    @editor = new TagEditor
    @search = new TagSelector({model: @model, data: @data, list: @list})
  #
  formatTags: ->
    $(@list).find('.btags').each((i, el) =>
      $el = $(el)
      $el.html( _.map( $el.data('tag_ids'), (v) =>
        TagFormater.getTagHtml(v) ).join('')
      )
    )
#
TagFormater = {
  formatResult: (data) ->
    color = Plugin.Color.idealTextColor(data.bgcolor)

    ['<span class="btag" style="background-color:', data.bgcolor,
      ';color:', color, ';">', data.text, '</span>'
    ].join('')

  formatSelect: (data) ->
    color = Plugin.Color.idealTextColor(data.bgcolor)

    ['<span class="btag" style="background-color:', data.bgcolor,
      ';color:', color, ';">',
      '<a class="icon-remove remove-tag" href="javascript:;" style="color:', color,'"></a> ',
      data.text, '</span>'
    ].join('')
  #
  getTagHtml: (id) ->
    "<li>#{ @formatResult(@getTag(id)) }</li>"
  #
  getTag: (id) ->
    @tags = @tags or @tagList()
    @tags[id]
  #
  tagList: ->
    h = {}
    _.each(window.tags, (v) -> h[v.id] = v)
    
    h
}

Plugin.Tag = Tag
Plugin.TagEditor = TagEditor
Plugin.TagSelector = TagSelector
