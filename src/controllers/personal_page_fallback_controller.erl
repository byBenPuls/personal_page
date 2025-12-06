-module(personal_page_fallback_controller).

-export([resolve/2]).

resolve(_Req, {error, internal_error}) ->
    {view, [{title, "Internal Error"}], #{view => internal_error, status_code => 500}};
resolve(_Req, {error, not_found}) ->
    {view, [{title, "Not Found"}], #{view => not_found, status_code => 404}}.
