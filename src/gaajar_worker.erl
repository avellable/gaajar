-module(gaajar_worker).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([feed/0]).

-include_lib("amqp_client/include/amqp_client.hrl").

-record(state, {channel}).

start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, Connection} = amqp_connection:start(#amqp_params_direct{}),
    {ok, Channel} = amqp_connection:open_channel(Connection),
    amqp_channel:call(Channel, #'exchange.declare'{exchange = <<"carrots">>,
                                                   type = <<"topic">>}),
    feed(),
    {ok, #state{channel = Channel}}.

handle_call(_Msg, _From, State) ->
    {reply, not_defined, State}.

handle_cast(feed, State = #state{channel = Channel}) ->
    Properties = #'P_basic'{content_type = <<"text/plain">>, delivery_mode = 1},

    Message = <<"Carrot!">>,
    BasicPublish = #'basic.publish'{exchange = <<"carrots">>,
                                    routing_key = <<"carrot">>},
    Content = #amqp_msg{props = Properties, payload = Message},
    amqp_channel:call(Channel, BasicPublish, Content),
    timer:apply_after(1000, ?MODULE, fire, []),
    {noreply, State};

handle_cast(_, State) ->
    {noreply,State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_, #state{channel = Channel}) ->
    amqp_channel:call(Channel, #'channel.close'{}),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%---------------------------

feed() ->
    gen_server:cast({global, ?MODULE}, feed).
