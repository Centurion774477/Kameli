
use strict; use warnings;
use JSON::PP;

$| = 1;

my @tokens;

# argue token
sub push_to_tokens {
    my $token = shift;
    push @tokens, $token;
}

# argue file to lex
sub lex {
    my $fileToOpen = shift;
    open my $fh, '<', $fileToOpen or die "Could not open file: $!";
    while (my $line = <$fh>) {
        if ($line =~ /my\sscalar\s(?<variable_name>\w+)\./) {
            push_to_tokens({
                type => 'create_empty_scalar',
                name => $+{variable_name}
            });
        } elsif ($line =~ /my\sarray\s(?<variable_name>\w+)\./) {
            push_to_tokens({
                type => 'create_empty_array',
                name => $+{variable_name}
            });
        } elsif ($line =~ /my\srecord\s(?<variable_name>\w+)\./) {
            push_to_tokens({
                type => 'create_empty_record',
                name => $+{variable_name}
            });
        }   elsif ($line =~ /my\sscalar\s(?<variable_name>\w+)\s=\s(?<value>.*)\./) {
            push_to_tokens({
                type => 'create_and_assign_scalar',
                name => $+{variable_name},
                value => $+{value}
            });
        } elsif ($line =~ /my\sarray\s(?<variable_name>\w+)\s=\s\((?<value>.*)\)\./) {
            push_to_tokens({
                type => 'create_and_assign_array',
                name => $+{variable_name},
                value => $+{value}
            });
        } elsif ($line =~ /my\srecord\s(?<variable_name>\w+)\s=\s\{(?<value>.*)\}\./) {
            push_to_tokens({
                type => 'create_and_assign_record',
                name => $+{variable_name},
                value => $+{value}
            });
        } elsif ($line =~ /my\sscalar\s(?<alias>.*)\s=\s(?<array_name>\w+)\'s\shead\./) {
            push_to_tokens({
                type => 'array_head',
                name => $+{array_name},
                alias => $+{alias}
            });
        } elsif ($line =~ /my\sscalar\s(?<alias>.*)\s=\s(?<array_name>\w+)\'s\stail\./) {
            push_to_tokens({
                type => 'array_tail',
                name => $+{array_name},
                alias => $+{alias}
            });
        } elsif ($line =~ /shift\s(?<array_name>\w+)\./) {
            push_to_tokens({
                type => 'array_shift',
                name => $+{array_name}
            });
        } elsif ($line =~ /push\s(?<item>.*)\sto\s(?<array_name>\w+)\./) {
            push_to_tokens({
                type => 'array_push',
                name => $+{array_name},
                item => $+{item}
            });
        } elsif ($line =~ /apply\s(?<pattern>.*)\sto\sall\s\of(?<array_name>\w+)\./) {
            push_to_tokens({
                type => 'array_map',
                name => $+{array_name},
                pattern => $+{pattern}
            });
        } elsif ($line =~ /my\sscalar\s(?<alias>.*)\s=\smatch\s(?<key>.*)\to\s(?<record>\w+)\./) {
            push_to_tokens({
                type => 'assign_record_match',
                name => $+{record},
                key => $+{key}
            });
        } elsif ($line =~ /match\s(?<key>.*)\to\s(?<record>\w+)\sorelse\s(?<else_value>.*)\./) {
            push_to_tokens({
                type => 'record_match_with_else',
                name => $+{record},
                key => $+{key},
                else_value => $+{else_value}
            });
        } elsif ($line =~ /end\./) {
            push_to_tokens({
                type => 'end'
            });
        }


        else {
            push_to_tokens({
                type => 'vanilla',
                value => $line
            })
        }
    }
    close $fh;
}



print encode_json(\@tokens);