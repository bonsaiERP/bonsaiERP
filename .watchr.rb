def run_spec(file)
  unless File.exist?(file)
    puts "#{file} does not exist"
    return
  end

  puts "Running #{file}"
  system "bundle exec rspec #{file}"
  puts
end

watch("spec/.*/*_spec\.rb") do |match|
  run_spec match[0]
end

watch("app/(.*/.*)\.rb") do |match|
  run_spec %{spec/#{match[1]}_spec.rb}
end

watch("lib/pay_plans_module.rb") do
  run_spec %{spec/models/transaction_spec.rb}
end

watch("app/assets/twitter-bootstrap/(.*)\.less") do |match|
  system("lessc app/assets/twitter-bootstrap/bootstrap.less > app/assets/stylesheets/twitter-bootstrap.css.scss")
  puts "Compiling less files"
end
