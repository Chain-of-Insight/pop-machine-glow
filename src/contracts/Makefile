.PHONY : test build clean fresh

test:
	pytest . -v

build:
	mkdir build
	ligo compile-contract oracle.ligo main > build/oracle.tz
	ligo compile-contract reward_proxy.ligo main > build/reward_proxy.tz

clean:
	rm -fr build

fresh: clean build
