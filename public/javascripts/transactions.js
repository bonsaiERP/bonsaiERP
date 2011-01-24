(function() {
  var Transaction;
  Transaction = (function() {
    Transaction.prototype.conf = {
      'currency_id': '#income_currency_id',
      'discount_id': '#income_discount',
      'taxes_id': '#taxes',
      'subtotal_id': '#subtotal',
      'discount_percentage_id': '#discount_percentage',
      'discount_total_id': '#discount_total',
      'taxes_total_id': '#taxes_total',
      'taxes_percentage_id': '#taxes_percentage',
      'total_id': '#total_value',
      'items_table_id': '#items_table',
      'add_item_id': '#add_item'
    };
    function Transaction(items, trigger, conf) {
      var self;
      this.items = items;
      this.trigger = trigger != null ? trigger : 'body';
      if (conf == null) {
        conf = {};
      }
      self = this;
      this.conf = $.extend(this.conf, conf);
      self.set_events();
    }
    Transaction.prototype.set_events = function() {
      this.set_discount_event();
      this.set_taxes_event();
      this.set_item_change_event("table select.item", "input.price");
      this.set_price_quantity_change_event("table", "input.price", "input.quantity");
      return this.set_add_item_event();
    };
    Transaction.prototype.set_discount_event = function() {
      var self;
      self = this;
      return $(this.conf.discount_id).live("change", function() {
        var val;
        val = $(this).val() * 1;
        $(self.conf.discount_percentage_id).html(_b.ntc(val)).data("val", val);
        return self.calculate_discount();
      });
    };
    Transaction.prototype.set_taxes_event = function(id) {
      var self;
      if (id == null) {
        id = this.conf.taxes_id;
      }
      self = this;
      return $(id).find("input:checkbox").live('click', function() {
        var k, sum, _i, _len, _ref;
        sum = 0;
        _ref = $(self.conf.taxes_id).find("input:checkbox:checked");
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          k = _ref[_i];
          sum += 1 * $(k).siblings("span").data("rate");
        }
        $(self.conf.taxes_percentage_id).html(_b.ntc(sum)).data("val", sum);
        return self.calculate_taxes();
      });
    };
    Transaction.prototype.set_item_change_event = function(item_sel, price_sel) {
      var self;
      self = this;
      return $(item_sel).live("change keyup", function() {
        var id, item;
        id = $(this).val();
        item = self.search_item(id);
        return $(this).parents("tr:first").find(price_sel).val(item.price).trigger("change");
      });
    };
    Transaction.prototype.set_price_quantity_change_event = function(grid_sel, price_sel, quantity_sel) {
      var self;
      self = this;
      return $(grid_sel).find("" + price_sel + ", " + quantity_sel).live("change", function() {
        return self.calculate_total_row(this, "input.price,input.quantity", "td.total_row");
      });
    };
    Transaction.prototype.set_add_item_event = function() {
      var self;
      self = this;
      return $(this.conf.add_item_id).live("click", function() {
        return self.add_item();
      });
    };
    Transaction.prototype.calculate_total_row = function(el, selectors, res) {
      var $tr, tot;
      tot = 1;
      $tr = $(el).parents("tr:first");
      $tr.find(selectors).each(function(i, el) {
        return tot = tot * $(el).val();
      });
      $tr.find(res).html(_b.ntc(tot)).data("val", tot);
      return this.calculate_subtotal("table " + res);
    };
    Transaction.prototype.calculate_subtotal = function(selector) {
      var sum;
      sum = 0;
      $(selector).each(function(i, el) {
        return sum += $(el).data("val") || 0;
      });
      $(this.conf.subtotal_id).html(_b.ntc(sum)).data("val", sum);
      return this.calculate_discount();
    };
    Transaction.prototype.calculate_discount = function() {
      var val;
      val = (-1 * $(this.conf.discount_id).val()) / 100 * $(this.conf.subtotal_id).data("val") || 0;
      $(this.conf.discount_total_id).html(_b.ntc(val)).data("val", val);
      return this.calculate_taxes();
    };
    Transaction.prototype.calculate_taxes = function() {
      var val;
      val = ($(this.conf.subtotal_id).data("val") + $(this.conf.discount_total_id).data("val")) * $(this.conf.taxes_percentage_id).data("val") / 100 || 0;
      $(this.conf.taxes_total_id).html(_b.ntc(val)).data("val", val);
      return this.calculate_total();
    };
    Transaction.prototype.calculate_total = function() {
      var sum;
      sum = $(this.conf.subtotal_id).data("val") + $(this.conf.discount_total_id).data("val") + $(this.conf.taxes_total_id).data("val") || 0;
      return $(this.conf.total_id).html(_b.ntc(sum)).data("val", sum);
    };
    Transaction.prototype.add_item = function() {
      var $tr, pos;
      $tr = $("" + this.conf.items_table_id + " tr:eq(1)").clone();
      pos = (new Date()).getTime();
      $tr.find("input, select").each(function(i, el) {
        var name;
        name = $(el).attr("name").replace(/\[\d+\]/, "[" + pos + "]");
        return $(el).attr("name", name).val("");
      });
      return $tr.insertBefore("" + this.conf.items_table_id + " tr.extra:first");
    };
    Transaction.prototype.search_item = function(id) {
      var k, _i, _len, _ref;
      id = parseInt(id);
      _ref = this.items;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        k = _ref[_i];
        if (id === k.id) {
          return k;
        }
      }
    };
    return Transaction;
  })();
  window.Transaction = Transaction;
}).call(this);
