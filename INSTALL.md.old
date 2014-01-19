# Bonsai installation with passenger on Ubuntu, Linux-Mint

    sudo apt-get update
    sudo apt-get upgrade

## Instaling Ruby (RVM)
Install the following

    sudo apt-get install curl git-core

And install rvm

    bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
    source /home/bonsai/.rvm/scripts/rvm

Add the following to the ~/.bashrc

    if [[ -n "$PS1" ]]; then
      if [[ -s $HOME/.rvm/scripts/rvm ]] ; then source $HOME/.rvm/scripts/rvm ; fi
    fi

And then install all needed dependencies for Ruby 1.9 MRI

    sudo apt-get install build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake

Install first ruby 2.0.0

    rvm install ruby-2.0.0
    rvm ruby-2.0.0


Create a gemset and set it as default

    rvm ruby-2.0.0
    rvm gemset create rails4.0
    rvm ruby-2.0.0@rails4.0 --default

## Locales if needed

    sudo apt-get install language-pack-en-base
    sudo locale-gen en_US.UTF-8
    sudo dpkg-reconfigure locales

### In case that this can't be set

Go to /etc/environment and add this

    LANG="en_US.UTF-8"
    LANGUAGE="en_US.UTF-8"
    LC_ALL="en_US.UTF-8"

## Database installation
Install **PostgreSQL 9.2**

    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install python-software-properties
    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:pitti/postgresql
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install postgresql-9.2 libpq-dev postgresql-contrib-9.2

To upgrate
`sudo apt-get update`
`sudo apt-get --only-upgrade install postgresql-9.2 postgresql-client-9.2`

### Create a user for the database

    sudo -u postgres createuser --superuser $USER
    sudo -u postgres psql postgres

### Inside postgreSQL

    postgres=# \passsword <user>

Edit `/etc/postgresql/9.2/main/postgresql.conf` and check that you have:

    listen_addresses = 'localhost'

Restart the database `sudo /etc/init.d/postgresql restart`

## Install node.js for Ubuntu

    sudo apt-get install python-software-properties
    sudo add-apt-repository ppa:chris-lea/node.js
    sudo apt-get update
    sudo apt-get install nodejs

## Install apache and mod_xsendfile

    sudo apt-get install libapache2-mod-xsendfile

Edit the file for in /etc/apache2/sites-enabled/bonsaierp.com and add
these lines

    XSendFile On
    XSendFilePath /tmp

## Bonsai installation
Now you need to download and install bonsai cloning from the repository, this creates the bonsai folder

    git clone [bonsaiRepo]

Go to the bonsai folder `cd bonsai` and then run. (*by default the branch used is master you can go to any branch with* `git checkout origin/dev -b dev`)

    bundle

**Create a file in your  `config/app_environment_variables.rb` and put
your env variables**

- ENV['SECRET_TOKEN']
- ENV['MANDRILL_API_KEY']


**Create the file `config/database.yml` in bonsai directory add this:**


    development:
      adapter: postgresql
      encoding: unicode
      database: bonsai_dev
      username: USER
      password: PASS
      host: localhost
      pool: 5

    test:
      adapter: postgresql
      encoding: unicode
      database: bonsai_test
      username: USER
      password: PASS
      host: localhost
      pool: 5

    production:
      adapter: postgresql
      encoding: unicode
      database: bonsai_prod
      username: USER
      password: PASS
      host: localhost
      pool: 5

Run the database setup with

    rake db:setup RAILS_ENV=production
    rake bonsai:create_data RAILS_ENV=production

Once installed we have to install passenger

## Passenger installation

    gem install passenger

Installs the passenger gem and now we need to install passenger module for nginx with the defaults

    rvmsudo passenger-install-nginx-module

with **apache** use the `apache2-prefork-dev` to install development
heders

If it asks you to install any dependencies install them, and we have to create a group and user for nginx

    sudo adduser --system --no-create-home --disabled-login --disabled-password --group nginx

Open the file with and editor in this case VIM

    sudo vim /etc/init.d/nginx

And add the following

    #! /bin/sh

    ### BEGIN INIT INFO
    # Provides:          nginx
    # Required-Start:    $all
    # Required-Stop:     $all
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: starts the nginx web server
    # Description:       starts nginx using start-stop-daemon
    ### END INIT INFO

    PATH=/opt/nginx/sbin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
    DAEMON=/opt/nginx/sbin/nginx
    NAME=nginx
    DESC=nginx

    test -x $DAEMON || exit 0

    # Include nginx defaults if available
    if [ -f /etc/default/nginx ] ; then
        . /etc/default/nginx
    fi

    set -e

    . /lib/lsb/init-functions

    case "$1" in
      start)
        echo -n "Starting $DESC: "
        start-stop-daemon --start --quiet --pidfile /opt/nginx/logs/$NAME.pid \
            --exec $DAEMON -- $DAEMON_OPTS || true
        echo "$NAME."
        ;;
      stop)
        echo -n "Stopping $DESC: "
        start-stop-daemon --stop --quiet --pidfile /opt/nginx/logs/$NAME.pid \
            --exec $DAEMON || true
        echo "$NAME."
        ;;
      restart|force-reload)
        echo -n "Restarting $DESC: "
        start-stop-daemon --stop --quiet --pidfile \
            /opt/nginx/logs/$NAME.pid --exec $DAEMON || true
        sleep 1
        start-stop-daemon --start --quiet --pidfile \
            /opt/nginx/logs/$NAME.pid --exec $DAEMON -- $DAEMON_OPTS || true
        echo "$NAME."
        ;;
      reload)
          echo -n "Reloading $DESC configuration: "
          start-stop-daemon --stop --signal HUP --quiet --pidfile /opt/nginx/logs/$NAME.pid \
              --exec $DAEMON || true
          echo "$NAME."
          ;;
      status)
          status_of_proc -p /opt/nginx/logs/$NAME.pid "$DAEMON" nginx && exit 0 || exit $?
          ;;
      *)
        N=/etc/init.d/$NAME
        echo "Usage: $N {start|stop|restart|reload|force-reload|status}" >&2
        exit 1
        ;;
    esac

    exit 0

Change permissions and make it executable

    sudo chmod +x /etc/init.d/nginx

Make it a service

    sudo /usr/sbin/update-rc.d -f nginx defaults

Start there server

    sudo /etc/init.d/nginx start

sudo update-rc.d nginx defaults
sudo update-rc.d nginx remove
sudo update-rc.d nginx start|stop
sudo update-rc.d nginx disable|enable

