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

## Bonsai installation
Now you need to download and install bonsai cloning from the repository, this creates the bonsai folder

    git clone [bonsaiRepo]

Go to the bonsai folder **cd bonsai** and then run. -by default the branch used is master- you can go to any branch with -git checkout origin/dev -b dev-

    bundle

And create the file **config/database.yml** in bonsai directory add this

    
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

