-module(gaajar_sup).

-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, _Arg = []).

init([]) ->
    {ok, {{one_for_one, 3, 10},
          [{gaajar_worker,
            {gaajar_worker, start_link, []},
            permanent,
            10000,
            worker,
            [gaajar_worker]}
          ]}}.
