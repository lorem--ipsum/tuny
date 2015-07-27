angular.module('slider', [])

.directive 'timeSlider', (timeUtils) ->
  return {
    replace: true
    scope: {
      duration: '='
      currentTime: '='
    }
    link: (scope, element,attrs) ->
      scope.getLeft = -> (scope.currentTime/scope.duration)*100 + '%'
      scope.labelize = timeUtils.durationToString
      return
    template: """<div class="time-slider">
      <div class="label">{{labelize(currentTime)}}</div>
      <div class="track-container">
        <div class="track"></div>
        <div class="thumb" ng-style="{left: getLeft()}"></div>
      </div>
      <div class="label">{{labelize(duration)}}</div>
    </div>"""
  }
