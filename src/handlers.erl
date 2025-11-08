-module(handlers).

-behaviour(cowboy_handler).

-export([init/2]).

init(Req0, Opts) ->
    Path = cowboy_req:path(Req0),
    {ok, Req} = handle(Path, Req0),
    {ok, Req, Opts}.

handle(<<"/">>, Req) ->
    Html = pages:build_page("index", [{title, "About"}]),
    pages:send_html(200, Html, Req);
handle(<<"/projects">>, Req) ->
    Html = pages:build_page("projects", [{title, "Projects"}]),
    pages:send_html(200, Html, Req);
handle(<<"/consultations">>, Req) ->
    Html = pages:build_page("consultations", [{title, "Consultations"}]),
    pages:send_html(200, Html, Req).
