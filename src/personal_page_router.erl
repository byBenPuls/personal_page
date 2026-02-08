-module(personal_page_router).

-behaviour(nova_router).

-export([routes/1]).

-define(MAIN, personal_page_main_controller).

section(Prefix, Security, Routes) ->
    #{
        prefix => Prefix,
        security => Security,
        routes => Routes
    }.

route(Path, Func, Methods) when is_list(Methods) ->
    {Path, Func, #{method => Methods}};
route(Path, Func, Params) when is_map(Params) ->
    {Path, Func, Params}.

main() ->
    section(
        "",
        false,
        [
            route(404, fun ?MAIN:not_found/1, #{}),
            route(500, fun ?MAIN:not_found/1, #{}),
            route("/", fun ?MAIN:index/1, [get]),
            route("/projects", fun ?MAIN:projects/1, [get]),
            route("/consultations", fun ?MAIN:consultations/1, [get])
        ]
    ).

%% The Environment-variable is defined in your sys.config in {nova, [{environment, Value}]}
routes(_Environment) ->
    [main()].
