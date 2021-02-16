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

ENV JAVA_HOME /usr/lib/jvm/java

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

USER $WILDFLY_USER

EXPOSE 8080
EXPOSE 9990

CMD ["sh", "-c", "$WILDFLY_HOME/bin/add-user.sh -u $MNGMT_USER -p $MNGMT_PASSWORD -s -e && $WILDFLY_HOME/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0"]