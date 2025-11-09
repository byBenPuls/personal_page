-module(pages).

-export([send_html/3]).
-export([build_page/2]).
-export([render_page/2]).
-export([get_accept_lang/1]).

build_filename(Name) ->
    filename:join(
        code:priv_dir(app), "static/" ++ Name ++ ".html").

render_page(PageName, []) ->
    {ok, Data} = file:read_file(build_filename(PageName)),
    Data;
render_page(PageName, Context) ->
    PageAtom = list_to_atom(PageName),
    erlydtl:compile(build_filename(PageName), PageAtom),
    {ok, Html} = PageAtom:render(Context),
    erlang:iolist_to_binary(Html).

build_page(PageName, Context) ->
    % TODO: add TTL for Cache
    case ets:lookup(page_store, PageName) of
        [{PageName, CachedHtml}] ->
            CachedHtml;
        [] ->
            Html = render_page(PageName, Context),
            ets:insert(page_store, {PageName, Html}),
            Html
    end.

get_accept_lang(Req) ->
    cowboy_req:header(<<"accept-language">>, Req).

send_html(Status, Body, Req0) ->
    send(Status, #{<<"content-type">> => <<"text/html">>}, Body, Req0).

send(Status, Headers, Body, Req0) ->
    Req = cowboy_req:reply(Status, Headers, Body, Req0),
    {ok, Req}.
