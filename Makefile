# NOTE: Every line in a recipe must begin with a tab character.
BUILD_DIR ?= target

PREFIX ?=          /usr/local
LUA_INCLUDE_DIR ?= $(PREFIX)/include
LUA_LIB_DIR ?=     $(PREFIX)/lib/lua/$(LUA_VERSION)
INSTALL ?= install
TEST_NGINX_AWS_CLIENT_ID ?= ${AWS_ACCESS_KEY_ID}
TEST_NGINX_AWS_SECRET ?= ${AWS_SECRET_ACCESS_KEY}
TEST_NGINX_AWS_SECURITY_TOKEN ?= ${AWS_SECURITY_TOKEN}

.PHONY: all clean test install

all: ;

install: all
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/kms/
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/s3/
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/sns/
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/kinesis/
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/lambda/
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/httpclient/
	$(INSTALL) src/lua/api-gateway/aws/*.lua $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/
	$(INSTALL) src/lua/api-gateway/aws/httpclient/*.lua $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/httpclient/
	$(INSTALL) src/lua/api-gateway/aws/kms/*.lua $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/kms/
	$(INSTALL) src/lua/api-gateway/aws/sns/*.lua $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/sns/
	$(INSTALL) src/lua/api-gateway/aws/kinesis/*.lua $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/kinesis/
	$(INSTALL) src/lua/api-gateway/aws/lambda/*.lua $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/lambda/
#	$(INSTALL) src/lua/api-gateway/aws/s3/*.lua $(DESTDIR)/$(LUA_LIB_DIR)/api-gateway/aws/s3/

test:
	echo "updating git submodules ..."
	if [ ! -d "test/resources/test-nginx/lib" ]; then	git submodule update --init --recursive; fi
	echo "running tests ..."
#	cp -r test/resources/api-gateway $(BUILD_DIR)
	mkdir  -p $(BUILD_DIR)
	TEST_NGINX_AWS_CLIENT_ID="${TEST_NGINX_AWS_CLIENT_ID}" TEST_NGINX_AWS_SECRET="${TEST_NGINX_AWS_SECRET}" TEST_NGINX_AWS_SECURITY_TOKEN="${TEST_NGINX_AWS_SECURITY_TOKEN}" PATH=/usr/local/sbin:$$PATH TEST_NGINX_SERVROOT=`pwd`/$(BUILD_DIR)/servroot TEST_NGINX_PORT=1989 prove -I ./test/resources/test-nginx/lib -r ./test/perl

package:
	git tag -a v1.5 -m 'release-1.5'
	git push origin v1.5
	git archive --format=tar --prefix=api-gateway-aws-1.5/ -o api-gateway-aws-1.4.tar.gz -v HEAD

clean: all
	rm -rf $(BUILD_DIR)/servroot