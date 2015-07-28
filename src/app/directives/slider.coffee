angular.module('slider', [])

.directive 'timeSlider', (timeUtils) ->
  return {
    replace: true
    scope: {
      duration: '='
      currentTime: '='
    }
    link: (scope, element,attrs) ->
      scope.getElapsedPercentage = -> (scope.currentTime/scope.duration)*100 + '%'
      scope.labelize = timeUtils.durationToString
      return
    template: """<div class="time-slider">
      <!--<div class="label">{{labelize(currentTime)}}</div>-->
      <div class="track-container" ng-style="{width: getElapsedPercentage()}">
        <div class="track"></div>
        <div class="thumb"></div>
      </div>
      <!--<div class="label">{{labelize(duration)}}</div>-->
    </div>"""
  }
