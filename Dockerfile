FROM centos:7

MAINTAINER Z

RUN yum update -y && \
    yum install -y java-1.8.0-openjdk-headless && \
    yum clean all

ENV JAVA_HOME=/usr/java/default/ \
    ZK_HOSTS=localhost:2181 \
    KM_VERSION=1.3.3.17 \
    KM_REVISION=0356db5f2698c36ec676b947c786b8543086dd49 \
    KM_CONFIGFILE="/kafka-manager/conf/application.conf"

ADD start-kafka-manager.sh /kafka-manager-${KM_VERSION}/start-kafka-manager.sh

RUN yum install -y java-1.8.0-openjdk-devel git wget unzip which && \
    mkdir -p /tmp && \
    cd /tmp && \
    git clone https://github.com/yahoo/kafka-manager && \
    cd /tmp/kafka-manager && \
    git checkout ${KM_REVISION} && \
    echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt && \
    ./sbt clean dist && \
    unzip  -d / ./target/universal/kafka-manager-${KM_VERSION}.zip && \
    rm -fr /tmp/* /root/.sbt /root/.ivy2 && \
    chmod +x /kafka-manager-${KM_VERSION}/start-kafka-manager.sh && \
    yum autoremove -y java-1.8.0-openjdk-devel git wget unzip which && \
    yum clean all

Run cp -R /kafka-manager-${KM_VERSION} /kafka-manager && chmod -R 777 /kafka-manager

WORKDIR /kafka-manager

EXPOSE 9000

ENTRYPOINT ["./start-kafka-manager.sh"]
