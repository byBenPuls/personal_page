-module(db).

-behaviour(gen_server).

-export([start_link/0, stop/0, add_post/1, get_post/1, delete_post/1, list_posts/0,
         set_page/2, get_page/1, delete_page/1, list_pages/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-record(state, {}).
-record(post, {slug, title, date, excerpt, content}).

add_post(Post = #post{}) ->
    mnesia:transaction(fun() -> mnesia:write(Post) end).

get_post(Slug) when is_binary(Slug) ->
    F = fun() ->
           case mnesia:read({post, Slug}) of
               [P] -> P;
               [] -> undefined
           end
        end,

    {atomic, Result} = mnesia:transaction(F),
    Result.

delete_post(Slug) when is_binary(Slug) ->
    mnesia:transaction(fun() -> mnesia:delete({post, Slug}) end).

list_posts() ->
    F = fun() ->
           mnesia:match_object(#post{slug = '_',
                                     title = '_',
                                     date = '_',
                                     excerpt = '_',
                                     content = '_'})
        end,
    {atomic, Posts} = mnesia:transaction(F),
    Posts.

set_page(Name, Html) when is_binary(Name), is_binary(Html) ->
    ets:insert(page_store, {Name, Html}).

get_page(Name) when is_binary(Name) ->
    case ets:lookup(page_store, Name) of
        [{_, Html}] ->
            Html;
        [] ->
            undefined
    end.

delete_page(Name) when is_binary(Name) ->
    ets:delete(page_store, Name).

list_pages() ->
    ets:tab2list(page_store).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
    gen_server:stop(?MODULE).

init([]) ->
    mnesia:create_schema([node()]),

    mnesia:start(),
    mnesia:create_table(post,
                        [{attributes, record_info(fields, post)}, {disc_copies, [node()]}]),

    ets:new(page_store, [named_table, public, set]),

    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    mnesia:stop(),
    ok.
