# Make HTML
Generate the website.

## Usage
Install Ruby and download the benchmarks database to `../database/`:

    curl -L https://github.com/coq-bench/database/archive/master.tar.gz |tar -xz
    mv database-master ../database

Generate the HTML files to `html/`:

    make

View the generated HTML on [localhost:8080](http://localhost:8080/):

    make server
