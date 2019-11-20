FROM jupyter/minimal-notebook

USER root
# install dependencies 
RUN apt-get update && apt-get install -yq --no-install-recommends \
    php-cli php-dev php-pear \
    pkg-config \
    && apt-get clean
#    rm -rf /var/lib/apt/lists/*

# install zeromq and zmq php extension 
RUN wget https://github.com/zeromq/zeromq4-1/releases/download/v4.1.5/zeromq-4.1.5.tar.gz && \
    tar -xvf zeromq-4.1.5.tar.gz && \
    cd zeromq-* && \
    ./configure && make && make install && \
    printf "\n" | pecl install zmq-beta && \
    echo 'extension=zmq.so' > /etc/php/7.2/cli/conf.d/zmq.ini

# install PHP composer
RUN wget https://getcomposer.org/installer -O composer-setup.php && \
    wget https://litipk.github.io/Jupyter-PHP-Installer/dist/jupyter-php-installer.phar && \
    php composer-setup.php && \
    php ./jupyter-php-installer.phar -vvv install && \
    mv composer.phar /usr/local/bin/composer && \
    rm -rf zeromq-* jupyter-php* && \
    rm composer-setup.php

# Reset user from jupyter/base-notebook
USER $NB_USER

# disable authentication
RUN mkdir -p .jupyter
RUN echo "" >> ~/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.token = ''" >> ~/.jupyter/jupyter_notebook_config.py