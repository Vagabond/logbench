-module(logfmt).

-compile([export_all]).

simple() ->
	{"Test~n", []}.

small() ->
	{"Hello world ~p ~p ~p~n", [node(), self(), now()]}.

large() ->
	{"Module ~p Function ~p Line ~p: Processes ~p Info ~p~n", [?MODULE, medium, ?LINE, erlang:system_info(process_count), erlang:system_info(info)]}.

giant() ->
	Bin = binary:copy(<<"a">>, 16777216),
	{"this is a 16mb binary: ~p~n", [Bin]}.

huge() ->
	Str = lists:duplicate(4194304, "a"),
	{"this is a 4mb string: ~p~n", [Str]}.
