var page = require('webpage').create(),
    system = require('system'),
    fs = require('fs'),
    page = require('webpage').create(),
    address, output, size;

page.viewportSize = { width: 600, height: 600 };
page.paperSize = {
  format: 'A4'
}

file = system.args[1];
pdf = system.args[2];

html = fs.read(file);
page.content = html;
//  '<style>h1{ font-weight: normal; }</style><h1>This is a test, jejejeje</h1>';
page.onLoadFinished = function() {
  page.render(pdf);
  phantom.exit();
}
