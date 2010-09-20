More is the LESS plugin for Rails.

Automatically parses `.less` files from `app/stylesheets` through LESS
and outputs CSS to `public/stylesheets`.

Ignores partials (prefixed with underscore: `_partial.less`) - these can be included with `@import` in your LESS files.

### LESS ?
[LESS](http://lesscss.org) extends CSS with: variables, mixins, operations and nested rules.

Installation
============
Install LESS
    gem install less

Then install more as plugin
    script/plugin install git://github.com/cloudhead/more.git

or as submodule:
    git submodule add git://github.com/cloudhead/more.git vendor/plugins/more
    script/runner vendor/plugins/more/install.rb


Usage
=====
Whenever a controller action is called in development more checks if any '.less' files changed and converts them to '.css'.  
Any `.css` file placed in `app/stylesheets` will be copied into `public/stylesheets` without being parsed through LESS.

    app/stylesheets/foo.less      --> public/stylesheets/foo.css
    app/stylesheets/foo/bar.less  --> public/stylesheets/foo/bar.css
    app/stylesheets/bar.css       --> public/stylesheets/bar.css

**Add the generated css to version control** or run `rake more:generate` after each deploy.

### Partials
If you prefix a file with an underscore, it is considered to be a partial, and will not be parsed unless included in another file. Example:

	<file: app/stylesheets/clients/partials/_form.less>
	@text_dark: #222;
	
	<file: app/stylesheets/clients/screen.less>
	@import "partials/_form";
	
	input { color: @text_dark; }

The example above will result in a single CSS file in `public/stylesheets/clients/screen.css`.

Configuration
=============

Add this to `config/environment.rb` if you do not like the defaults.

Source path: the location of your LESS files (default: app/stylesheets)

	Less::More.source_path = "public/stylesheets/less"
	
Destination Path: where the css goes (public/#{destination_path}) (default: stylesheets)

	Less::More.destination_path = "css"

Compress generated files by removing extra line breaks (default: true)

	Less::More.compression = false

Insert a 'Do not modify this is generated' header into generated files. (default: true)

	Less::More.header = false

Rake Tasks
=====

Parse all LESS files and save the resulting CSS files to the destination path:

	$ rake more:generate

Delete all generated CSS files:

	$ rake more:clean

This task will not delete any CSS files from the destination path, that does not have a corresponding LESS file in the source path.

Upgrading from less-for-rails
=============================
Move your `.less` files to `app/stylesheets` or set `Less::More.source_path = Rails.root + "/public/stylesheets"`.

Doumentation
============
[More RDoc documentation](http://rdoc.info/projects/cloudhead/more)


Contributors
============
* August Lilleaas ([http://github.com/augustl](http://github.com/augustl))
* Logan Raarup ([http://github.com/logandk](http://github.com/logandk))
* Michael Grosser ([http://github.com/grosser](http://github.com/grosser))

LESS is maintained by Alexis Sellier [http://github.com/cloudhead](http://github.com/cloudhead)
