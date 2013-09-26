# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(sass|css|js|html|coffee))).*}) { |m| "/assets/#{m[3]}" }
  watch(%r{(spec)(/javascripts/\w+/(.+\.(sass|css|js|html|coffee))).*}) { |m| "/assets/#{m[3]}" }
end
