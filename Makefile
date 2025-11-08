APPNAME=app
REBAR=`which rebar3 || echo ./rebar3`

all: deps compile

deps:
	@( $(REBAR) get-deps )

compile:
	@( $(REBAR) compile )

clean:
	@( $(REBAR) clean )

run-local:
	rebar3 shell --config config/sys.config

tests:
	rebar3 eunit

.PHONY: all, deps, compile, tests, cov, run-local
