-module(personal_page_main_controller).

-export([index/1, consultations/1, projects/1, not_found/1]).

-fallback_controller(personal_page_fallback_controller).

index(_Req) ->
    view("About", index).

consultations(_Req) ->
    view("Consultations", consultations).

projects(_Req) ->
    view("Projects", projects).

not_found(_Req) ->
    view("Not Found", not_found, 404).

view(PageTitle, ViewName) ->
    {ok, [{title, PageTitle}], #{view => ViewName}}.

view(PageTitle, ViewName, StatusCode) ->
    {ok, [{title, PageTitle}], #{view => ViewName, status_code => StatusCode}}.
