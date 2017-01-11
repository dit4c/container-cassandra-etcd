.PHONY = clean all

BASE_DIR = $(shell pwd)
BUILD_DIR = ${BASE_DIR}/build
OUT_DIR = ${BASE_DIR}/dist
TARGET_IMAGE = ${OUT_DIR}/cassandra-etcd-linux-amd64.aci

MKDIR_P = mkdir -p

CASSANDRA_DOCKER_IMAGE=library/cassandra:latest
CASSANDRA_ACI=${BUILD_DIR}/library-cassandra-latest.aci

CASSANDRA_ETCD_SEED_PROVIDER_VERSION=1.1
CASSANDRA_ETCD_SEED_PROVIDER_URL=https://github.com/zalando-incubator/cassandra-etcd-seed-provider/releases/download/v${CASSANDRA_ETCD_SEED_PROVIDER_VERSION}/cassandra-etcd-seed-provider-${CASSANDRA_ETCD_SEED_PROVIDER_VERSION}.jar
CASSANDRA_ETCD_SEED_PROVIDER_JAR=${BUILD_DIR}/cassandra-etcd-seed-provider-${CASSANDRA_ETCD_SEED_PROVIDER_VERSION}.jar

ACBUILD=${BUILD_DIR}/acbuild
ACBUILD_VERSION=0.4.0
ACBUILD_URL=https://github.com/containers/build/releases/download/v${ACBUILD_VERSION}/acbuild-v${ACBUILD_VERSION}.tar.gz

DOCKER2ACI=${BUILD_DIR}/docker2aci
DOCKER2ACI_VERSION=0.14.0
DOCKER2ACI_URL=https://github.com/appc/docker2aci/releases/download/v${DOCKER2ACI_VERSION}/docker2aci-v${DOCKER2ACI_VERSION}.tar.gz

all: ${TARGET_IMAGE}

${TARGET_IMAGE}: ${OUT_DIR} ${ACBUILD} ${CASSANDRA_ACI} ${CASSANDRA_ETCD_SEED_PROVIDER_JAR}
	${ACBUILD} --debug begin ${CASSANDRA_ACI}
	${ACBUILD} --debug copy-to-dir ${CASSANDRA_ETCD_SEED_PROVIDER_JAR} /usr/share/cassandra/lib/
	${ACBUILD} --debug set-exec -- cassandra -f
	${ACBUILD} --debug set-name cassandra-etcd
	${ACBUILD} --debug set-user cassandra
	${ACBUILD} --debug set-group cassandra
	${ACBUILD} --debug write --overwrite $@
	${ACBUILD} --debug end

clean:
	rm -rf ${BUILD_DIR} ${OUT_DIR}

${CASSANDRA_ACI}:
	cd ${BUILD_DIR} && ${DOCKER2ACI} docker://${CASSANDRA_DOCKER_IMAGE}

${CASSANDRA_ETCD_SEED_PROVIDER_JAR}:
	curl -sL ${CASSANDRA_ETCD_SEED_PROVIDER_URL} > $@

${ACBUILD}: ${BUILD_DIR}
	curl -sL ${ACBUILD_URL} | tar xz --strip-components=1 -C ${BUILD_DIR}

${DOCKER2ACI}: ${BUILD_DIR}
	curl -sL ${DOCKER2ACI_URL} | tar xz --strip-components=1 -C ${BUILD_DIR}

${BUILD_DIR}:
	${MKDIR_P} ${BUILD_DIR}

${OUT_DIR}:
	${MKDIR_P} ${OUT_DIR}
