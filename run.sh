#!/bin/sh

FMTS="simple small"
ITERATIONS=100000

for FMT in $FMTS; do
	for BENCH in el_file sync_el_file lager_file log4erl_file elog_file elogger_file fast_log_file alog_file; do
		for I in 1 2 3; do
			./bin/bench $BENCH $FMT $ITERATIONS 1
			sleep 5
		done
	done
done

mv results results.1
mkdir mem_results.1
mv *.rrd *.png mem_results.1

for FMT in $FMTS; do
	for BENCH in el_file sync_el_file lager_file log4erl_file elog_file elogger_file fast_log_file alog_file; do
		for I in 1 2 3; do
			./bin/bench $BENCH $FMT $ITERATIONS 10
			sleep 5
		done
	done
done

mv results results.10
mkdir mem_results.10
mv *.rrd *.png mem_results.10

for FMT in $FMTS; do
	for BENCH in el_file sync_el_file lager_file log4erl_file elog_file elogger_file fast_log_file alog_file; do
		for I in 1 2 3; do
			./bin/bench $BENCH $FMT $ITERATIONS 100
			sleep 5
		done
	done
done

mv results results.100
mkdir mem_results.100
mv *.rrd *.png mem_results.100


