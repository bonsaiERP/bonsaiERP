$(->
  # Tooltip
  $('[title]').tooltip()


  # Video
  $('#video').click(->
    html = '<iframe width="640" height="390" src="http://youtube.com/embed/cnK38rqrlok/?autoplay=1&rel=0" frameborder="0" allowfullscreen></iframe>'
    $('<div/>').html(html).
    dialog({
      modal: true, 
      width: 660,
      height: 410,
      close: (event, ui)-> 
        $(this).remove()
    })
  )
)
