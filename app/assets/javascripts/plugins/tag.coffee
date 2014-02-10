# Create new and administrate
class TagEditor
  sel: '#btag-editor'
  constructor: ->
    @$name = $(@sel).find('#btag-name-input')
    @$bgcolor = $(@sel).find('#btag-bgcolor-input')
    @$button = $(@sel).find('button')
    $(@sel).dialog({autoOpen: false, width: 400, title: 'Nueva etiqueta', modal: true})
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
    $(@sel).find('button').prop('disabled', true)
    $.post('/tags', @data(), (resp) =>
      $(@sel).find('button').prop('disabled', false)
      @setAjaxResponse(resp)
    )
  data: ->
    {tag: {name: @$name.val(), bgcolor: @$bgcolor.val()}}
  #
  setAjaxResponse: (resp) ->
    if resp.id
      $(@sel).dialog('close')
      window.tags.push({id: resp.id, text: resp.name, label: resp.name, bgcolor: resp.bgcolor})
      window.tags = _.sortBy(window.tags, (v) -> v.label )
      $('#tags').trigger('btags:newtag', [resp])
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
    throw 'You must set window.tags for TagSelector'  unless window.tags?
    throw 'You must set a list in options in TagSelector class'  unless @options.list?
    @list = @options.list

    @tag = @options.tag

    @$button = $(@sel).find('button')
    @setSelect2()
    @setEvents()
  #
  setSelect2: ->
    $('#tags').select2({
      data: window.tags,
      multiple: true,
      formatResult: TagFormater.formatResult,
      formatSelection: TagFormater.formatSelect,
      containerCssClass: 'btags',
      dropdownCssClass: 'btags',
      escapeMarkup: (t) -> t
    })
  #
  setEvents: ->
    @setRemoveEvent()
    @$button.on 'click', @applyTags

    $('#tags').on 'btags:newtag', (event, tag) => @updateSelect2(event, tag)
  #
  setRemoveEvent: ->
    $('.btags').off('click', 'a.remove-tag')
    $('.btags').on('click', 'a.remove-tag', ->
      $(this).parents('.select2-search-choice').find('a.select2-search-choice-close').trigger('click')
    )
  # updates the select2 data with new tag as well for the
  # TagFormater.tags
  updateSelect2: (event, tag) ->
    $('#tags').select2('destroy')
    @setSelect2()
    vals = $('#tags').select2('val')
    vals.push(tag.id)
    $('#tags').select2('val', vals)

    @setRemoveEvent()
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
    @$button.prop 'disabled', true

    $.post('/tags/update_models', data, (resp) =>
      @$button.prop 'disabled', false
      if resp.success
        @updateTagView(ids, data.tag_ids)
      else
        alert 'Existio un error al actualizar las etiquetas'
    )
  #
  updateTagView: (ids, tag_ids) ->
    tagsHTML = @createTags(tag_ids)

    _.each(ids, (v) ->
      $sel = $("li##{v}")
      $sel.removeClass('selected')
      $sel.find('input.row-check').prop('checked', false)
      $sel.find('ul.btags').html(tagsHTML)
    )
  #
  createTags: (tag_ids) ->
    _.map(tag_ids, (id) => TagFormater.getTagHtml(id) ).join('')
  #
  ajaxData: (ids) ->
    {model: @model, ids: ids, tag_ids: $(@input).select2('val')}

# Main class
class Tag
  constructor: (@list, @model) ->
    @formatTags()
    @editor = new TagEditor
    @search = new TagSelector({model: @model, list: @list})
    # Needs to be inside constructor
    # reset for TagFormater.tags
    $('body').on('btags:newtag', '#tags', -> TagFormater.resetTags())

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
    return ''  unless data
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
    _.each(window.tags, (v) ->
      v.label = v.text
      h[v.id] = v
    )

    h
  #
  resetTags: ->
    @tags = null
}

# Uses jqueryui autocomplete to search with tags
class TagSearch
  constructor: (@sel) ->
    @$input = $(@sel)
    @setSearchTags()

    @setAutocomplete()
    @setFormatTags()

    @setEvents()
  #
  setAutocomplete: ->
    self = this
    @$input.autocomplete({
      source: (req, resp) ->
        resp( $.ui.autocomplete.filter(self.getTags(), self.lastValue() ) )
      focus: -> false
      select: (event, ui) =>

        @setInputVal(ui.item)
        @_getTags = false
    })
  #
  setEvents: ->
    @$input.on 'keydown', (event) =>
      return false  if event.keyCode is $.ui.keyCode.COMMA
      @_getTags = false  if event.keyCode is $.ui.keyCode.BACKSPACE
      true

    $('body').on 'btags:newtag', '#tags', =>
      @_getTags = @_tagLabels = false
      @tagLabels()
  #
  tagLabels: ->
    @_tagLabels = @_tagLabels || _(tags).filter((v) -> v.text).map((v) -> v.text).value()
  #
  setInputVal: (item) ->
    val = @$input.val().split(';')
    val.pop()
    val.push(item.text)
    @$input.val(val.join(';') + ";")
  #
  getTags: ->
    @_getTags = @_getTags || _(tags).filter((v) => not _.include(@splitVal(), v.text) ).value()
  #
  splitVal: ->
    @$input.val().split(';')
  #
  lastValue: ->
    @$input.val().split(";").pop()
  #
  setFormatTags: ->
    @$input.data('uiAutocomplete')._renderItem = ($list, item) ->
      item.label = item.text
      $("<li><a>#{TagFormater.formatResult(item)}</a></li>")
      .data('uiAutocomplete', item).appendTo($list)
  #
  setSearchTags: ->
    id = new Date().getTime()
    @$inputTags = $("<input type='hidden' name='search_tags' id='#{id}'/>").insertBefore(@$input)



Plugin.Tag = Tag
Plugin.TagEditor = TagEditor
Plugin.TagSelector = TagSelector
Plugin.TagFormater = TagFormater
Plugin.TagSearch = TagSearch
