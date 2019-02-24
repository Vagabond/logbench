-module(memgraph).

-include_lib("errd/include/errd.hrl").

-export([start/0, start/1, init/1, graph/0, graph/2]).

start() ->
	spawn(?MODULE, init, ["memgraph"]).

start(Name) ->
	spawn(?MODULE, init, [Name]).

init(Name) ->
	FileName = Name++".rrd",
	file:delete(FileName),
	{ok, RRD} = errd_server:start_link(),
	{ok, _} = errd_server:command(RRD,
			#rrd_create{file=FileName,
				step=1,
				ds_defs = [#rrd_ds{name="memory", args="10:0:U", type = gauge}],
				rra_defs = [
					#rrd_rra{cf=last, args="0.5:1:3600"}
					]}),
	self() ! update,
	loop(RRD, Name).

loop(RRD, Name) ->
	FileName = Name++".rrd",
	receive
		update ->
			Mem = erlang:memory(total),
			errd_server:command(RRD, #rrd_update{file=FileName, updates=[#rrd_ds_update{name="memory", value=Mem}]}),
			erlang:send_after(1000, self(), update)
	end,
	loop(RRD, Name).

graph() ->
	graph("memgraph", "-20m").

graph(Start, Name) ->
	{ok, RRD} = errd_server:start_link(),
  Name2 = "memory",
	Command = "graph "++Name++".png --start "++Start++" --imgformat PNG --height 200 --width 600 DEF:"++Name2++"="++Name++".rrd:"++Name2++":LAST LINE2:"++Name2++"#000000:"++Name2++"\n",
	errd_server:raw(RRD, Command).
