-module(users_handler).

-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, resource_exists/2, content_types_provided/2,
         content_types_accepted/2, get_resource/2, create_resource/2, delete_resource/2,
         update_resource/2, accept_json/2]).

-ifdef(TEST).

-export([format_user/1]).

-endif.

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    Methods = [<<"GET">>, <<"POST">>, <<"PATCH">>, <<"DELETE">>],
    {Methods, Req, State}.

resource_exists(Req, _State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            case cowboy_req:method(Req) of
                <<"POST">> ->
                    {false, Req, list};
                <<"GET">> ->
                    {true, Req, list}
            end;
        UserID ->
            case db:get_user(UserID) of
                {ok, _} ->
                    {true, Req, UserID};
                {error, _} ->
                    {false, Req, UserID}
            end
    end.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, get_resource}], Req, State}.

content_types_accepted(Req, State) ->
    {[{<<"application/json">>, accept_json}], Req, State}.

accept_json(Req, State) ->
    case cowboy_req:method(Req) of
        <<"POST">> ->
            create_resource(Req, State);
        <<"PATCH">> ->
            update_resource(Req, State)
    end.

create_resource(Req, list) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req),
    Data = jsone:decode(Body),

    Name = maps:get(<<"name">>, Data),
    Email = maps:get(<<"email">>, Data),
    Comment = maps:get(<<"comment">>, Data),

    _Id = db:create_user(Name, Email, Comment),
    Req2 = cowboy_req:set_resp_body(Body, Req1),
    %% TODO: refactor response
    {{true, "/foo/bar"}, Req2, list}.

get_resource(Req, list) ->
    Users = db:get_users(),
    Response = jsone:encode(#{users => [format_user(User) || User <- Users]}),
    {Response, Req, list};
get_resource(Req, UserID) ->
    {ok, User} = db:get_user(UserID),
    Response = jsone:encode(format_user(User)),
    {Response, Req, UserID}.

update_resource(Req, UserID) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req),
    Data = jsone:decode(Body),

    Updates = maps:with([<<"name">>, <<"email">>, <<"comment">>], Data),
    db:update_user(UserID, Updates),
    {true, Req1, UserID}.

delete_resource(Req, UserID) ->
    ok = db:delete_user(UserID),
    {true, Req, UserID}.

format_user({Id, Name, Email, Comment, CreatedAt, UpdatedAt}) ->
    #{<<"id">> => Id,
      <<"name">> => Name,
      <<"email">> => Email,
      <<"comment">> => Comment,
      <<"created_at">> => CreatedAt,
      <<"updated_at">> => UpdatedAt}.
