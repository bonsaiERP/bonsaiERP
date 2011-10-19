# spec/javascripts/support/jasmine_config.rb
# when jasmine starts the server out-of-process, it needs this in order to be able to invoke the asset tasks
unless Object.const_defined?(:Rake)
  require 'rake'
  load File.expand_path('../../../../Rakefile', __FILE__)
end

module Jasmine
  class Config

    def js_files(spec_filter = nil)
      # remove all generated files
      generated_files_directory = File.expand_path("../../generated", __FILE__)
      rm_rf generated_files_directory, :secure => true

      precompile_app_assets
      compile_jasmine_javascripts

      # this is code from the original jasmine config js_files method - you could also just alias_method_chain it
      spec_files_to_include = spec_filter.nil? ? spec_files : match_files(spec_dir, [spec_filter])
      src_files.collect {|f| "/" + f } + helpers.collect {|f| File.join(spec_path, f) } + spec_files_to_include.collect {|f| File.join(spec_path, f) }
    end

    private

    # this method compiles all the same javascript files your app will
    def precompile_app_assets
      puts "Precompiling assets..."

      ENV["RAILS_GROUPS"] ||= "assets"
      ENV["RAILS_ENV"]    ||= "test"

      # make sure the Rails environment is loaded
      ::Rake.application['environment'].invoke

      # Previously, ::Rails.application.assets.static_root was set to
      # a temporary compiled dir. In lieu of sprockets' deprecation of
      # static_root, ::Rails.application.assets.manifest and
      # ::Rails.application.config.assets.prefix are now set to the compiled
      # dir.
      ::Rails.application.config.assets.manifest = "spec/javascripts/generated/assets"
      ::Rails.application.config.assets.prefix = "../spec/javascripts/generated/assets"

      # rake won't let you run the same task twice in the same process without
      # re-enabling it

      # once the assets have been cleared, recompile them into the spec directory
      ::Rake.application['assets:precompile'].reenable
      ::Rake.application['assets:precompile'].invoke
    end

    # this method compiles all of the spec files into js files that jasmine can run
    def compile_jasmine_javascripts
      puts "Compiling jasmine coffee scripts into javascript..."
      root = File.expand_path("../../../../spec/javascripts/coffee", __FILE__)
      destination_dir = File.expand_path("../../generated/specs", __FILE__)

      glob = File.expand_path("**/*.js.coffee", root)

      Dir.glob(glob).each do |srcfile|
        srcfile = Pathname.new(srcfile)
        destfile = srcfile.sub(root, destination_dir).sub(".coffee", "")
        FileUtils.mkdir_p(destfile.dirname)
        File.open(destfile, "w") {|f| f.write(CoffeeScript.compile(File.new(srcfile)))}
      end
    end

  end
end
