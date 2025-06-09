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

ENV CLASSPATH=/davmail/davmail.jar:/usr/share/java/commons-logging.jar:/usr/share/java/httpclient.jar:/usr/share/java/httpcore.jar:/usr/share/java/jackrabbit-webdav.jar:/usr/share/java/javafx-base.jar:/usr/share/java/javafx-controls.jar:/usr/share/java/javafx-graphics.jar:/usr/share/java/javafx-media.jar:/usr/share/java/javafx-swing.jar:/usr/share/java/javafx-web.jar:/usr/share/java/javax.mail.jar:/usr/share/java/jettison.jar:/usr/share/java/jna.jar:/usr/share/java/log4j-1.2.jar:/usr/share/java/swt4.jar:/usr/share/java/stax2-api.jar:xercesImpl.jar:woodstox-core-asl.jar:commons-codec.jar:htmlcleaner.jar:jdom2.jar:jcifs.jar
ENV SWT_GTK3=0

EXPOSE 1110 1025 1143 1080 1389

CMD ["java", "-Xmx512M", "-Dsun.net.inetaddr.ttl=60", "davmail.DavGateway", "/davmail.properties"]
