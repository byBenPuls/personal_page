-module(personal_page_auth).

-export([auth_user/1]).

auth_user(Req) ->
    ApiKey = os:getenv("API_KEY"),
    try
        {ok, UserKey} = extract_auth_key(Req),
        true = check_encrypted(UserKey, ApiKey),
        {ok, User} = get_user(UserKey),
        auth_response(User)
    catch
        _:_ ->
            false
    end.

extract_auth_key(_Req = #{headers := Headers}) ->
    maps:find(<<"x-api-key">>, Headers).

encrypt(Key) ->
    crypto:hash(blake2b, Key).

compare(FirstKey, SecondKey) ->
    crypto:hash_equals(FirstKey, SecondKey).

check_encrypted(UserKey, SecondKey) ->
    compare(encrypt(UserKey), encrypt(SecondKey)).

get_user(Key) ->
    {ok, #{name => Key, role => "Admin"}}.

auth_response(User) ->
    {true, #{user => User}}.
