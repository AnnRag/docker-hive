FROM ubuntu:18.04

# Install openjdk-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get clean;

# Setup JAVA_HOME and JAVA_OPTIONS
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

RUN apt-get update && \
    apt-get install -y wget && \
    apt-get clean;

# Install hadoop-3.1.4
RUN wget --no-verbose https://apache-mirror.rbc.ru/pub/apache/hadoop/common/hadoop-3.1.4/hadoop-3.1.4.tar.gz && \
    tar -xvzf hadoop-3.1.4.tar.gz && \
    mv hadoop-3.1.4 hadoop && \
    rm hadoop-3.1.4.tar.gz;

# Install hive-3.1.2
RUN wget --no-verbose https://apache-mirror.rbc.ru/pub/apache/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz && \
    tar -xvzf apache-hive-3.1.2-bin.tar.gz && \
    mv apache-hive-3.1.2-bin hive && \
    rm apache-hive-3.1.2-bin.tar.gz;

# replace guava versions - issue: https://issues.apache.org/jira/browse/HIVE-22915
RUN rm hive/lib/guava-19.0.jar
RUN wget https://repo1.maven.org/maven2/com/google/guava/guava/29.0-jre/guava-29.0-jre.jar
RUN mv guava-29.0-jre.jar hive/lib/

# Setup hadoop
ENV HADOOP_HOME=/hadoop
ENV PATH="${HADOOP_HOME}/bin:${PATH}"
COPY hadoop/* /hadoop/etc/hadoop/
ENV HDFS_NAMENODE_USER="root"
ENV HDFS_DATANODE_USER="root"
ENV HDFS_SECONDARYNAMENODE_USER="root"

# Setup hive
ENV HIVE_HOME=/hive
ENV PATH="${HIVE_HOME}/bin:${PATH}"
ENV HIVE_CONF_DIR=$HIVE_HOME/conf
#COPY config/*.xml $HIVE_HOME/conf/

RUN apt-get purge openssh-server && \
    apt-get install -y openssh-server && \
    apt-get install -y openssh-client
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys
RUN echo "\nHost *\n" >> ~/.ssh/config && \
    echo "   StrictHostKeyChecking no\n" >> ~/.ssh/config && \
    echo "   UserKnownHostsFile=/dev/null\n" >> ~/.ssh/config

RUN /hadoop/bin/hdfs namenode -format

# https://cwiki.apache.org/confluence/display/Hive/GettingStarted#GettingStarted-RunningHiveServer2andBeeline.1
RUN schematool -dbType derby -initSchema
CMD service ssh start  && /hadoop/sbin/start-dfs.sh && hiveserver2