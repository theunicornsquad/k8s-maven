FROM centos:centos7 as build

ENV GRAAL_VERSION=19.3.1
ARG MAVEN_VERSION=3.6.2
ENV GRAALVM_HOME /opt/graalvm

RUN yum update -y && \
  yum install -y which git sudo && \
  yum clean all

ENV GRAAL_CE_URL=https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${GRAAL_VERSION}/graalvm-ce-java8-linux-amd64-${GRAAL_VERSION}.tar.gz
ENV MAVEN_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz

RUN yum -y install gcc zlib-devel libc6-dev zlib1g-dev curl git nano upx-ucl gzip

# All in one step, to reduce number of layers
RUN curl ${MAVEN_URL} -o /tmp/maven.tar.gz && \
    tar -zxf /tmp/maven.tar.gz -C /tmp && \
    mv /tmp/apache-maven-${MAVEN_VERSION} /opt/apache-maven && \
    curl -L ${GRAAL_CE_URL} -o /tmp/graalvm.tar.gz && \
    tar -zxf /tmp/graalvm.tar.gz -C /tmp && \
    mv /tmp/graalvm-ce-java8-${GRAAL_VERSION} /opt/graalvm && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*


RUN rm -rf /opt/graalvm/*src.zip \
    /opt/graalvm/sample/

LABEL org.label-schema.name="graalvm-playground" \
      org.label-schema.description="A docker image with GraalVM, JDK 1.8, Node, Maven and Git" \
      org.label-schema.vcs-url="https://github.com/unicornsquald/k8s-maven" 


ENV JAVA_HOME /opt/graalvm
ENV GRAALVM_HOME /opt/graalvm
ENV NATIVE_IMAGE_CONFIG_FILE $GRAALVM_HOME/native-image.properties
ENV PATH /opt/apache-maven/bin:$JAVA_HOME/jre/bin:$GRAALVM_HOME/bin:$PATH

COPY --from=build /opt/graalvm /opt/graalvm
COPY --from=build /opt/apache-maven /opt/apache-maven

RUN /opt/graalvm/bin/gu install native-image llvm-toolchain && \
    mkdir -p /root/.native-image && \
    echo "NativeImageArgs = --no-server" > $GRAALVM_HOME/native-image.properties

WORKDIR /root