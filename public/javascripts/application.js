(function() {
  $(document).ready(function() {
    var createDialog, csfr_token, currency, mark, ntc, parsearFecha, roundVal, serializeFormElements, setDateSelect, setIframePostEvents, speed, start, toByteSize, transformDateSelect, transformMinuteSelect, _b;
    _b = {};
    window._b = _b;
    speed = 300;
    csfr_token = $('meta[name=csfr-token]').attr('content');
    $.datepicker._defaults.dateFormat = 'dd M yy';
    parsearFecha = function(fecha, tipo) {
      var d;
      fecha = $.datepicker.parseDate($.datepicker._defaults.dateFormat, fecha);
      d = [fecha.getFullYear(), fecha.getMonth() + 1, fecha.getDate()];
      if ('string' === tipo) {
        return d.join("-");
      } else {
        return d;
      }
    };
    setDateSelect = function(el) {
      var fecha;
      fecha = parsearFecha($(el).val());
      $(el).siblings('select[name*=1i]').val(fecha[0]);
      $(el).siblings('select[name*=2i]').val(fecha[1]);
      return $(el).siblings('select[name*=3i]').val(fecha[2]);
    };
    $.setDateSelect = $.fn.setDateSelect = setDateSelect;
    transformMinuteSelect = function(el, step) {
      var $el, k, options, sel, steps, val;
      if (step == null) {
        step = 5;
      }
      $el = $(el);
      val = $el.val();
      steps = parseInt(60 / 5) - 1;
      options = [];
      for (k = 0; (0 <= steps ? k <= steps : k >= steps); (0 <= steps ? k += 1 : k -= 1)) {
        if (el === val) {
          sel = 'selected="selected"';
        } else {
          sel = "";
        }
        options.push('<option value="' + (5 * k) + '" ' + sel + '>' + (5 * k) + '</option>');
      }
      options = options.join("");
      return $(el).html(options);
    };
    transformDateSelect = function(elem) {
      return $(elem).find('.date, .datetime').each(function(i, el) {
        var day, input, minute, month, year;
        input = document.createElement('input');
        $(input).attr({
          'class': 'date-transform',
          'type': 'text',
          'size': 10
        });
        year = $(el).find('select[name*=1i]').hide().val();
        month = (1 * $(el).find('select[name*=2i]').hide().val()) - 1;
        day = $(el).find('select[name*=3i]').hide().after(input).val();
        minute = $(el).find('select[name*=5i]');
        if (minute.length > 0) {
          transformMinuteSelect(minute);
        }
        $(input).datepicker({
          yearRange: '1900:',
          showOn: 'both',
          buttonImageOnly: true,
          buttonImage: '/stylesheets/images/calendar.gif',
          onSelect: function(dateText, inst) {
            return $.setDateSelect(inst.input);
          }
        });
        if (year !== '' && month !== '' && day !== '') {
          return $(input).datepicker("setDate", new Date(year, month, day));
        }
      });
    };
    $.transformDateSelect = $.fn.transformDateSelect = transformDateSelect;
    $('[tooltip]').live('mouseover mouseout', function(e) {
      var div, pos;
      div = '#tooltip';
      if ($(this).hasClass('error')) {
        div = '#tooltip-error';
      }
      if (e.type === 'mouseover') {
        pos = $(this).position();
        $(div).css({
          'top': pos.top + 'px',
          'left': (e.clientX + 20) + 'px'
        }).html($(this).attr('tooltip'));
        return $(div).show();
      } else {
        return $(div).hide();
      }
    });
    $('a.more').live("click", function() {
      return $(this).html('Ver menos').removeClass('more').addClass('less').next('.hidden').show(speed);
    });
    $('a.less').live('click', function() {
      return $(this).html('Ver más').removeClass('less').addClass('more').next('.hidden').hide(speed);
    });
    createDialog = function(params) {
      var div;
      params = $.extend({
        'id': new Date().getTime(),
        'title': '',
        'width': 800,
        'height': 400,
        'modal': true,
        'resizable': false
      }, params);
      div = document.createElement('div');
      $(div).attr({
        'id': params['id'],
        'title': params['title'],
        'data-ajax_id': params['id']
      }).addClass('ajax-modal').css({
        'z-index': 1000
      });
      delete params['id'];
      delete params['title'];
      $(div).dialog(params);
      return div;
    };
    $('a.ajax').live("click", function(e) {
      var div, id;
      id = new Date().getTime().toString();
      $(this).attr('data-ajax_id', id);
      div = createDialog({
        'title': $(this).attr('data-title')
      });
      $(div).load($(this).attr("href"), function(e) {
        return $(div).find('a.new[href*=/], a.edit[href*=/], a.list[href*=/]').hide();
      });
      e.stopPropagation();
      return false;
    });
    roundVal = function(val, dec) {
      dec = dec || 2;
      return Math.round(val * Math.pow(10, dec)) / Math.pow(10, dec);
    };
    $.roundVal = $.fn.roundVal = roundVal;
    currency = {
      'separator': ",",
      'delimiter': '.',
      'precision': 2
    };
    _b.currency = currency;
    ntc = function(val) {
      var ar, arr, c, i, l, sep, sign, t, tmp, vals;
      val = typeof val === 'string' ? 1 * val : val;
      if (val < 0) {
        sign = "-";
      } else {
        sign = "";
      }
      val = val.toFixed(_b.currency.precision);
      vals = val.toString().replace(/^-/, "").split(".");
      val = vals[0];
      l = val.length - 1;
      ar = val.split("");
      arr = [];
      tmp = "";
      c = 0;
      for (i = l; (l <= 0 ? i <= 0 : i >= 0); (l <= 0 ? i += 1 : i -= 1)) {
        tmp = ar[i] + tmp;
        if ((l - i + 1) % 3 === 0 && i < l) {
          arr.push(tmp);
          tmp = '';
        }
        c++;
      }
      t = arr.reverse().join(_b.currency.delimiter);
      if (tmp !== "") {
        sep = t.length > 0 ? _b.currency.delimiter : "";
        t = tmp + sep + t;
      }
      return sign + t + _b.currency.separator + vals[1];
    };
    _b.ntc = ntc;
    toByteSize = function(bytes) {
      switch (true) {
        case bytes < 1024:
          return bytes + " bytes";
        case bytes < Math.pow(1024, 2):
          return roundVal(bytes / Math.pow(1024, 1)) + " Kb";
        case bytes < Math.pow(1024, 3):
          return roundVal(bytes / Math.pow(1024, 2)) + " MB";
        case bytes < Math.pow(1024, 4):
          return roundVal(bytes / Math.pow(1024, 3)) + " GB";
        case bytes < Math.pow(1024, 5):
          return roundVal(bytes / Math.pow(1024, 4)) + " TB";
        case bytes < Math.pow(1024, 6):
          return roundVal(bytes / Math.pow(1024, 5)) + " PB";
        default:
          return roundVal(bytes / Math.pow(1024, 6)) + " EB";
      }
    };
    _b.tobyteSize = toByteSize;
    setIframePostEvents = function(iframe, created) {
      return iframe.onload = function() {
        var html, posts, postsSize;
        html = $(iframe).contents().find('body').html();
        if ($(html).find('form').length <= 0 && created) {
          $('#posts ul:first').prepend(html);
          mark('#posts ul li:first');
          posts = parseInt($('#posts ul:first>li').length);
          postsSize = parseInt($('#posts').attr("data-posts_size"));
          if (posts > postsSize) {
            $('#posts ul:first>li:last').remove();
          }
          return $('#create_post_dialog').dialog('close');
        } else {
          created = true;
          return $('#create_post_dialog').html(html);
        }
      };
    };
    $('a.post').live('click', function() {
      var div, iframe;
      if ($('iframe#post_iframe').length <= 0) {
        iframe = $('<iframe />').attr({
          'id': 'post_iframe',
          'name': 'post_iframe',
          'style': 'display:none;'
        })[0];
        $('body').append(iframe);
        setIframePostEvents(iframe, false);
        div = createDialog({
          'id': 'create_post_dialog',
          'title': 'Crear comentario'
        });
      } else {
        div = $('#create_post_dialog').dialog("open").html("");
      }
      $(div).load($(this).attr("href"));
      return false;
    });
    $('div.ajax-modal form[enctype!=multipart/form-data]').live('submit', function() {
      var data, el;
      data = serializeFormElements(this);
      el = this;
      $.ajax({
        'url': $(el).attr('action'),
        'cache': false,
        'context': el,
        'data': data,
        'type': data['_method'] || $(this).attr('method'),
        'success': function(resp, status, xhr) {
          var id, p;
          if ($(resp).find('input:submit').length <= 0) {
            p = $(el).parents('div.ajax-modal');
            id = $(p).attr('data-ajax_id');
            $(p).dialog('destroy');
            return $('body').trigger('ajax:complete', [resp]);
          } else {
            return $(el).parents('div.ajax-modal:first').html(resp);
          }
        },
        'error': function(resp) {
          return alert('Existen errores en su formulario por favor corrija los errores');
        }
      });
      return false;
    });
    $('a.delete').live("click", function(e) {
      var el, url;
      $(this).parents("tr:first, li:first").addClass('marked');
      if (confirm('Esta seguro de borrar el item seleccionado')) {
        url = $(this).attr('href');
        el = this;
        $.ajax({
          'url': url,
          'type': 'delete',
          'context': el,
          'success': function() {
            $(el).parents("tr:first, li:first").remove();
            return $('body').trigger('ajax:delete', url);
          },
          'error': function() {
            return alert('Existio un error al borrar');
          }
        });
      } else {
        $(this).parents("tr:first, li:first").removeClass('marked');
        e.stopPropagation();
      }
      return false;
    });
    serializeFormElements = function(elem) {
      var params;
      params = {};
      $(elem).find('input:not(:radio):not(:checkbox), select, textarea').each(function(i, el) {
        if ($(el).val()) {
          return params[$(el).attr('name')] = $(el).val();
        }
      });
      $(elem).find('input:radio:checked, input:checkbox:checked').each(function(i, el) {
        return params[$(el).attr('name')] = $(el).val();
      });
      return params;
    };
    $.serializeFormElements = $.fn.serializeFormElements = serializeFormElements;
    mark = function(selector, velocity, val) {
      var self;
      self = selector || this;
      val = val || 0;
      velocity = velocity || 30;
      $(self).css({
        'background': 'rgb(255,255,' + val + ')'
      });
      if (val >= 255) {
        $(self).attr("style", "");
        return false;
      }
      return setTimeout(function() {
        val += 5;
        return mark(self, velocity, val);
      }, velocity);
    };
    $.mark = $.fn.mark = mark;
    start = function() {
      return transformDateSelect('body');
    };
    return start();
  });
}).call(this);
