-module(not_found_handler).

-export([init/2]).

init(Req, _Opts) ->
    Html = pages:build_page("not_found", [{title, "Not found"}]),
    pages:send_html(200, Html, Req).
