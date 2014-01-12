# *bonsaiERP*
*bonsaiERP* is a simple ERP system to control the most basic stuff for a company, that includes:

- Sales
- Buys
- Expenses
- Bank accounts
- Inventory

 The software is been improved as we move

ctags -R `bundle show rails`/../*

v=spf1 a ip4:192.34.56.117 -all

txt.gsub(/(<link href=)"([a-z\.\/\?=])"/, "#{$1}\"localhost.bom:9292#{$2}\"")
render_to_string

txt.gsub(/(<link href=")([a-z0-9\/\?\.=\-_]+)/) { "#{$1}http://localhost.bom:9292#{$2}\"" }S

//= require 'plugins/bootstrap3'
//= require 'components/print_common'
//= require 'clases'
css = "<style>\n"
%w(plugins/bootstrap3 components/print_common clases).each do |v|
  css << Rails.application.assets.find_asset(v).body
end
css << '</style>'

f = File.new 'app/views/layouts/_print_css.print.erb', 'w+'
f.write css
f.close

('20100101101010'), ('20100324202441'), ('20100325221629'), ('20100401192000'), ('20100416193705'), ('20100421174307'), ('20100427190727'), ('20100531141109'), ('20110119140408'), ('20110201153434'), ('20110201161907'), ('20110411174426'), ('20110411182005'), ('20110411182905'), ('20111103143524'), ('20121215153208'), ('20130114144400'), ('20130114164401'), ('20130115020409'), ('20130204171801'), ('20130221151829'), ('20130325155351'), ('20130411141221'), ('20130426151609'), ('20130429120114'), ('20130510144731'), ('20130510222719'), ('20130522125737'), ('20130527202406'), ('20130618172158'), ('20130618184031'), ('20130702144114'), ('20130704130428'), ('20130715185912'), ('20130716131229'), ('20130716131801'), ('20130717190543'), ('20130911005608'), ('20131009131456'), ('20131009141203')

tail -f logs/production.log | grep "500 Internal Server Error" -B 2 -A 5
:%s/:\([^ ]*\)\(\s*\)=>/\1:/g

<!DOCTYPE html>
<html ng-app="app">

  <head>
    <script data-require="angular.js@1.0.7" data-semver="1.0.7" src="https://ajax.googleapis.com/ajax/libs/angularjs/1.0.7/angular.js"></script>
    <link rel="stylesheet" href="style.css" />
    <script src="script.js"></script>
  </head>

  <body>
    <h1>Compile dynamic HTML</h1>
    <div ng-controller="MyController">
      <textarea ng-model="html"></textarea>
      <div dynamic="html"></div>
      <div ng-controller='OtherController'>
        {{count}}
        <h2 dynamic='html'></h2>
      </div>
    </div>
  </body>

</html>

var app = angular.module('app', []);

app.directive('dynamic', function ($compile) {
  return {
    restrict: 'A',
    replace: true,
    link: function (scope, ele, attrs) {
      scope.$watch(attrs.dynamic, function(html) {
        ele.html(html);
        $compile(ele.contents())(scope);
      });
    }
  };
});

function MyController($scope) {
  $scope.click = function(arg) {
    alert('Clicked ' + arg);
  }
  $scope.html = '<a ng-click="click(1)" href="#">Click me</a>';
}

function OtherController($scope) {
  $scope.count = 0;
  $scope.update = function() { $scope.count += 1; };
  $scope.html = '<a ng-click="click(1)" href="#">Click me</a>';
}
