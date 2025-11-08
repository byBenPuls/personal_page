-module(app).

-behaviour(application).

-export([start/2, stop/1]).

resolve_routes() ->
    BasicPages =
        [{"/", handlers, []}, {"/projects", handlers, []}, {"/consultations", handlers, []}],
    BlogPages = [{"/blog", blog_handler, []}, {"/blog/:id", blog_handler, []}],
    NotFoundPage = [{"/[...]", not_found_handler, []}],
    BasicPages ++ BlogPages ++ NotFoundPage.

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([{'_', resolve_routes()}]),
    {ok, _} =
        cowboy:start_clear(http_listener, [{port, 8080}], #{env => #{dispatch => Dispatch}}),

    app_sup:start_link().

stop(_State) ->
    db:stop(),
    ok.
