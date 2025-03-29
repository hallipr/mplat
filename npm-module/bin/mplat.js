#!/usr/bin/env node

// ensure that onle of the optional dependencies is installed
// get the current platform and architecture
const os = require('os');
const path = require('path');
const fs = require('fs');

let platform = os.platform();
const packageName = `@hallipr/mplat-${platform}-${os.arch()}`;

function getPackagePath() {
    const basePaths = require.resolve.paths(packageName) || [];
    for (const basePath of basePaths) {
        const packagePath = path.join(basePath, packageName);
        if (fs.existsSync(packagePath)) {
            return packagePath;
        }
    }

    return null;
}

let packagePath = getPackagePath();

if (!packagePath) {
    console.error(`Platform package "${packageName}" is not installed.`);
    process.exit(1); // Exit with an error code
}

console.log(`Using package: ${packagePath}`);

// run package at path passing all args
const args = process.argv.slice(2);
const childProcess = require('child_process');
const execPath = path.join(packagePath, 'bin', 'mplat-cli');

const child = childProcess.spawn(execPath, args, {
    stdio: 'inherit',
    shell: true,
});

child.on('error', (err) => {
    console.error(`Error executing package: ${err.message}`);
    process.exit(1); // Exit with an error code
});

child.on('exit', (code) => {
    process.exit(code); // Exit with the same code as the child process
});
