-module(gaajar).

-behaviour(application).

-export([start/2, stop/1]).

start(normal, []) ->
    gaajar_sup:start_link().

stop(_State) ->
    ok.
