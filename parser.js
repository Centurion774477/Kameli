
import readline from 'readline';

const snippets = [];

function addToSnippets(snippet) {
    snippets.push(snippet);
}

function parseEmptyScalarCreation(token) {
    addToSnippets("my $" + token.name + ";");
}

function parseEmptyArrayCreation(token) {
    addToSnippets("my @" + token.name + ";");
}

function parseEmptyRecordCreation(token) {
    addToSnippets("my %" + token.name + ";");
}


function parseScalarCreationWithData(token) {
    addToSnippets("my $" + token.name + " = " + token.value + ";");
}

function parseArrayCreationWithData(token) {
    addToSnippets("my @" + token.name + " = " + token.value + ";");
}

function parseRecordCreationWithData(token) {
    addToSnippets("my %" + token.name + " = (" + token.value + ");");
}

function parseArrayHead(token) {
    addToSnippets("my $" + token.alias + " = " + token.name + "[0];");
}

function parseArrayTail(token) {
    addToSnippets("my $" + token.alias + " = " + token.name + "[-1];");
}

function parseArrayShift(token) {
    addToSnippets("shift(" + token.name + ");");
}

function parseArrayPush(token) {
    addToSnippets("push(" + token.item + ", " + token.name + ");");
}

// check the syntax on this
function parseArrayMap(token) {
    addToSnippets(token.pattern + " for @" + token.name + ";");
}

function parseRecordMatch(token) {
    addToSnippets("my $" + token.alias + " = " + token.name + "->{" + token.key + "};");
}

function parseRecordMatchWithElse(token) {
    addToSnippets("my $" + token.alias + " = " + token.name + "->{" + token.key + "} or " + token.else_value + ";");
}

function parse_sort(token) {
    switch (token.type) {
        case 'create_empty_scalar':
            parseEmptyScalarCreation(token);
            break;
        case 'create_empty_array':
            parseEmptyArrayCreation(token);
            break;
        case 'create_empty_record':
            parseEmptyRecordCreation(token);
            break;
        case 'create_and_assign_scalar':
            parseScalarCreationWithData(token);
            break;
        case 'create_and_assign_array':
            parseArrayCreationWithData(token);
            break;
        case 'create_and_assign_record':
            parseRecordCreationWithData(token);
            break;
        case 'vanilla':
            addToSnippets(token.value);
            break;
        case 'array_head':
            parseArrayHead(token);
            break;
        case 'array_tail':
            parseArrayTail(token);
            break;
        case 'array_shift':
            parseArrayShift(token);
            break;
        case 'array_push':
            parseArrayPush(token);
            break;
        case 'array_map':
            parseArrayMap(token);
            break;
        case 'assign_record_match':
            parseRecordMatch(token);
            break;
        case 'record_match_with_else':
            parseRecordMatchWithElse(token);
            break;
        default:
            throw new Error(`Unknown token type: ${token.type} with value ${token}.`);
    }
}

function parse(tokens) {
    tokens.forEach(token => parse_sort(token));
}

const rl = readline.createInterface({
  input: process.stdin,
  terminal: false
});

const tokens = [];

rl.on('line', (line) => {
  if (line.trim()) {
    const token = JSON.parse(line);
    tokens.push(token);
  }
});

rl.on('close', () => {
  const code = parse(tokens);
  process.stdout.write(JSON.stringify(code) + "\n");
});
