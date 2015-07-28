angular.module('switch', [])

.directive 'switch', (timeUtils) ->
  return {
    replace: true
    transclude: true
    require: 'ngModel'
    scope: {

    }
    link: (scope, element, attrs, ngModel) ->
      scope.ngModel = ngModel

      scope.toggle = ->
        ngModel.$setViewValue(!ngModel.$viewValue);
        return


      return
    template: """<div class="switch" ng-click="toggle()" ng-class="{on: ngModel.$viewValue}">
      <div class="track-container">
        <div class="track"></div>
        <div class="thumb" ng-transclude></div>
      </div>
    </div>"""
  }
