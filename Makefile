.PHONY: test install

install:
	sudo luarocks make rockspec/lua-resty-queue-master-0.rockspec

test:
	luacheck lib/
	prove -I../test-nginx/lib -I. -r t

clean: 
	sudo luarocks remove lua-resty-queue
