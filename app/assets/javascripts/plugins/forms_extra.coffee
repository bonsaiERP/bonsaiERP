(($) ->
  $.fn.select2.defaults = _.merge($.fn.select2.defaults, {
    numCars: (n) -> if n == 1 then "" else "es"
    formatResultCssClass: -> undefined
    formatNoMatches: -> "No se encontro"
    formatInputTooShort: (input, min) -> 
      n = min - input.length
      "Ingrese #{n} caracter#{@numCars(n)} mas"
    formatInputTooLong: (input, max) -> 
      n = input.length - max
      "Ingrese #{n} caracter#{@numCars(n)} menos"
    ###
    formatSelectionTooBig: ->
      #function (limit) { return "You can only select " + limit + " item" + (limit == 1 ? "" : "s"); },
    ###
    formatLoadMore: -> "Cargando resultados..."
      #function (pageNumber) { return "Loading more results..."; },
    formatSearching: -> "Buscando..."
  })

  select2Autocomplete = (el) ->
    $this = $(this)

    $this.select2(
      minimumInputLength: 2
      ajax: {
        url: $this.data('source')
        dataType: 'json'
        data: (term) ->
          { q: term }
        results: (data, page) ->
          {results: data}
      }
      formatResult: (res) ->
        "#{res.to_s}"
      formatSelection: (res) ->
        "#{res.to_s}"
    )

  $.fn.select2Autocomplete = select2Autocomplete

)(jQuery)

