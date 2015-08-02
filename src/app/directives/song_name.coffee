"use strict"

angular.module('songName', [])

.directive 'songName', ->
  return {
    restrict: 'E'
    replace: true
    scope: {song: '='}
    link: (scope, element, attrs) ->
      scope.$watch 'song', (song) ->
        scope.artist = undefined
        scope.title = undefined

        return unless song?

        bits = song.title.split(/\s*-\s*/)

        if bits.length > 1
          scope.artist = bits.shift()
          scope.title = bits.join(' - ')

    template: """
      <div class="song-name">
        <div ng-show="!artist" class="song-name" ng-bind="song.title || 'Tuny'"></div>
        <div ng-show="title" class="song-title" ng-bind="title"></div>
        <div ng-show="artist" class="song-artist" ng-bind="artist"></div>
      </div>
    """
  }
