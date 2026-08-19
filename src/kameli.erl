
-module(kameli).

-import(string, [
port_command/2,
lists:map/2
]).

-export([main/0]).

open_worker() ->
    RunCompiler = "perl lexer.pl | node parser.js",

    Port = open_port(
        {spawn, RunCompiler}, [
            binary,
            {line, 4096},
            use_stdio
        ]
    ),
    Port().

main() ->
    open_worker().
    