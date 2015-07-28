remote = require('remote')
app = remote.require('app')
youtubedl = require('youtube-dl')

angular.module('directives', ['utils', 'player', 'slider', 'shortcuts', 'switch'])

.directive 'focusWhenTrue', ($timeout) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    scope.$watch attrs.focusWhenTrue, (v) ->
      if !!v
        $timeout -> element[0].focus()
      else
        $timeout -> element[0].blur()
