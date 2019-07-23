# Make HTML
Generate the website.

## Usage
Install Ruby and download the benchmarks database to `../database/`:

    curl -L https://github.com/coq-bench/database/archive/master.tar.gz |tar -xz
    mv database-master ../database

Generate the HTML files to `html/`:

    make

View the generated HTML on [localhost:8080](http://localhost:8080/):

    make serve

## Connect to Gitter
To send a summary of the results of the last bench iteration to a Gitter room:

    sudo gem install ruby-gitter
    ruby push_to_gitter.rb database_path token_path room_name
