FROM php:7.3

RUN set -eux; \
    apt-get update -y; \
    apt-get install -y wget apt-transport-https gnupg2; \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -; \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list; \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list; \
    curl -sL https://deb.nodesource.com/setup_12.x | bash -; \
    apt-get update -y; \
    apt-get install -y git zip libmcrypt-dev libcurl4-gnutls-dev libicu-dev libzip-dev \
                       libfreetype6-dev libjpeg-dev libpng-dev libxml2-dev \
                       libbz2-dev libc-client-dev libkrb5-dev \ 
                       nodejs yarn google-chrome-stable; \				   
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/;  \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
    docker-php-ext-install mbstring curl json intl gd xml zip bz2 opcache pdo_mysql pcntl imap exif bcmath;\
	pecl install xdebug; \
    echo "date.timezone = UTC" > /usr/local/etc/php/conf.d/timezone.ini; \
    echo "memory_limit = -1" > /usr/local/etc/php/conf.d/memory.ini; \
	EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"; \
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
	ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"; \
	if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then \
		>&2 echo 'ERROR: Invalid installer signature'; \ 
		rm composer-setup.php; \
		exit 1; \
	fi; \
	php composer-setup.php --install-dir=bin --filename=composer --quiet; \
	rm composer-setup.php; \
    wget https://chromedriver.storage.googleapis.com/2.42/chromedriver_linux64.zip -O /tmp/chromedriver.zip; \
    echo unzip; \
    unzip /tmp/chromedriver.zip -d /usr/local/bin; \
    apt-get autoclean -y; \
    apt-get --purge autoremove -y; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    php -i;

