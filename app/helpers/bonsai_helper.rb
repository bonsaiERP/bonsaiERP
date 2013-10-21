# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Especial methods created to make easier the development
module BonsaiHelper

  # Creates the links show, edit, destroy
  def bonsai_links(klass, options={})
    ["edit", "destroy"].inject([]) do |t, m|
      t << bonsai_method_path(m, klass)
    end.join(" ").html_safe
  end

  # Set the method and link for  new, edit, destroy, show
  def bonsai_method_path(m, klass)
    k = klass.class.to_s.underscore.pluralize.singularize
    case(m)
      when "new" then link_to "nuevo", send("new_#{k}_path", klass)
      when "show" then link_to "ver", klass, :class => "show_icon", :title => "Ver"
      when "edit" then link_to "editar", send("edit_#{k}_path", klass), :class => "edit", :title => "Editar"
      when "destroy" then link_to "borrar", klass, :method => :delete, :class => "delete", :title => "Borrar", :confirm => 'Esta seguro de borrar el item seleccionado', :remote => true
      else ""
    end
  end

  def error_message(f, method)
    if f.object.errors.messages[method].any?
      content_tag :span, f.object.errors.messages[method].join(', '),class: 'error'
    end
  end

  def field_with_errors(f, method)
    'field_with_errors'  if f.object.errors[method] && f.object.errors[method].any?
  end

  #
  def bonsai_title()
    if params[:action] == "index"
      t("controllers.#{ params[:controller] }.other")
    elsif params[:action] == "show"
      t("controllers.#{ params[:controller] }.one")
    else
      t(params[:action]) + ' ' + t("controllers.#{params[:controller]}.one").downcase
    end
  end

  # Shows the base errors
  # @param [FormBuilder]
  def bonsai_form_error(f)
    unless f.object.errors.empty?
      html = content_tag('h4', 'Exiten errores en el formulario')
      unless f.object.errors[:base].empty?
        html << "<dl>#{ f.object.errors[:base].inject("") { |t, v|  t << "<dd>#{v}</dd>" } }</dl>".html_safe
      end
      "<div class='alert alert-error'>#{ html }</div>".html_safe
    end
  end

  # returns an active value
  def tabs_filter(val)
    params[:option] ||= 'all'
    if val == params[:option]
      "active"
    end
  end

  # returns size "(2)" if the size > 0
  def size_or_blank(size)
    if size > 0
      "(#{size})"
    end
  end
end
