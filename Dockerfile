FROM debian:12 AS base
RUN apt-get update


# First we build the jar file
FROM base AS builder
WORKDIR /davmail

RUN apt-get install -y ant git
RUN git clone https://github.com/mguessan/davmail .
RUN git checkout trunk
RUN ant -Dfile.encoding=UTF-8


# Then we run the jar file
FROM base AS runner
WORKDIR /davmail

RUN apt-get install -y openjdk-17-jre libcommons-codec-java libcommons-logging-java libhtmlcleaner-java libhttpclient-java libjackrabbit-java libjcifs-java libjettison-java libjna-java liblog4j1.2-java libmail-java libopenjfx-java  libservlet-api-java libslf4j-java libstax2-api-java libswt-cairo-gtk-4-jni libswt-gtk-4-java libwoodstox-java

# Copy jar file and default davmail.properties
COPY --from=builder /davmail/dist/davmail.jar /davmail/davmail.jar
COPY --from=builder /davmail/src/etc/davmail.properties /davmail.properties
COPY entrypoint.sh /entrypoint.sh

EXPOSE 1110 1025 1143 1080 1389

VOLUME [ "/davmail.properties" ]
VOLUME [ "/.env.oauth" ]
ENTRYPOINT [ "/entrypoint.sh" ]
