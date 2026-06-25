const fs = require('fs');
const path = require('path');
const ts = require('typescript');

const projectRoot = path.resolve(__dirname, '..');

function registerExtension(extension) {
  require.extensions[extension] = (module, filename) => {
    const source = fs.readFileSync(filename, 'utf8');
    const output = ts.transpileModule(source, {
      compilerOptions: {
        esModuleInterop: true,
        jsx: ts.JsxEmit.ReactJSX,
        module: ts.ModuleKind.CommonJS,
        target: ts.ScriptTarget.ES2022
      },
      fileName: filename
    });

    module._compile(output.outputText, filename);
  };
}

registerExtension('.ts');
registerExtension('.tsx');

require(path.join(projectRoot, 'tests', 'google-wallet.test.tsx'));
require(path.join(projectRoot, 'tests', 'apple-wallet.test.tsx'));
require(path.join(projectRoot, 'tests', 'wallet-ux.test.tsx'));
require(path.join(projectRoot, 'tests', 'menu-templates.test.tsx'));
