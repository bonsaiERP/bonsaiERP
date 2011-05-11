(function() {
  var currency, ntc, toByteSize, _b;
  String.prototype.pluralize = function() {
    if (/[aeiou]$/.test(this)) {
      return this + "s";
    } else {
      return this + "es";
    }
  };
  _b = {};
  window._b = _b;
  _b.dateFormat = function(date, format) {
    var d;
    format = format || $.datepicker._defaults.dateFormat;
    if (date) {
      d = $.datepicker.parseDate('yy-mm-dd', date);
      return $.datepicker.formatDate($.datepicker._defaults.dateFormat, d);
    } else {
      return "";
    }
  };
  currency = {
    'separator': ",",
    'delimiter': '.',
    'precision': 2
  };
  _b.currency = currency;
  ntc = function(val, precision) {
    var ar, arr, c, i, l, sep, sign, t, tmp, vals;
    precision || (precision = _b.currency.precision);
    val = typeof val === 'string' ? 1 * val : val;
    if (val < 0) {
      sign = "-";
    } else {
      sign = "";
    }
    val = val.toFixed(precision);
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
  $(document).ready(function() {
    var AjaxLoadingHTML, createAutocompleteField, createDialog, createErrorLog, createMessageCont, createSelectOption, csrf_token, getAjaxType, mark, parseDate, setDateSelect, setIframePostEvents, speed, start, transformDateSelect, transformMinuteSelect, updateTemplateRow;
    speed = 300;
    csrf_token = $('meta[name=csrf-token]').attr('content');
    window.csrf_token = csrf_token;
    $.datepicker._defaults.dateFormat = 'dd M yy';
    parseDate = function(date, tipo) {
      var d;
      date = $.datepicker.parseDate($.datepicker._defaults.dateFormat, date);
      d = [date.getFullYear(), date.getMonth() + 1, date.getDate()];
      if ('string' === tipo) {
        return d.join("-");
      } else {
        return d;
      }
    };
    createAutocompleteField = function() {
      return $(this).hide().before("<input type='text' size='" + ($(this).attr('size')) + "' style='text-align:left' class='autocomplete_view'/>");
    };
    $.createAutocompleteField = $.fn.createAutocompleteField = createAutocompleteField;
    $('input.autocomplete').createAutocompleteField();
    setDateSelect = function(el) {
      var date;
      el = el || this;
      date = parseDate($(el).val());
      $(el).siblings('select[name*=1i]').val(date[0]).trigger("change");
      $(el).siblings('select[name*=2i]').val(date[1]).trigger("change");
      return $(el).siblings('select[name*=3i]').val(date[2]).trigger("change");
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
    transformDateSelect = function() {
      return $(this).find('.date, .datetime').each(function(i, el) {
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
          buttonImage: '/stylesheets/images/calendar.gif'
        });
        $(input).change(function(e) {
          $.setDateSelect(this);
          return $(this).trigger("change:datetime", this);
        });
        if (year !== '' && month !== '' && day !== '') {
          $(input).datepicker("setDate", new Date(year, month, day));
        }
        return $('.ui-datepicker').not('.ui-datepicker-inline').hide();
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
    AjaxLoadingHTML = function() {
      return "<div class='c'><img src='/images/ajax-loader.gif' alt='Cargando' /><br/>Cargando...</div>";
    };
    window.AjaxLoadingHTML = AjaxLoadingHTML;
    createDialog = function(params) {
      var data, div, div_id, html;
      data = params;
      params = $.extend({
        'id': new Date().getTime(),
        'title': '',
        'width': 800,
        'modal': true,
        'resizable': false,
        'position': 'top',
        'close': function(e, ui) {
          return $('#' + div_id).parents("[role=dialog]").detach();
        }
      }, params);
      html = params['html'] || AjaxLoadingHTML();
      div_id = params.id;
      div = document.createElement('div');
      $(div).attr({
        'id': params['id'],
        'title': params['title']
      }).data(data).addClass('ajax-modal').css({
        'z-index': 10000
      }).html(html);
      delete params['id'];
      delete params['title'];
      $(div).dialog(params);
      return div;
    };
    window.createDialog = createDialog;
    getAjaxType = function(el) {
      if ($(el).hasClass("new")) {
        return 'new';
      } else if ($(el).hasClass("edit")) {
        return 'edit';
      } else {
        return 'show';
      }
    };
    window.getAjaxType = getAjaxType;
    $('div.ajax-modal form').live('submit', function() {
      var $div, data, el, new_record, trigger;
      if ($(this).attr('enctype') === 'multipart/form-data') {
        return true;
      }
      el = this;
      data = $(el).serialize();
      $(this).find('input, select, textarea').attr('disabled', true);
      $div = $(this).parents('.ajax-modal');
      new_record = $div.data('ajax-type') === 'new' ? true : false;
      trigger = $div.data('trigger');
      $.ajax({
        'url': $(el).attr('action'),
        'cache': false,
        'context': el,
        'data': data,
        'type': data['_method'] || $(this).attr('method'),
        'success': function(resp, status, xhr) {
          var div, p;
          if (typeof resp === "object") {
            data['new_record'] = new_record;
            p = $(el).parents('div.ajax-modal');
            $(p).html('').dialog('destroy');
            return $('body').trigger(trigger, [resp]);
          } else if (resp.match(/^\/\/\s?javascript/)) {
            p = $(el).parents('div.ajax-modal');
            return $(p).html('').dialog('destroy');
          } else {
            div = $(el).parents('div.ajax-modal:first');
            div.html(resp);
            return setTimeout(function() {
              return $(div).transformDateSelect();
            }, 200);
          }
        },
        'error': function(resp) {
          return alert('Existe errores, por favor intente de nuevo.');
        }
      });
      return false;
    });
    $('a.ajax').live("click", function(e) {
      var data, div;
      data = $.extend({
        'title': $(this).attr('title'),
        'ajax-type': getAjaxType(this)
      }, $(this).data());
      div = createDialog(data);
      $(div).load($(this).attr("href"), function(e) {
        return $(div).transformDateSelect();
      });
      e.stopPropagation();
      return false;
    });
    $('a.search').live("click", function() {
      var search;
      search = $(this).attr("href");
      return $(search).show(speed);
    });
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
    updateTemplateRow = function(template, data, macro) {
      var $node, tmp;
      if ($.inArray(macro, ["insertBefore", "insertAfter", "appendTo"]) < 0) {
        macro = "insertAfter";
      }
      if (data['new_record']) {
        $node = $.tmpl(template, data)[macro](this);
      } else {
        $node = $(this).find("#" + data.id);
        tmp = $.tmpl(template, data).insertBefore($node);
        $node.detach();
        $node = tmp;
      }
      $node.mark();
      return $('body').trigger("update:template", [$node, data]);
    };
    $.updateTemplateRow = $.fn.updateTemplateRow = updateTemplateRow;
    $('a.delete[data-remote=true]').live("click", function(e) {
      var conf, el, self, trigger, url;
      self = this;
      $(self).parents("tr:first, li:first").addClass('marked');
      trigger = $(self).data('trigger') || 'ajax:delete';
      conf = $(self).data('confirm') || 'Esta seguro de borrar el item seleccionado';
      if (confirm(conf)) {
        url = $(this).attr('href');
        el = this;
        $.ajax({
          'url': url,
          'type': 'delete',
          'context': el,
          'data': {
            'authenticity_token': csrf_token
          },
          'success': function(resp, status, xhr) {
            var error;
            if (typeof resp === "object") {
              if (resp.destroyed || resp.success) {
                $(el).parents("tr:first, li:first").remove();
                return $('body').trigger(trigger, [resp, url]);
              } else {
                $(self).parents("tr:first, li:first").removeClass('marked');
                error = resp.errors || "";
                return alert("Error no se pudo borrar: " + error);
              }
            } else if (resp.match(/^\/\/\s?javascript/)) {
              return $(self).parents("tr:first, li:first").removeClass('marked');
            } else {
              return alert('Existio un error al borrar');
            }
          },
          'error': function() {
            $(self).parents("tr:first, li:first").removeClass('marked');
            return alert('Existio un error al borrar');
          }
        });
      } else {
        $(this).parents("tr:first, li:first").removeClass('marked');
        e.stopPropagation();
      }
      return false;
    });
    $('#links a.delete').live('click', function() {
      var form, html, txt;
      txt = $(this).data("confirm") || "Esta seguro de borrar";
      if (!confirm(txt)) {
        return false;
      } else {
        html = "<input type='hidden' name='utf-8' value='&#x2713;' />";
        html += "<input type='hidden' name='authenticity_token' value='" + csrf_token + "' />";
        html += "<input type='hidden' name='_method' value='delete' />";
        form = $('<form/>').attr({
          'method': 'post',
          'action': $(this).attr('href')
        }).html(html).appendTo('body').submit();
        return false;
      }
    });
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
    $('[data-new_url]').each(function(i, el) {
      var $a, data, title;
      data = $(el).data();
      title = data.title || "Nuevo";
      $a = $('<a/>').attr({
        'href': data.new_url,
        'class': 'ajax add icon',
        'data-trigger': data.trigger
      });
      $a.insertAfter(el);
      return setTimeout(function() {
        return $a.attr('title', title);
      }, 100);
    });
    $('a.close').live('click', function() {
      var self;
      self = this;
      $(this).parents('div:first').hide(speed);
      if (!$(this).parents("div:first").hasClass("search")) {
        return setTimeout(function() {
          return self.remove();
        }, speed);
      }
    });
    createSelectOption = function(value, label) {
      var opt;
      opt = "<option selected='selected' value='" + value + "'>" + label + "</option>";
      return $(this).append(opt).val(value).mark();
    };
    $.createSelectOption = $.fn.createSelectOption = createSelectOption;
    start = function() {
      return $('body').transformDateSelect();
    };
    createErrorLog = function(data) {
      if (!($('#error-log').length > 0)) {
        $('<div id="error-log" style="background: #FFF"></div>').dialog({
          title: 'Error',
          width: 900,
          height: 500
        });
      }
      return $('#error-log').html(data).dialog("open");
    };
    createMessageCont = function(text, options) {
      return "<div class='message'><span class='close'></span><p>" + text + "</p></div>";
    };
    window.createMessageCont = createMessageCont;
    $('.message .close').live("click", function() {
      return $(this).parents(".message:first").hide("slow").delay(500).remove();
    });
    $('a.more_info').live('click', function() {
      if ($(this).html() === "Ver información") {
        $(this).html("Ocultar información");
        $($(this).attr('href')).show("slow");
      } else {
        $(this).html("Ver información");
        $($(this).attr('href')).hide("slow");
      }
      return false;
    });
    $.ajaxSetup({
      beforeSend: function(xhr) {},
      error: function(event) {},
      complete: function(event) {
        if ($.inArray(event.status, [404, 422, 500]) >= 0) {
          return createErrorLog(event.responseText);
        }
      },
      success: function(event) {}
    });
    $('.tip').tooltip({
      offset: [-3, 10],
      events: {
        def: "mouseover,mouseout",
        input: "focus,blur",
        widget: "focus mouseover,blur mouseout",
        tooltip: ""
      }
    });
    return start();
  });
}).call(this);
