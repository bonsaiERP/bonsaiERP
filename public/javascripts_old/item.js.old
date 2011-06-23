/**
* Class that creates the table of ranges
*/
DiscountRange = function(field_id) {
  this.initialize(field_id);
}
DiscountRange.prototype = {
  'reg_range_discount': /^([\d]+(\.[\d]+)?:[\d]+(\.\d)?\s+)*([\d]+(\.[\d]+)?:[\d]+(\.\d)?\s*)?$/,
  /**
  * Constructor function
  * @param String : Id of the field
  */
  'initialize': function(field_id) {
    var self = this;
    self['field_id'] = field_id;
    self.setEvents();
  },
  // Events for the field
  'setEvents': function() {
    var self = this;
    // focus
    $('#' + this.field_id).focus(function() {
      if($('#' + self.field_id + '_div').length <= 0) {
        self.createDiv();
      }
      var value = $(this).val();
      $('#' + self.field_id + '_div').show();
    });

    // blur
    $('#' + self.field_id).blur(function() {
      $('#' + self.field_id + '_div').hide();
    });

    // keyup
    $('#' + self.field_id).keyup(function() {
      self.setTable();
    });
  },
  /**
   * Sets the table if valid
   */
  'setTable': function() {
    var self = this;
    var values = self.splitValues( $('#' + self.field_id ).val() );
    $('#' + self.field_id + '_table').replaceWith(self.createTable(values) );
  },
  /**
   * Splits the value for range string and values
   * @param String
   * @return Array
   */
  'splitValues': function(val) {
    var val = val.replace(/\s*$/, "");
    var arr = [];
    var self = this;
    if( self.reg_range_discount.test( val ) && !( /^\s*$/.test( val ) ) ) {
      $(val.split(/\s+/)).each(function(i, el) {
        var tmp = el.split(":");
        arr[arr.length] = [parseFloat(tmp[0]), parseFloat(tmp[1]) ];
      });
    }
    return arr;
  },
  /**
   * Creates an HTML table to display ranges
   * @param Array
   * @return String
   */
  'createTable': function(values) {
    var html = '';
    var self = this;
    var create = false;

    $(values).each(function(i, el) {
      if(values[i + 1]) {
        txt = el[0] + ' o menor que ' + values[i + 1][0];
      }else {
        txt = 'mayores o igual a ' + el[0];
      }
      html += '<tr><td>' + txt + '</td><td>' + el[1] + ' %</td></tr>';
    });

    return '<table class="decorated" id="' + self.field_id + '_table"><tr><th>Rango</th><th>Porcentaje (%)</th>' + html + '</table>';
  },
  /**
  * Creates the div for the field
  */
  'createDiv': function() {
    var self = this;
    var div = document.createElement('div');
    var values = self.splitValues( $('#' + self.field_id ).val() );
    var html = ['<p class="hint">Ingrese rangos con formato (cantidad:porcentaje) Ej.: 10:5 20:7 40:7.5<br/>', 
        'o oferta única Ej.: 0:3<br />', 'Nota: el porcetaje acepta solo números con 1 decimal</p>',
        '<h3 class="dark">Rangos</h3>', self.createTable( values ) ].join("");
    $(div).attr({'id': self.field_id + '_div'})
    .css({
      'position': 'absolute', 'width': '300px', 'padding': '5px', 'margin-top': '-1px',
      'background-color': '#FFF', 'border': '1px solid #DFDFDF'
    }).html( html ).insertAfter('#' + self.field_id);
  }
}

