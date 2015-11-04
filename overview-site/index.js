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
      {id: 'classes', name: 'Files', template: 'templates/classes.html'},
      {id: 'duplication', name: 'Duplication', template: 'templates/duplication.html'},
      {id: 'raw', name: 'Raw', template: 'templates/raw.html'}
    ];
    $scope.activeTab = $scope.tabs[0];

    $scope.clickTab = function (tab) {
      $scope.activeTab = tab;
    };
  })
  .directive('linesPercentage', function() {
    return {
      scope : {
        src : '=',
        total : '='
      },
      template : "<span>{{src}} Lines ({{src/total * 100 | number:2 }}%)</span>"
    }
  })
  .controller('ProfileCtrl', function ($scope) {
    var self = this;
    self.columns = [
      {id: 'volume', name: 'Volume'},
      {id: 'complexity_per_unit', name: 'Complexity per Unit'},
      {id: 'duplication', name: 'Duplication'},
      {id: 'unit_size', name: 'Unit Size'},
      //{id: 'unit_testing', name: 'Unit Testing'}
    ];

    self.rows = [
      {name: 'Analysability', columns: ['volume', 'duplication', 'unit_size', 'unit_testing']},
      {name: 'Changability', columns: ['complexity_per_unit', 'duplication']},
      {name: 'Stability', columns: ['unit_testing']},
      {name: 'Testability', columns: ['complexity_per_unit', 'unit_size', 'unit_testing']}
    ];

    self.getAverage = function (row) {
      var results = row.columns.map(function (id) {
        if ($scope.analysis.profile[id]) {
          return $scope.analysis.profile[id].rating;
        }
      }).filter(function (i) {
        return i != null;
      });
      var sum = 0;
      results.forEach(function (s) {
        sum += s;
      });
      return Math.round(sum / results.length);
    }
  })
  .filter('risk', function () {
    return function (i) {
      switch (i) {
        case 5:
          return '++';
        case 4:
          return '+';
        case 3:
          return 'o';
        case 2:
          return '-';
        case 1:
          return '--';
      }
    };
  });

