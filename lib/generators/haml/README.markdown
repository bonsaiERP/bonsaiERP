# Information about this fork

This for is no longer following the normal scaffolding layout of Rails.
It uses I18n backend for headings, model attributes names etc in it's views.

## Rails 3 HAML Scaffold Generator

Essentially just a copy of the Rails 3 ERB generator with HAML replacements for the templates.

Original idea from [Paul Barry's article on custom genrators][OriginalIdea]

### Installation

1. Generate your new rails application:

        rails ApplicationName
        cd ApplicationName

2. Edit "Gemfile" and add "gem haml" to the gem list
3. Either

        gem install haml

    ...or...

        bundle install

4. Run

        haml --rails .
        
5. Edit config/application.rb and add the following:

        config.generators do |g|
            g.template_engine :haml
        end


6. Either 

        git clone git://github.com/psynix/rails3_haml_scaffold_generator.git lib/generators/haml

    ...or...

        git submodule add git://github.com/psynix/rails3_haml_scaffold_generator.git lib/generators/haml
  
7. Create stuff with:

        rails generate controller ControllerName index
        rails generate mailer ExamplesNotifications
        rails generate scaffold FancyModel
    
    ... or if you like to mix it up with ERB, ignore step 5 and use ...

        rails generate haml:controller ControllerName index
        rails generate haml:mailer ExamplesNotifications
        rails generate haml:scaffold FancyModel

## TODO

* Gemify (?)

[OriginalIdea]: http://paulbarry.com/articles/2010/01/13/customizing-generators-in-rails-3
