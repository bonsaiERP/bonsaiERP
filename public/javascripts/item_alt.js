(function() {
  var DiscountRange;
  DiscountRange = function(field_id) {
    var self;
    self = this;
    self['field_id'] = field_id;
    self.setEvents();
    return this;
  };
  DiscountRange.prototype.reg_range_discount = /^([\d]+(\.[\d]+)?:[\d]+(\.\d)?\s+)*([\d]+(\.[\d]+)?:[\d]+(\.\d)?\s*)?$/;
  DiscountRange.prototype.setEvents = function() {
    var self;
    self = this;
    $('#' + self.field_id).focus(function() {
      if ($('#' + self.field_id + '_div').length <= 0) {
        self.createDiv();
      }
      return $('#' + self.field_id + '_div').show();
    });
    $('#' + self.field_id).blur(function() {
      return $('#' + self.field_id + '_div').hide();
    });
    return $('#' + self.field_id).keyup(function() {
      return self.setTable();
    });
  };
  DiscountRange.prototype.setTable = function() {
    var self, values;
    self = this;
    values = self.splitValues($('#' + self.field_id).val());
    return $('#' + self.field_id + '_table').replaceWith(self.createTable(values));
  };
  DiscountRange.prototype.splitValues = function(val) {
    var self;
    self = this;
    val = val.replace(/\s*$/, '');
    return (self.reg_range_discount.test(val) && !(/^\s*$/.test(val))) ? $(val.split(" ")).map(function(i, el) {
      return [
        $(el.split(":")).map(function(i, elem) {
          return parseFloat(elem);
        }).toArray()
      ];
    }).toArray() : null;
  };
  DiscountRange.prototype.createTable = function(values) {
    var html, self;
    html = '';
    self = this;
    $(values).each(function(i, el) {
      var txt;
      if (values[i + 1]) {
        txt = el[0] + ' o menor que ' + values[i + 1][0];
      } else {
        txt = 'mayores o igual a ' + el[0];
      }
      return html += '<tr><td>' + txt + '</td><td>' + el[1] + ' %</td></tr>';
    });
    return '<table class="decorated" id="' + self.field_id + '_table"><tr><th>Rango</th><th>Porcentaje (%)</th>' + html + '</table>';
  };
  DiscountRange.prototype.createDiv = function() {
    var html, self, values;
    self = this;
    values = self.splitValues($('#' + self.field_id).val());
    html = ['<p class="hint">Ingrese rangos con formato (cantidad:porcentaje) Ej.: 10:5 20:7 40:7.5<br/>', 'o oferta única Ej.: 0:3<br />', 'Nota: el porcetaje acepta solo números con 1 decimal</p>', '<h3 class="dark">Rangos</h3>', self.createTable(values)].join("");
    return $('<div \>').attr({
      'id': self.field_id + '_div'
    }).css({
      'position': 'absolute',
      'width': '300px',
      'padding': '5px',
      'margin-top': '-1px',
      'background-color': '#FFF',
      'border': '1px solid #DFDFDF'
    }).html(html).insertAfter('#' + self.field_id);
  };
  window.DiscountRange = DiscountRange;
})();
