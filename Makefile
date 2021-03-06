SHELL=/bin/bash
LIBS=$(shell find . -regex "^./lib\/.*\.coffee\$$" | sed s/\.coffee$$/\.js/ | sed s/lib/lib-js/)

.PHONY: test

build: $(LIBS)

lib-js/%.js : lib/%.coffee
	set -e ;\
	coffee_bin_prefix=.. ;\
	coffee_bin_path=/coffee-script/bin/coffee ;\
	if [ ! -f "$${coffee_bin_prefix}$${coffee_bin_path}" ]; then coffee_bin_prefix=node_modules; fi ;\
	$${coffee_bin_prefix}$${coffee_bin_path} --bare -c -o $(@D) $(patsubst lib-js/%,lib/%,$(patsubst %.js,%.coffee,$@))

test-cov:
	rm -rf lib-js lib-js-cov
	coffee -c -o lib-js lib
	jscoverage lib-js lib-js-cov
	NODE_ENV=test TEST_COV_SAML2=1 node_modules/mocha/bin/mocha -R html-cov --ignore-leaks --compilers coffee:coffee-script/register test/*.coffee | tee coverage.html
	open coverage.html

test: build
	NODE_ENV=test node_modules/mocha/bin/mocha --ignore-leaks --timeout 60000 -R spec --compilers coffee:coffee-script/register test/*.coffee

clean:
	rm -rf lib-js lib-js-cov
