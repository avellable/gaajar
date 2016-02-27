-module(gaajar_tests).

-include_lib("eunit/include/eunit.hrl").
-include_lib("amqp_client/include/amqp_client.hrl").

eat_gaajar_test() ->
    {ok, Connection} = amqp_connection:start(#amqp_params_direct{}),
    {ok, Channel} = amqp_connection:open_channel(Connection),
    #'queue.declare_ok'{queue = Q}
        = amqp_channel:call(Channel, #'queue.declare'{exclusive = true,
                                                      auto_delete = true}),
    #'queue.bind_ok'{}
        = amqp_channel:call(Channel, #'queue.bind'{queue = Q,
                                                   exchange = <<"carrots">>,
                                                   routing_key = <<"carrot">>}),
    timer:sleep(2000),
    case amqp_channel:call(Channel, #'basic.get'{queue = Q, no_ack = true}) of
        {'basic.get_empty', _} -> exit(did_not_receive_gaajar);
        {_, #amqp_msg{}}       -> ok
    end,
    ok.
