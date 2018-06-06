FROM centos:7 as dist

MAINTAINER Z <nggiang12@gmail.com>

RUN curl https://bintray.com/sbt/rpm/rpm | tee /etc/yum.repos.d/bintray-sbt-rpm.repo && \
    yum update -y && \
    yum install -y java-1.8.0-openjdk-headless wget sbt which && \
    yum clean all

ENV KM_VERSION=1.3.3.14 \
    KM_REVISION=5de818f330365fc3cd835b8227875ad12f29ed15

RUN mkdir -p /tmp /src && wget -nv https://github.com/yahoo/kafka-manager/archive/$KM_VERSION.tar.gz -O /tmp/kafka-manager.tar.gz\
  && tar -xf /tmp/kafka-manager.tar.gz -C /src && cd /src/kafka-manager-$KM_VERSION \
  && echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt\
  && ./sbt update && ./sbt dist

## run env
FROM centos:7 as kafka-manager

ENV JAVA_HOME=/usr/java/default/ \
    ZK_HOSTS=localhost:2181 \
    KM_VERSION=1.3.3.14 \
    KM_REVISION=5de818f330365fc3cd835b8227875ad12f29ed15 \
    KM_CONFIGFILE="/kafka-manager/conf/application.conf"

RUN yum update -y && \
    yum install -y java-1.8.0-openjdk-headless unzip && \
    yum clean all

RUN mkdir /kafka-manager

COPY --from=dist /src/kafka-manager-$KM_VERSION/target/universal/kafka-manager-$KM_VERSION.zip /tmp

# unload the dist
RUN unzip -d /tmp /tmp/kafka-manager-$KM_VERSION.zip && mv /tmp/kafka-manager-$KM_VERSION/* /kafka-manager/ \
 && rm -rf /tmp/kafka-manager* && rm -rf /kafka-manager/share/doc

# add starting wrapper
ADD start-kafka-manager /kafka-manager/bin/start-kafka-manager
# ADD application.conf /kafka-manager/conf/
# ADD logback.xml /kafka-manager/conf/

Run chmod +x /kafka-manager/bin/ && \
    mv /kafka-manager/bin/ /usr/bin/ && \
    env >> "env.lock"

WORKDIR /kafka-manager

EXPOSE 9000

ENTRYPOINT ["start-kafka-manager"]
