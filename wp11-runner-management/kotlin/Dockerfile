FROM openjdk:17.0.2-jdk-slim-buster
LABEL MAINTAINER=p3_dde_devops@p3-group.com
ENV JAVA_SETTINGS=""
RUN apt-get update && apt-get -y upgrade && apt-get -y install wget && apt-get -y install curl
RUN groupadd -r app -g 1000 && useradd -u 1000 -r -g app -m -d /web-app -s /sbin/nologin -c "App user" app && \
    chmod 755 /web-app
RUN rm -rf /var/lib/apt/lists/*
WORKDIR /web-app
COPY build/libs/demo-0.0.1-SNAPSHOT.jar demo-0.0.1-SNAPSHOT.jar
EXPOSE 8080
USER app
CMD java $JAVA_SETTINGS -Dserver.port=8080  -jar demo-0.0.1-SNAPSHOT.jar