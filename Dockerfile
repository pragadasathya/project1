FROM maven AS buildstage
RUN mkdir /opt/myfork12
WORKDIR /opt/myfork12
COPY . .
RUN mvn clean install

FROM tomcat
WORKDIR webapps
COPY --from=buildstage /opt/myfork12/target/*.war .
RUN rm -rf ROOT && mv *.war ROOT.war
EXPOSE 8080
