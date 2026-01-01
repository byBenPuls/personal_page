-module(personal_page_router).

-behaviour(nova_router).

-export([routes/1]).

-define(MAIN, personal_page_main_controller).
-define(API, personal_page_api_controller).

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

api() ->
    section("/api",
            {personal_page_auth, auth_user},
            [route("/healthcheck", ?API, healthcheck, [get]),
             route("/post/:id", ?API, get_post, [get]),
             route("/post/:id", ?API, insert_post, [post]),
             route("/post/:id", ?API, update_post, [put]),
             route("/post/:id", ?API, delete_post, [delete])]).

other() ->
    #{}.

%% The Environment-variable is defined in your sys.config in {nova, [{environment, Value}]}
routes(_Environment) ->
    [main(), api()].

% TODO: add blog routes (some routes may be protected by auth module)
