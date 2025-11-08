-module(blog_handler).

-behaviour(cowboy_handler).

-export([init/2]).

-record(post, {slug, title, date, excerpt, content}).

init(Req0, Opts) ->
    Path = cowboy_req:path(Req0),

    Method = cowboy_req:method(Req0),
    {ok, Req} = handle(Method, Path, Req0),
    {ok, Req, Opts}.

handle(<<"GET">>, <<"/blog">>, Req) ->
    Posts = db:list_posts(),
    PreparedPosts =
        lists:reverse(
            lists:map(fun tuple_to_map/1, Posts)),
    Html = pages:render_page("blog", [{title, "Blog"}, {posts, PreparedPosts}]),
    pages:send_html(200, Html, Req);
handle(<<"POST">>, <<"/blog">>, Req) ->
    case authorized(Req) of
        false ->
            pages:send_html(403, <<"Forbidden">>, Req);
        true ->
            {ok, Body, _Req2} = cowboy_req:read_body(Req),
            Post = parse_post(Body),
            db:add_post(Post),
            pages:send_html(201, <<"Created">>, Req)
    end;
handle(<<"GET">>, <<"/blog/", Slug/binary>>, Req) ->
    case db:get_post(Slug) of
        undefined ->
            not_found_handler:init(Req, []);
        Post ->
            PreparedPost = tuple_to_map(Post),
            Html =
                pages:render_page("blog_post",
                                  [{title, maps:get(title, PreparedPost)}, {post, PreparedPost}]),
            pages:send_html(200, Html, Req)
    end;
handle(<<"PUT">>, <<"/blog/", Slug/binary>>, Req) ->
    case authorized(Req) of
        false ->
            pages:send_html(403, <<"Forbidden">>, Req);
        true ->
            case db:get_post(Slug) of
                undefined ->
                    not_found_handler:init(Req, []);
                Post ->
                    {ok, Body, _Req2} = cowboy_req:read_body(Req),
                    UpdatedPost = update_post(Post, parse_post(Body)),
                    db:add_post(UpdatedPost),
                    pages:send_html(200, <<"Updated">>, Req)
            end
    end;
handle(<<"DELETE">>, <<"/blog/", Slug/binary>>, Req) ->
    case authorized(Req) of
        false ->
            pages:send_html(403, <<"Forbidden">>, Req);
        true ->
            case db:get_post(Slug) of
                undefined ->
                    not_found_handler:init(Req, []);
                _Post ->
                    db:delete_post(Slug),
                    pages:send_html(200, <<"Deleted">>, Req)
            end
    end;
handle(_, _, Req) ->
    not_found_handler:init(Req, []).

get_auth_token(Req) ->
    cowboy_req:header(<<"x-api-key">>, Req).

get_auth_token_from_env() ->
    % TODO: rewrite this later
    list_to_binary(os:getenv("API_KEY", <<"secret">>)).

authorized(Req) ->
    case get_auth_token(Req) of
        undefined ->
            false;
        Value ->
            Secret = get_auth_token_from_env(),
            case byte_size(Value) =:= byte_size(Secret) of
                false ->
                    false;
                true ->
                    crypto:hash_equals(Value, Secret)
            end
    end.

parse_post(Body) ->
    Json = jsone:decode(Body, [{keys, attempt_atom}]),
    #post{slug = maps:get(slug, Json),
          title = maps:get(title, Json),
          date = maps:get(date, Json),
          excerpt = maps:get(excerpt, Json),
          content = maps:get(content, Json)}.

update_post(OldPost, NewPost) ->
    OldPost#post{title = NewPost#post.title,
                 date = NewPost#post.date,
                 excerpt = NewPost#post.excerpt,
                 content = NewPost#post.content}.

tuple_to_map({post, Slug, Title, Date, Excerpt, Content}) ->
    #{slug => Slug,
      title => Title,
      date => Date,
      excerpt => Excerpt,
      content => Content}.
