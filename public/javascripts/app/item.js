(function() {
  var DiscountRange, DiscountRangeShow;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  DiscountRange = (function() {
    function DiscountRange(field_id) {
      var self;
      self = this;
      self['field_id'] = field_id;
      self.setEvents();
    }
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
        $('#' + self.field_id + '_div').hide();
        return self.validateSecuence(self.splitValues($('#' + self.field_id).val()));
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
      if (self.reg_range_discount.test(val) && !(/^\s*$/.test(val))) {
        return $(val.split(" ")).map(function(i, el) {
          return [
            $(el.split(":")).map(function(i, elem) {
              return parseFloat(elem);
            }).toArray()
          ];
        }).toArray();
      }
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
    DiscountRange.prototype.validateSecuence = function(values) {
      var curr_per, curr_val, first;
      console.log(values);
      curr_val = curr_per = 0;
      first = true;
      return $(values).each(function(i, el) {
        if (!first) {
          if (el[0] <= curr_val || el[1] <= curr_per) {
            alert('La secuencia de un rango de descuento debe ser de menor a mayor Ej.: 10:2 15:2.5');
            return false;
          }
        }
        first = false;
        curr_val = el[0];
        return curr_per = el[1];
      });
    };
    return DiscountRange;
  })();
  window.DiscountRange = DiscountRange;
  DiscountRangeShow = (function() {
    __extends(DiscountRangeShow, DiscountRange);
    function DiscountRangeShow(field_id) {
      var self;
      self = this;
      self['field_id'] = field_id;
    }
    DiscountRangeShow.prototype.tableForField = function(value) {
      var self;
      self = this;
      return $(self.createTable(self.splitValues(value))).appendTo('#' + self.field_id);
    };
    return DiscountRangeShow;
  })();
  window.DiscountRangeShow = DiscountRangeShow;
}).call(this);
