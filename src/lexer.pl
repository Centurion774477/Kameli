
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
            })
        } elsif ($line =~ /my\sarray\s(?<variable_name>\w+)\s=\s\((?<value>.*)\)\./) {
            push_to_tokens({
                type => 'create_and_assign_array',
                name => $+{variable_name},
                value => $+{value}
            })
        } elsif ($line =~ /my\srecord\s(?<variable_name>\w+)\s=\s\{(?<value>.*)\}\./) {
            push_to_tokens({
                type => 'create_and_assign_record',
                name => $+{variable_name},
                value => $+{value}
            })
        } else {
            push_to_tokens({
                type => 'vanilla',
                value => $line
            })
        }
    }
    close $fh;
}



print encode_json(\@tokens);