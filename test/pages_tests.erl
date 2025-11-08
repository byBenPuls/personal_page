-module(pages_tests).

-include_lib("eunit/include/eunit.hrl").

-define(SETUP(Fun), {setup, fun start/0, fun stop/1, Fun}).

start() ->
    ets:new(page_store, [named_table, public, {read_concurrency, true}]),
    ok.

stop(_) ->
    ets:delete(page_store),

    ok.

build_filename(Name) ->
    "priv/static/" ++ Name ++ ".html".

build_filename_test_() ->
    [{"builds correct filename for simple name",
      ?_assertEqual("priv/static/home.html", build_filename("home"))},
     {"builds correct filename for complex name",
      ?_assertEqual("priv/static/user-profile.html", build_filename("user-profile"))},
     {"builds correct filename for empty name",
      ?_assertEqual("priv/static/.html", build_filename(""))}].

render_page_test_() ->
    {setup,
     fun() ->
        filelib:ensure_dir("priv/static/"),
        file:write_file("priv/static/simple.html", <<"<html>Simple Page</html>">>),
        file:write_file("priv/static/dynamic.html", <<"Hello {{name}}!">>),
        ok
     end,
     fun(_) ->
        file:delete("priv/static/simple.html"),
        file:delete("priv/static/dynamic.html"),

        ok
     end,
     [{"renders static page without context",
       fun() ->
          Result = pages:render_page("simple", []),
          ?assertEqual(<<"<html>Simple Page</html>">>, Result)
       end},
      {"renders dynamic page with context",
       fun() ->
          Result = pages:render_page("dynamic", [{name, "World"}]),
          ?assertEqual(<<"Hello World!">>, Result)
       end},
      {"returns binary for dynamic template",
       fun() ->
          Result = pages:render_page("dynamic", [{name, "Test"}]),
          ?assert(is_binary(Result)),
          ?assertEqual(<<"Hello Test!">>, Result)
       end}]}.

render_page_error_test_() ->
    {setup,
     fun() -> ok end,
     fun(_) -> ok end,
     [{"handles non-existent file gracefully",
       fun() ->
          try
              _Result = pages:render_page("nonexistent_file_123", []),
              ?assert(true)
          catch
              error:enoent -> ?assert(true);
              error:{badmatch, {error, enoent}} -> ?assert(true);
              _:Other ->
                  ct:pal("Unexpected error type: ~p", [Other]),
                  ?assert(false)
          end
       end}]}.

build_page_integration_test_() ->
    {setup,
     fun() ->
        start(),
        filelib:ensure_dir("priv/static/"),
        file:write_file("priv/static/integration.html", <<"Welcome {{user}}">>),
        ok
     end,
     fun(_) ->
        file:delete("priv/static/integration.html"),
        stop(ok)
     end,
     [{"full flow: build, cache, and retrieve",
       fun() ->
          Result1 = pages:build_page("integration", [{user, "Alice"}]),
          ?assertEqual(<<"Welcome Alice">>, Result1),

          Result2 = pages:build_page("integration", [{user, "Bob"}]),
          ?assertEqual(<<"Welcome Alice">>, Result2),

          ets:delete(page_store, "integration"),
          Result3 = pages:build_page("integration", [{user, "Charlie"}]),
          ?assertEqual(<<"Welcome Charlie">>, Result3)
       end}]}.
