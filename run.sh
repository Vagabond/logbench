#!/bin/sh

for BENCH in el_file sync_el_file lager_file log4erl_file elog_file elogger_file fast_log_file alog_file; do
	for FMT in simple small large; do
		for I in 1 2 3; do
			./bin/bench $BENCH $FMT 10000 1
		done
	done
done

mv results results.1
mkdir mem_results.1
mv *.rrd *.png mem_results.1

for BENCH in el_file sync_el_file lager_file log4erl_file elog_file elogger_file fast_log_file alog_file; do
	for FMT in simple small large; do
		for I in 1 2 3; do
			./bin/bench $BENCH $FMT 10000 10
		done
	done
done

mv results results.100
mkdir mem_results.100
mv *.rrd *.png mem_results.100

