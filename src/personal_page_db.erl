-module(personal_page_db).

-behaviour(gen_server).

-export([start_link/0, ping/1]).
-export([init/1, handle_call/3, handle_cast/2]).
-export([insert_post/1, delete_post/1, update_post/1, get_all_posts/1, get_post/1]).

-record(post,
        {id = null :: int(),
         name = null :: binary(),
         text = null :: binary(),
         created_at = null :: int()}).

-type post() :: #post{}.

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

ping(Server) ->
    gen_server:call(Server, ping).

-spec insert_post(post()) -> {ok, post()} | error.
insert_post(Post) ->
    gen_server:call(?MODULE, {insert_post, Post#post{created_at = erlang:system_time()}}).

-spec update_post(post()) -> {ok, post()} | {error, term()}.
update_post(Post = #post{id = Id}) when Id =/= null ->
    gen_server:call(?MODULE, {update_post, Post});
update_post(_) ->
    {error, id_required}.

-spec delete_post(post()) -> {ok, post()} | error.
delete_post(Post) ->
    gen_server:call(?MODULE, {delete_post, Post}).

-spec get_post(post()) -> {ok, post()} | error.
get_post(Post) ->
    {}.

-spec get_all_posts(post()) -> {ok, [post()] | []} | error.
get_all_posts(Post) ->
    {}.

init(_Args) ->
    ets:new(t, [ordered_set, named_table]),
    {ok, {}}.

handle_call(ping, _From, State) ->
    {reply, pong, State}.

handle_cast(_msg, State) ->
    {noreply, State}.
