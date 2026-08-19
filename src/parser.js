
import readline from 'readline';

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
  const ast = parse(tokens);
  process.stdout.write(JSON.stringify(ast) + "\n");
});

const snippets = [];

//
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

function parse(token) {
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
    }
}

tokens.forEach(token => parse(token));