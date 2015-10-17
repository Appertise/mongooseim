-module(mod_user_status).
-author('rrigoni@gmail.com').

-behaviour(gen_mod).

-export([start/2,
	 init/2,
	 stop/1,
	 send_unavailable_notice/4,
	 send_available_notice/4]).

-define(PROCNAME, ?MODULE).

-include("ejabberd.hrl").
-include("jlib.hrl").

start(Host, Opts) ->
    ?INFO_MSG("Starting mod_user_status", [] ),
    register(?PROCNAME,spawn(?MODULE, init, [Host, Opts])),  
    ok.

init(Host, _Opts) ->
    inets:start(),
    ssl:start(),
    ejabberd_hooks:add(unset_presence_hook, Host, ?MODULE, send_unavailable_notice, 10),
    ejabberd_hooks:add(set_presence_hook, Host, ?MODULE, send_available_notice, 10),
    ok.

stop(Host) ->
    ?INFO_MSG("Stopping mod_user_status", [] ),
    ejabberd_hooks:delete(unset_presence_hook, Host, ?MODULE, send_unavailable_notice, 10),
    ejabberd_hooks:delete(set_presence_hook, Host, ?MODULE, send_available_notice, 10),
    ok.

send_unavailable_notice(User, Server, _Resource, _Status) ->
    Token = gen_mod:get_module_opt(Server, ?MODULE, auth_token, ""),
    PostUrl = gen_mod:get_module_opt(Server, ?MODULE, post_url_unavailable, ""),
    if (Token /= "") ->
	      Sep = "&",
	      Post = [
	        "user=", User, Sep,
	        "access_token=", Token ],
	      httpc:request(post, {PostUrl, [], "application/x-www-form-urlencoded", list_to_binary(Post)},[],[]),
	      ok;
	    true ->
	      ok
    end.

send_available_notice(User, Server, _Resource, _Packet) ->
    Token = gen_mod:get_module_opt(Server, ?MODULE, auth_token, ""),
    PostUrl = gen_mod:get_module_opt(Server, ?MODULE, post_url_available, ""),
    if (Token /= "") ->
				Sep = "&",
				Post = [
					"user=", User, Sep,
					"access_token=", Token ],
				httpc:request(post, {PostUrl, [], "application/x-www-form-urlencoded", list_to_binary(Post)},[],[]),
				ok;
			true ->
				ok
    end.