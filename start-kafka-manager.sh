#!/bin/sh

if [[ $KM_USERNAME != ''  && $KM_PASSWORD != '' ]]; then
    sed -i.bak '/^basicAuthentication/d' /kafka-manager/conf/application.conf
    echo 'basicAuthentication.enabled=true' >> /kafka-manager/conf/application.conf
    echo "basicAuthentication.username=${KM_USERNAME}" >> /kafka-manager/conf/application.conf
    echo "basicAuthentication.password=${KM_PASSWORD}" >> /kafka-manager/conf/application.conf
    echo 'basicAuthentication.realm="Kafka-Manager"' >> /kafka-manager/conf/application.conf
fi

exec ./bin/kafka-manager -Dconfig.file=${KM_CONFIGFILE} "${KM_ARGS}" "${@}"
