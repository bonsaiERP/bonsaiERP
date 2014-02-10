$(->
  # Copied from jquery source to generate put, patch and delete methods
  $(['put', 'patch', 'delete']).each (i, method) ->
    jQuery[ method ] = ( url, data, callback, type ) ->
      if jQuery.isFunction( data )
        type = type || callback
        callback = data
        data = undefined

      jQuery.ajax({
        url: url,
        type: method,
        dataType: type,
        data: data,
        success: callback
      })
)
