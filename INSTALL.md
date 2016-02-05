# Bonsai installation with passenger on Ubuntu 14.04
```
sudo apt-get update
sudo apt-get install git-core curl tmux
sudo a2enmode rewrite
sudo a2enmode headers
sudo a2enmode expires
sudo apt-get install libapache2-mod-upload-progress
sudo apt-get install libapache2-mod-xsendfile
sudo apt-get install imagemagick
sudo apt-get install libgmp-dev
```

## Set ssh
Login to the server and edit `/etc/ssh/sshd_config`

```
Port <ENTER YOUR PORT>
Protocol 2
PermitRootLogin no
```

Then reload ssh
```
sudo reload ssh
```


```
sudo apt-get upgrade
```

## Instaling Ruby (RVM)
Install the following, when running `rvm requirements` will ask password
to install required

```
\curl -sSL https://get.rvm.io | bash -s stable
rvm requirements
```

Install first ruby 2.0.0 and then create gemset

```
rvm install ruby-2.2.3
rvm ruby-2.2.3
rvm gemset create rails-4.2
rvm ruby-2.2.3@rails-4.2 --default
```

## Locales if needed

```
sudo apt-get install language-pack-en-base
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales
```

### In case that this locale can't be set

Go to /etc/environment and add this

```
LANG="en_US.UTF-8"
LANGUAGE="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
```

## Database installation
Install **PostgreSQL 9.4**

Create `/etc/apt/sources.list.d/pgdg.list` and add

```
deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main
```
Then update and install

```
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install postgresql-9.4 libpq-dev postgresql-contrib-9.4
```


To upgrate
`sudo apt-get update`
`sudo apt-get --only-upgrade install postgresql-9.4 postgresql-client-9.4`

### Create a user for the database

```
sudo -u postgres createuser --superuser $USER
sudo -u postgres psql postgres
```

### Inside postgreSQL

```
\passsword <user>
CREATE DATABASE bonsai_prod OWNER <user>
```

Edit `/etc/postgresql/9.4/main/postgresql.conf` and check that you have:

```
listen_addresses = 'localhost'
```

Restart the database `sudo service postgresql restart` and then create
the database `bonsai_prod` login with user **bonsai_data**



## Install node.js, mod_xsendfile apache

```
sudo apt-get install nodejs nodejs-dev
```

## Install phantomjs for PDF generation
Download phantomjs from http://phantomjs.org/, decompress file and put
the `bin/phantomjs` to `/usr/bin`

## Passenger installation
```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo apt-get install apt-transport-https ca-certificates
```

Create a file `/etc/apt/sources.list.d/passenger.list` and insert

```
# 14.04
deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main
# 12.04
deb https://oss-binaries.phusionpassenger.com/apt/passenger precise main
```
Save and then install passenger

```
sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list
sudo apt-get update

sudo apt-get install libapache2-mod-passenger
sudo a2enmod passenger
sudo service apache2 restart
```


## Bonsai installation
Now you need to download and install bonsai cloning from the repository, this creates the bonsai folder

```
git clone git@bitbucket.org:boriscyber/bonsaierp.git
cd bonsaierp
bundle
```

**Create a file in your  `config/app_environment_variables.rb` and put
your env variables**

```
- ENV['SECRET_TOKEN']
- ENV['MANDRILL_API_KEY']
```

**Create the file `config/database.yml` in bonsai directory add this:**

```
development:
  adapter: postgresql
  encoding: unicode
  database: bonsai_prod
  username: bonsai_data
  password: PASS
  host: localhost
  pool: 5

production:
  adapter: postgresql
  encoding: unicode
  database: bonsai_prod
  username: bonsai_data
  password: PASS
  host: localhost
  pool: 5
```

Run the database setup with

```
rake db:setup RAILS_ENV=production
rake bonsai:create_data RAILS_ENV=production
```
