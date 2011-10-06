# Bonsai installation with passenger on Linux (Ubuntu-Mint)

## Instaling Ruby (RVM)
Install the following

    sudo apt-get install curl git-core

And install rvm

    bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)

Add the following to the ~/.bashrc
    
    if [[ -n "$PS1" ]]; then
      if [[ -s $HOME/.rvm/scripts/rvm ]] ; then source $HOME/.rvm/scripts/rvm ; fi
    fi

And then install all needed dependencies for Ruby 1.9 MRI

    sudo apt-get install build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake

Install first ruby 1.8.7 needed for 1.9.2

    rvm install ruby-1.8.7
    rvm ruby-1.8.7

Install Ruby 1.9

    rvm install ruby-1.9.2

Create a gemset and set it as default

    rvm ruby-1.9.2
    rvm gemset create rails3.1
    rvm ruby-1.9.2@rails3.1 --default

## Database installation
Install **MySQL**
    
    sudo apt-get install mysql-server libmysqld-dev

## Bonsai installation
Now you need to download and install bonsai cloning from the repository, this creates the bonsai folder

    git clone [bonsaiRepo]

Go to the bonsai folder **cd bonsai** and then run. (*by default the branch used is master you can go to any branch with -git checkout origin/dev -b dev*)

    bundle

Create the file **config/database.yml** in bonsai directory add this:

    
    development:
      adapter: mysql2
      encoding: utf8
      database: bonsai_dev
      username: USER
      password: PASSWORD
      host: localhost
      pool: 5

    test:
      adapter: mysql2
      encoding: utf8
      database: bonsai_test
      username: USER
      password: PASSWORD
      host: localhost
      pool: 5

    production:
      adapter: mysql2
      encoding: utf8
      database: bonsai_dev
      username: USER
      password: PASSWORD
      host: localhost
      pool: 5

Run the database setup with 

    rake db:setup

Once installed we have to install passenger

## Passenger installation
        
    gem install passenger

Installs the passenger gem and now we need to install passenger module for nginx with the defaults

    rvmsudo passenger-install-nginx-module

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
