angular
  .module('OverviewSite', [])
  .controller('IndexCtrl', function ($scope, $http) {
    $scope.targetFile = 'file:///Users/matstijl/development/repositories/github/stil4m/software-evolution-series-1/maintenance/export.json';
    $scope.analysis = null;
    $http.get('./data.json').success(function (d) {
      $scope.analysis = d;
      console.log(d);
    });
    $scope.lookupFile = function (data) {
      if (data == null) {
        $scope.error = "No target file";
      }

      reader.readAsArrayBuffer(data);

    }
  })
  .controller('OverviewCtrl', function ($scope) {
    $scope.tabs = [
      {id: 'overview', name: 'Overview', template: 'templates/overview.html'},
      {id: 'classes', name: 'Files'},
      {id: 'duplication', name: 'Duplication'}
    ];
    $scope.activeTab = $scope.tabs[0];

    $scope.clickTab = function (tab) {
      $scope.activeTab = tab;
    };
  });
