-module(logbench).

-compile([{parse_transform, lager_transform}, export_all]).
-include_lib("elog/include/elog.hrl").

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
				true = code:add_pathz(filename:dirname(escript:script_name())
					++ "/../deps/lager/ebin"),
				application:load(lager),
				application:set_env(lager, error_logger_redirect, false),
				application:set_env(lager, crash_log, undefined),
				application:set_env(lager, handlers, [{lager_console_backend, info}]),
				lager:start()
		end,
		fun() ->
				lager:error(Fmt, Args)
		end,
		fun() -> _ = gen_event:which_handlers(lager_event) end
	}.

log4erl_console({Fmt, Args}) ->
	{fun() ->
				true = code:add_pathz(filename:dirname(escript:script_name())
					++ "/../deps/log4erl/ebin"),
				application:load(log4erl),
				application:start(log4erl),
				log4erl:add_console_appender(cmd_logs, {info, "%j %T [%L] %l%n"})
		end,
		fun() ->
				log4erl:error(Fmt, Args)
		end,
		fun() -> ok end
		%fun() -> _ = gen_event:which_handlers(default_logger) end
	}.

alog_console({Fmt, Args}) ->
	{fun() ->
				true = code:add_pathz(filename:dirname(escript:script_name())
					++ "/../deps/alog/ebin"),
				application:start(sasl),
				application:load(alog),
				application:set_env(alog, install_error_logger_handler, false),
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
				ok = error_logger:logfile({open, "logs/el.log"})
		end,
		fun() -> error_logger:error_msg(Fmt, Args) end,
		fun() -> _ = gen_event:which_handlers(error_logger) end
	}.

sync_el_file({Fmt, Args}) ->
	{fun() ->
				error_logger:tty(false),
				ok = error_logger:logfile({open, "logs/sync_el.log"})
		end,
		fun() -> sync_error_logger:error_msg(Fmt, Args) end,
		fun() -> ok end
	}.

lager_file({Fmt, Args}) ->
	{fun() ->
				true = code:add_pathz(filename:dirname(escript:script_name())
					++ "/../deps/lager/ebin"),
				application:load(lager),
				application:set_env(lager, error_logger_redirect, false),
				application:set_env(lager, crash_log, undefined),
				application:set_env(lager, handlers, [{lager_file_backend, [{"logs/lager.log", info}]}]),
				lager:start()
		end,
		fun() ->
				lager:info(Fmt, Args)
		end,
		fun() -> _ = gen_event:which_handlers(lager_event) end
	}.

log4erl_file({Fmt, Args}) ->
	{fun() ->
				true = code:add_pathz(filename:dirname(escript:script_name())
					++ "/../deps/log4erl/ebin"),
				application:load(log4erl),
				application:start(log4erl),
				log4erl:add_file_appender(cmd_logs, {"logs", "log4erl", {size, 10*1024*1024}, 4, "log", info, "%j %T [%L] %l%n"})
		end,
		fun() ->
				log4erl:error(Fmt, Args)
		end,
		%fun() -> _ = gen_event:which_handlers(default_logger) end
		fun() -> ok end
	}.

alog_file({Fmt, Args}) ->
	{fun() ->
				true = code:add_pathz(filename:dirname(escript:script_name())
					++ "/../deps/alog/ebin"),
				application:start(sasl),
				application:load(alog),
				application:set_env(alog, enabled_loggers, [alog_disk_log]),
				application:set_env(alog, install_error_logger_handler, false),
				application:set_env(alog, alog_disk_log, [{name, alog_disk_log},
						{file, "logs/alogger.log"},
						{format, external}]),
				application:start(alog),
				ok = alog_control:delete_all_flows(),
				ok = alog_control:add_new_flow({mod,['_']}, {'=<', debug}, [alog_disk_log])
		end,
		fun() ->
				alog:error(Fmt, Args)
		end,
		fun() ->
				_ = sys:get_status(alog_disk_log, infinity),
				%% make sure everything actually makes it onto disk
				ok = disk_log:sync(alog_disk_log),
				ok
		end
	}.

elog_file({Fmt, Args}) ->
	{fun() ->
				true = code:add_pathz(filename:dirname(escript:script_name())
					++ "/../deps/elog/ebin"),
				application:load(elog),
				application:set_env(elog, level, info),
				application:set_env(elog, logger, {elogger_file, [{file, "logs/elog.log"},
									{size_limit, 10 * 1024 * 1024},
									{date_break, false}]}),
				application:start(elog)
		end,
		fun() ->
				?INFO(Fmt, Args)
		end,
		fun() -> _ = sys:get_status('elogger-info', infinity) end
	}.

elog_console({Fmt, Args}) ->
	{fun() ->
				true = code:add_pathz(filename:dirname(escript:script_name())
					++ "/../deps/elog/ebin"),
				application:load(elog),
				code:load_file(elogger),
				application:set_env(elog, level, info),
				application:set_env(elog, logger, {elogger_console, []}),
				application:start(elog)
		end,
		fun() ->
				?INFO(Fmt, Args)
		end,
		fun() -> _ = sys:get_status('elogger-info', infinity) end
	}.

elogger_file({Fmt, Args}) ->
	{fun() ->
				true = code:add_pathz(filename:dirname(escript:script_name())
					++ "/../deps/elogger/ebin"),
				[[SaslGL]] = ets:match(ac_tab, {{application_master, kernel}, '$1'}),
				%% set our group leader to the one from kernel
				%% so elogger can use application:get_env/1
				erlang:group_leader(SaslGL, self()),
				%% force module load order
				application:set_env(kernel, error_logger_mf_file, "logs/elogger"),
				application:set_env(kernel, error_logger_mf_maxbytes, 10 * 1024 * 1024),
				application:set_env(kernel, error_logger_mf_maxfiles, 5),
				elogger:start_link(),
				%% NOW remove the tty handler, if we do it before elogger tries to call
				%% error_logger:simple_logger() which causes a crash
				error_logger:tty(false)
		end,
		fun() -> error_logger:error_msg(Fmt, Args) end,
		fun() -> _ = gen_event:which_handlers(error_logger) end
	}.

fast_log_file({Fmt, Args}) ->
	{fun() ->
				true = code:add_pathz(filename:dirname(escript:script_name())
					++ "/../deps/fast_log/ebin"),
				application:load(fast_log),
				application:set_env(fast_log, loggers, [[{name, fast_logger}, {file, "logs/fast_log.log"}, {file_size, 10 * 1024 * 1024}]]),
				error_logger:tty(false),
				application:start(sasl),
				application:start(fast_log)
		end,
		fun() -> fast_log:info(fast_logger, token, Fmt, Args) end,
		fun() ->
				%% make sure the gen_event is drained
				_ = gen_event:which_handlers(fast_logger)
		end
	}.

