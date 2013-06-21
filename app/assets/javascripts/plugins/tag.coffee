class NewTag
  sel: '#btag-editor'
  constructor: ->
    @$name = $('#btag-name-input')
    @$bgcolor = $('#btag-bgcolor-input')
    @setEvents()
  #
  setEvents: ->
    self = this
    $(@sel).on('click', '.color', ->
      self.$bgcolor.val($(this).data('color')).trigger('keyup')
    )

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
