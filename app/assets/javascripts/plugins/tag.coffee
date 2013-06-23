class NewTag
  sel: '#btag-editor'
  constructor: ->
    @$name = $(@sel).find('#btag-name-input')
    @$bgcolor = $(@sel).find('#btag-bgcolor-input')
    @$button = $(@sel).find('button')
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
      alert 'saved'
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

class SearchTag
  text: ''
  constructor: (@input, @data) ->
    @setSelect2()

  #
  setSelect2: ->
    $(@input).select2({
      data: @data,
      multiple: true,
      formatResult: Plugin.Tag.formatResult,
      formatSelection: Plugin.Tag.formatSelect,
      containerCssClass: 'btags',
      dropdownCssClass: 'btags',
      escapeMarkup: (t) -> t
    })

    @setSelect2Events()
  #
  setSelect2Events: ->
    self = this
    @$cont = $(self.input).select2('container')
    @$input = @$cont.find('.select2-input')
    @$input.on('keyup', -> self.text = this.value )

    #$(@input).one('select2-focus', ->   )
    $(@$cont).on('focus', '.select2-input', (event) ->
      this.value = self.text
      #console.log 'setting', self.text, this
    )

    @$cont.on('change paste input focus', '.select2-input', (event) =>
      console.log event.type,'input'
    )
    $(@input).on 'select2-blur change selec2-focus', (event) ->
      console.log event.type,'cont'

#
Tag = {
  formatResult: (data) ->
    color = Plugin.Color.idealTextColor(data.bgcolor)

    ['<span class="btag" style="background-color:', data.bgcolor,
      ';color:', color, ';">', data.text, '</span>'
    ].join('')

  formatSelect: (data) ->
    color = Plugin.Color.idealTextColor(data.bgcolor)

    ['<span class="btag" style="background-color:', data.bgcolor,
      ';color:', color, ';">',
      '<a class="icon-remove" href="javascript:;" style="color:', color,'"></a> ',
      data.text, '</span>'
    ].join('')
}

Plugin.Tag = Tag
Plugin.SearchTag = SearchTag
Plugin.NewTag = NewTag
