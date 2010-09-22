var dateFormat = 'dd, mmm yyyy';

jQuery(function($) {

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
function changeDateSelect(el) {
  var input = document.createElement('input');
  $(input).attr('type', 'text');
  $(el).find('select:eq(2)').after(input);

  var currentDate = [];
  $(el).find('select:lt(3)').hide();
  year = $(el).find('select[name*=1i]').hide().val();
  month = parseInt( $(el).find('select[name*=2i]').hide().val() ) - 1;
  day = $(el).find('select[name*=3i]').hide().after( input ).val();

  currentDate = new Date(year, month, day);

  $(input).dateinput({
    'format': dateFormat,
    'lang': 'es',
    'selectors': true,
    'firstDay': 1,
    'change': function() {
      var val = this.getValue('yyyy-mm-dd');
      val = val.split('-');
      self = this.getInput();
      $(val).each(function(i, el) {
        var val = el.replace(/^0([0-9]+$)/, '$1');
        $(self).siblings('select[name*=' + (i + 1) + 'i]').val(val);
      });
    }
  });
  $(input).data('dateinput').setValue(currentDate);
}
