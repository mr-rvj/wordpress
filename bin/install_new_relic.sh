#!/bin/bash

export NR_KEY=$(jq -r '.new_relic_key' /secrets/credentials.json)
export NR_APP_NAME=$(jq -r '.new_relic_key' /secrets/credentials.json)

# The installation will not happen unless the credentials and ENV variables are set
if [ $NR_KEY ] && [ $NR_APP_NAME ] && [ $NR_PHP_AGENT_URL ]
then
    curl -L ${NR_PHP_AGENT_URL} | tar -C /tmp -zx

    export NR_INSTALL_USE_CP_NOT_LN=1
    export NR_INSTALL_SILENT=1

    /tmp/newrelic-php5-*/newrelic-install install

    rm -rf /tmp/newrelic-php5-* /tmp/nrinstall*

    sed -i -e "s/\"REPLACE_WITH_REAL_KEY\"/\"${NR_KEY}\"/" \
        -e "s/newrelic.appname = \"PHP Application\"/newrelic.appname = \"${NR_APP_NAME}\"/" \
        -e 's/;newrelic.daemon.app_connect_timeout =.*/newrelic.daemon.app_connect_timeout=15s/' \
        -e 's/;newrelic.daemon.start_timeout =.*/newrelic.daemon.start_timeout=5s/' \
        /etc/php/8.1/fpm/conf.d/newrelic.ini
fi
