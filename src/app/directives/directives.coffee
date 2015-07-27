remote = require('remote')
app = remote.require('app')
youtubedl = require('youtube-dl')

angular.module('directives', ['utils', 'player', 'slider', 'shortcuts'])
