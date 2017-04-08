FROM java:8

ENV DEBIAN_FRONTEND=noninteractive \
    PRESTO_HOME=/presto \
    PRESTO_REPO=https://repo1.maven.org/maven2/com/facebook/presto \
    PRESTO_VERSION=0.167 \
    TERADATA_PRESTO_REPO=https://github.com/Teradata/presto \
    TERADATA_PRESTO_VERSION=0.167-t

RUN apt-get -qq update && \
    apt-get -qq install -y python git wget && \
    wget -q ${PRESTO_REPO}/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz \
            ${PRESTO_REPO}/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar \
            ${PRESTO_REPO}/presto-jdbc/${PRESTO_VERSION}/presto-jdbc-${PRESTO_VERSION}.jar \
            ${PRESTO_REPO}/presto-verifier/${PRESTO_VERSION}/presto-verifier-${PRESTO_VERSION}-executable.jar \
            ${PRESTO_REPO}/presto-benchmark-driver/${PRESTO_VERSION}/presto-benchmark-driver-${PRESTO_VERSION}-executable.jar && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x presto-*executable.jar && \
    tar zxf presto-server-${PRESTO_VERSION}.tar.gz && \
    ln -s presto-server-${PRESTO_VERSION} presto && \
    mv *.jar presto/. && \
    cd presto && \
        ln -s presto-cli-${PRESTO_VERSION}-executable.jar presto && \
        ln -s presto-verifier-${PRESTO_VERSION}-executable.jar verifier && \
        ln -s presto-benchmark-driver-${PRESTO_VERSION}-executable.jar benchmark-driver && \
    cd - && \
 		git clone -b release-${TERADATA_PRESTO_VERSION} ${TERADATA_PRESTO_REPO} teradata-presto && \
    cd teradata-presto && \
        ./mvnw package -DskipTests && \
        cp -pR /presto/plugin/mysql/ /presto/plugin/sqlserver && \
        rm /presto/plugin/sqlserver/presto-mysql-0.167.jar \
   		     /presto/plugin/sqlserver/mysql-connector-java-5.1.35.jar && \
        cp /teradata-presto/presto-sqlserver/target/presto-sqlserver-${TERADATA_PRESTO_VERSION}.0.3-SNAPSHOT.jar \
           /presto/plugin/sqlserver/ && \
    cd -

ADD ./sqljdbc42.jar /presto/plugin/sqlserver/
WORKDIR $PRESTO_HOME
VOLUME ["$PRESTO_HOME/etc", "$PRESTO_HOME/data"]
EXPOSE 8080
ENTRYPOINT ["./bin/launcher", "run"]
