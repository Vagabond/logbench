Logbench
---------

A tool for benchmarking logging in Erlang.

Logbench consists of 2 kinds of functions, handlers and formatters.

Formatters generate some formatting to be done. Available formatters include simple, small, large, huge and giant.

Handlers are functions that return a 3-tuple of funs, the first fun is the setup, the second fun is the logging fun
and the third fun is the 'block until done' fun. This latter fun is usually simply a synchronous call to the logging
process so that we know all prior log events have been processed.

You can run a benchmark like this:

`./bin/bench <handler> <formatter> <iterations> [workers]`

Simply running `./bin/bench` will give you a list of the available handlers and formatters.

Workers indicates the number of processes generating log events, it default to 1. Increase it to emulate more processes
generating the log events.

A sample runner is included as `run.sh`.
