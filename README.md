# Make HTML
> Generate the bench website https://coq-bench.github.io/.

[![website screenshot](https://github.com/coq-bench/make-html/raw/master/pictures/website_screenshot.png)](https://coq-bench.github.io/)

## Generate the HTML
Install Ruby and download the benchmarks database to `../database/`:

    curl -L https://github.com/coq-bench/database/archive/master.tar.gz |tar -xz
    mv database-master ../database

Generate the HTML files to `html/`:

    make

View the generated HTML on [localhost:8080](http://localhost:8080/):

    make serve

## Post on Gitter
[![Gitter screenshot](https://github.com/coq-bench/make-html/raw/master/pictures/gitter_screenshot.png)](https://gitter.im/coq/opam-bench-reports)

To send a summary of the results of the last bench iterations in the past `nb_hours` hours to a Gitter room (like in [coq/opam-bench-reports](https://gitter.im/coq/opam-bench-reports)):

    sudo gem install ruby-gitter
    ruby push_to_gitter.rb database_path token_path room_name nb_hours
