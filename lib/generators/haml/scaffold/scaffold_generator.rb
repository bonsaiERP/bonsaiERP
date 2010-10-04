require 'generators/haml/base.rb'
require 'rails/generators/resource_helpers'

module Haml
  module Generators
    class ScaffoldGenerator < Haml::Generators::Base
      include Rails::Generators::ResourceHelpers

      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      class_option :layout,    :type => :boolean
      class_option :singleton, :type => :boolean, :desc => "Supply to skip index view"

      def create_root_folder
        empty_directory File.join("app/views", controller_file_path)
      end

      def copy_index_file
        return if options[:singleton]
        copy_view :index
      end

      def copy_edit_file
        copy_view :edit
      end

      def copy_show_file
        copy_view :show
      end

      def copy_new_file
        copy_view :new
      end

      def copy_form_file
        copy_view :_form
      end

      def copy_layout_file
        return unless options[:layout]
        template "layout.html.haml", File.join("app/views/layouts", controller_class_path, "#{controller_file_name}.html.haml")
      end

      protected
        def copy_view(view)
          template "#{view}.html.haml", File.join("app/views", controller_file_path, "#{view}.html.haml")
        end
    end
  end
end
