#!/bin/sh

FMTS="simple small large" # huge giant"
BENCHES="el_console logger_console logger_lager_console logger_limited_console lager_console el_file logger_file logger_lager_file logger_limited_file lager_file"
ITERATIONS=10000

for FMT in $FMTS; do
	for BENCH in $BENCHES; do
		for I in 1 2 3; do
			./bin/bench $BENCH $FMT $ITERATIONS 1 > /dev/null 2>&1
			rm -rf logs
			sleep 5
		done
	done
done

mv results results.1
mkdir mem_results.1
mv *.rrd *.png mem_results.1

for FMT in $FMTS; do
	for BENCH in $BENCHES; do
		for I in 1 2 3; do
			./bin/bench $BENCH $FMT $ITERATIONS 4 > /dev/null 2>&1
			rm -rf logs
			sleep 5
		done
	done
done

mv results results.4
mkdir mem_results.4
mv *.rrd *.png mem_results.4

for FMT in $FMTS; do
	for BENCH in $BENCHES; do
		for I in 1 2 3; do
			./bin/bench $BENCH $FMT $ITERATIONS 100 > /dev/null 2>&1
			rm -rf logs
			sleep 5
		done
	done
done

mv results results.100
mkdir mem_results.100
mv *.rrd *.png mem_results.100


