
import readline from 'readline';

const fs = require('node:fs');


function generate(snippet, file) {
    fs.writeFile(file, snippet, err => {
        if (err) {
            throw ("GENERATOR [error]:" + err);
        }
    })
}

function run_generator(snippets, file) {
    try {
        snippets.forEach((snippet) => generate(snippet, file));
    } catch (err) {
        process.stderr.write(err);
    }
    return true;
}

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const snippets = [];

const file = process.argv[0];

rl.on('line', (line) => {
    if (line.trim()) {
        const snippet = JSON.parse(line);
        snippets.push(snippet);
    }
});

rl.on('close', () => {
    const message = run_generator(snippets, file);
    console.log({"ok": true, "message": message});
});