# *bonsaiERP*

*bonsaiERP* is a simple ERP system written with [Ruby on Rails](http://rubyonrails.org), and includes the following modules:

- Sales
- Buys
- Expenses
- Bank and Cash Accounts
- Inventory
- File management (in development)

The system allows to use multiple currencies and make exchange rates.

## Installation

### bonsaiERP requires

- Ruby 2.2.2
- PostgreSQL 9.4 and postgresql-contrib to enable **hstore**
- Nodejs for compiling assets
- imagemagick

### Installing *bonsaiERP*



### Attached files (UPLOADS)

*bonsaiERP* uses dragonfly gem to manage file uploads, you can set where
the files will go setting:

`config/initialiazers/dragonfly.rb`
