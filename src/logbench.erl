-module(logbench).

-compile([{parse_transform, lager_transform}, export_all]).

el_console({Fmt, Args}) ->
	{fun() -> ok end,
		fun() -> error_logger:error_msg(Fmt, Args) end,
		fun() -> _ = gen_event:which_handlers(error_logger) end
	}.

sync_el_console({Fmt, Args}) ->
	{fun() -> ok end,
		fun() -> sync_error_logger:error_msg(Fmt, Args) end,
		fun() -> ok end
	}.

lager_console({Fmt, Args}) ->
	{fun() ->
				application:load(lager),
				application:set_env(lager, handlers, [{lager_console_backend, info}]),
				application:start(lager)
		end,
		fun() ->
				lager:error(Fmt, Args)
		end,
		fun() -> ok end
	}.

log4erl_console({Fmt, Args}) ->
	{fun() ->
				application:load(log4erl),
				application:start(log4erl),
				log4erl:add_console_appender(cmd_logs, {info, "%j %T [%L] %l%n"})
		end,
		fun() ->
				log4erl:error(Fmt, Args)
		end,
		fun() -> ok end
	}.

alog_console({Fmt, Args}) ->
	{fun() ->
				application:start(sasl),
				application:start(alog),
				ok = alog_control:delete_all_flows(),
				ok = alog_control:add_new_flow({mod,['_']}, {'=<', debug}, [alog_tty])
		end,
		fun() ->
				alog:error(Fmt, Args)
		end,
		fun() -> ok end
	}.

el_file({Fmt, Args}) ->
	{fun() ->
				error_logger:tty(false),
				ok = error_logger:logfile({open, "logs/test.log"})
		end,
		fun() -> error_logger:error_msg(Fmt, Args) end,
		fun() -> _ = gen_event:which_handlers(error_logger) end
	}.

sync_el_file({Fmt, Args}) ->
	{fun() ->
				error_logger:tty(false),
				ok = error_logger:logfile({open, "logs/test.log"})
		end,
		fun() -> sync_error_logger:error_msg(Fmt, Args) end,
		fun() -> ok end
	}.

lager_file({Fmt, Args}) ->
	{fun() ->
				application:load(lager),
				application:set_env(lager, handlers, [{lager_file_backend, [{"logs/test.log", info}]}]),
				application:start(lager)
		end,
		fun() ->
				lager:info(Fmt, Args)
		end,
		fun() -> ok end
	}.

log4erl_file({Fmt, Args}) ->
	{fun() ->
				application:load(log4erl),
				application:start(log4erl),
				log4erl:add_file_appender(cmd_logs, {"logs", "test", {time, 0}, 4, "log", info, "%j %T [%L] %l%n"})
		end,
		fun() ->
				log4erl:error(Fmt, Args)
		end,
		fun() -> ok end
	}.

alog_file({Fmt, Args}) ->
	{fun() ->
				application:start(sasl),
				application:start(alog),
				ok = alog_control:delete_all_flows(),
				ok = alog_control:add_new_flow({mod,['_']}, {'=<', debug}, [alog_disk_log])
		end,
		fun() ->
				alog:error(Fmt, Args)
		end,
		fun() -> ok end
	}.

