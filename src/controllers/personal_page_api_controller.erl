-module(personal_page_api_controller).

-export([get_post/1, insert_post/1, update_post/1, delete_post/1, healthcheck/1]).

-define(EXAMPLE, #{id => 123, text => <<"some text">>}).

get_post(_Req = #{bindings := #{<<"id">> := Id}, auth_data := User}) ->
    io:write(User),

    json(?EXAMPLE).

insert_post(_Req) ->
    json(?EXAMPLE).

update_post(_Req) ->
    json(#{}).

delete_post(_Req = #{parsed_qs := #{<<"id">> := Id}, auth_data := User}) ->
    json(#{}).

json(Body) ->
    {json, Body}.

healthcheck(_Req) ->
    SomeMetrics = #{},
    json(#{status => <<"ok">>, metrics => SomeMetrics}).
