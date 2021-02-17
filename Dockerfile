FROM centos:7.9.2009

LABEL maintener.name="Diego Augusto da Silva"
LABEL maintener.contact="augusto.dev.di@gmail.com"
LABEL maintener.message="This image is for didatic purposes only"

ENV WILDFLY_USER wildfly
ENV WILDFLY_GROUP $WILDFLY_USER
ENV WILDFLY_HOME /opt/$WILDFLY_USER
ENV WILDFLY_VERSION 22.0.1.Final
ENV WILDFLY_SHA1 624bd3ca7e66accf5494028f5ebabcb119339803

RUN yum update -y 
RUN yum install -y xmlstarlet saxon bsdtar unzip augeas java-11-openjdk-devel 
RUN yum clean all

RUN curl -L https://github.com/TravaOpenJDK/trava-jdk-11-dcevm/releases/download/dcevm-11.0.10%2B3/java11-openjdk-dcevm-linux.tar.gz -o $HOME/java11-openjdk-dcevm-linux.tar.gz
RUN tar -xvzf $HOME/java11-openjdk-dcevm-linux.tar.gz -C /usr/lib/jvm/

ENV JAVA_HOME /usr/lib/jvm/dcevm-11.0.10+3

RUN mkdir -p $JAVA_HOME/lib/dcevm && cp $JAVA_HOME/lib/server/libjvm.so $JAVA_HOME/lib/dcevm/
RUN rm $HOME/java11-openjdk-dcevm-linux.tar.gz

RUN groupadd -r $WILDFLY_GROUP -g 1000 
RUN useradd -u 1000 -r -g $WILDFLY_GROUP -m -d /dev/null -s /sbin/nologin -c "Wildfly User" $WILDFLY_USER

RUN curl -L https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz -o $HOME/wildfly-$WILDFLY_VERSION.tar.gz 
RUN sha1sum $HOME/wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 
RUN tar xvzf $HOME/wildfly-$WILDFLY_VERSION.tar.gz -C /opt
RUN rm $HOME/wildfly-$WILDFLY_VERSION.tar.gz 
RUN ln -s /opt/wildfly-$WILDFLY_VERSION $WILDFLY_HOME
RUN chown -R wildfly:0 $WILDFLY_HOME 
RUN chmod -R g+rw $WILDFLY_HOME 
RUN chgrp -R wildfly $WILDFLY_HOME

ENV LAUNCH_JBOSS_IN_BACKGROUND true
ENV JAVA_OPTS "-Xms512m -Xmx1024m -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m -XXaltjvm=dcevm -javaagent:/opt/wildfly/hotswap-agent-1.4.1.jar"

ADD start.sh $WILDFLY_HOME/

RUN chown $WILDFLY_USER $WILDFLY_HOME/start.sh
RUN chgrp $WILDFLY_GROUP $WILDFLY_HOME/start.sh
RUN chmod 775 $WILDFLY_HOME/start.sh

USER $WILDFLY_USER

RUN curl -L https://github.com/HotswapProjects/HotswapAgent/releases/download/RELEASE-1.4.1/hotswap-agent-1.4.1.jar -o $WILDFLY_HOME/hotswap-agent-1.4.1.jar

EXPOSE 8080
EXPOSE 9990

CMD ["sh", "-c", "/opt/wildfly/start.sh"]