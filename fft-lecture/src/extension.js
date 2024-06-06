const vscode = require('vscode');

function activate(context) {
	console.log('Congratulations, your extension "fstlec" is now active!');

	let disposable = vscode.commands.registerCommand('fstlec.helloWorld', function () {
		vscode.window.showInformationMessage('Hello World from fstlec!');
	});

	context.subscriptions.push(disposable);
}

function deactivate() {}

module.exports = {
	activate,
	deactivate
}