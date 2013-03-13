#!/bin/sh

#for BENCH in el_console sync_el_console lager_console log4erl_console alog_console el_file sync_el_file lager_file log4erl_file; do
for BENCH in el_file sync_el_file lager_file log4erl_file elog_file elogger_file fast_log_file; do
	for FMT in simple small large; do
		for I in 1 2 3; do
			./bin/bench $BENCH $FMT 10000
		done
	done
done
