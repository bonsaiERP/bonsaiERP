var dateFormat = 'dd, mmm yyyy';

jQuery(function($) {

  //$('input.date').dateinput({ 'format': dateFormat, 'lang': 'es', 'firstDay': 1 });

  $('div.date, div.datetime').each(function(i, el) {
     var sel = $(el).find('select:eq(2)');
     if(sel.length > 0) {
       changeDateSelect(el);
     }
  });

});

/**
 * Changes the selects from date to a dateselect field
 * @param selector jQuery
 */
function changeDateSelect(sel) {
  var datesel = document.createElement('input');
  $(datesel).attr('type', 'text');
  $(sel).find('select:eq(2)').after(datesel);

  var currentDate = [];
  $(sel).find('select:lt(3)').hide().each(function(i, el) {
    currentDate.push(parseInt($(el).val() ) );
  });
  currentDate = new Date(currentDate[0], (currentDate[1] - 1), currentDate[2]);

  $(datesel).dateinput({
    'format': dateFormat,
    'lang': 'es', 
    'selectors': true,
    'firstDay': 1,
    'change': function() {
      var val = this.getValue('yyyy-mm-dd');
      val = val.split('-');
      $(this.getInput()).siblings('select:hidden').each(function(i, elem){
        $(elem).val( parseInt(val[i]) );
      });
    }
  });
  $(datesel).data('dateinput').setValue(currentDate);

}
