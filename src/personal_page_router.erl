-module(personal_page_router).

-behaviour(nova_router).

-export([routes/1]).

-define(MAIN, personal_page_main_controller).

section(Prefix, Security, Routes) ->
    #{prefix => Prefix,
      security => Security,
      routes => Routes}.

route(Path, Module, Func, Methods) ->
    {Path, {Module, Func}, #{method => Methods}}.

main() ->
    section("",
            false,
            [route("/", ?MAIN, index, [get]),
             route("/projects", ?MAIN, projects, [get]),
             route("/consultations", ?MAIN, consultations, [get]),
             route("/blog", ?MAIN, blog, [get]),
             route("/post:id", ?MAIN, post, [get])]).

%% The Environment-variable is defined in your sys.config in {nova, [{environment, Value}]}
routes(_Environment) ->
    [main()].
