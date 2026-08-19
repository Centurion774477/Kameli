
-module(kameli).

-import(string, [string:replace/4]).

-export([main/0]).

% add error and exception handling

open_worker(File) ->
    NewFile = string:replace(File, ".kameli", ".pl", all),

    RunPerl = "perl lexer.pl " ++ File,
    RunNodeParser = "node parser.js",
    RunNodeGenerator = "node generator.js" ++ NewFile,

    RunCompiler = Runperl ++ " | " ++ RunNodeParser ++ " | " ++ RunNodeGenerator,
    % perl lexer.pl <file_to_lex> | node parser.js | node generator.js <file_to_output>

    Port = open_port(
        {spawn, RunCompiler}, [
            binary,
            {line, 4096},
            use_stdio
        ]
    ),
    Port().
    io:format("[ok] -> see file in ")

main() ->
    open_worker().
    