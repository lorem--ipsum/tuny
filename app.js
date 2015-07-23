var fs = require('fs');

function init() {
  angular.element(document.querySelector('[ng-controller]'))
    .injector()
    .get('$youtube')
    .init();
}

function onYouTubeIframeAPIReady() {
  angular.element(document.querySelector('[ng-controller]'))
    .injector()
    .get('$youtubeIFrame')
    .init();
}

angular.module('tuny', [])

.controller('TunyCtrl', function($scope, $window, $youtube, $http, $timeout) {
  $http.get('favourites.json').success(function(data) {
    $scope.originalVideos = data;
    $scope.videos = data.concat();
  });

  var lastPlayedVideo = undefined;
  $scope.playing = false;
  $scope.shuffled = false;
  $scope.videoVisible = false;

  // Shamelessly stolen from http://stackoverflow.com/questions/6274339/how-can-i-shuffle-an-array-in-javascript
  var shuffle = function (o) {
    for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
  }

  $scope.toggleShuffle = function() {
    if ($scope.shuffled) {
      $scope.videos = $scope.originalVideos.concat();
    } else {
      shuffle($scope.videos);
    }
    $scope.shuffled = !$scope.shuffled;
  };

  $scope.playVideo = function(video) {
    $scope.currentVideo = video;
    $scope.playing = true;
  }

  $scope.playPause = function() {
    if (!$scope.currentVideo) {
      $scope.currentVideo = $scope.videos[0];
      $scope.playing = true;
    } else {
      $scope.playing = !$scope.playing;
    }
  };

  $scope.next = function() {
    index = $scope.videos.indexOf($scope.currentVideo);
    newVideo = $scope.videos[(index + 1)%$scope.videos.length];
    if (newVideo.inError === true && $scope.videoVisible === false) {
      $timeout($scope.next);
    } else {
      $scope.currentVideo = newVideo;
    }
  };

  $scope.back = function() {

  };

  $scope.onEnd = function() {
    $scope.next();
  };

  $scope.onError = function() {
    if ($scope.videoVisible === false && $scope.currentVideo) {
      $scope.currentVideo.inError = true;
      $scope.next();
    }
  }
})

.directive('youtubeVideo', function($youtubeIFrame) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      var player = undefined;
      var isReady = false;
      var videoId = undefined;

      var play = function(id) {
        player.loadVideoById(id);
      }

      var onPlayerReady = function(event) {isReady = true;};

      scope.$watch(attrs.isPlaying, function(isPlaying) {
        if (!isReady) {
          return;
        }

        if (isPlaying === true) {
          player.playVideo();
        } else if (isPlaying === false) {
          player.pauseVideo();
        }
      });

      scope.$watch(attrs.youtubeVideo, function(id) {
        if (!isReady) {
          return;
        }

        if (id) {
          play(id);
        } else {
          player.stopVideo();
        }
      }, true);

      var onPlayerStateChange = function(event) {
        if (event.data === YT.PlayerState.ENDED) {
          scope[attrs.onEnd]();
          scope.$apply();
        }
      };

      var onPlayerError = function(event) {
        console.log(event.data, [150, 101].indexOf(event.data))
        if ([150, 101].indexOf(event.data) !== -1) {
          scope[attrs.onError]();
          scope.$apply();
        }
      };

      $youtubeIFrame.then(function(){
        player = new YT.Player(element[0], {
          height: '400',
          width: '600',
          playerVars: {
            controls: 0
          },
          events: {
            'onError': onPlayerError,
            'onReady': onPlayerReady,
            'onStateChange': onPlayerStateChange
          }
        });
      });

    }
  }
})

.service('$youtubeIFrame', function($rootScope) {
  var _callbacks = [];
  var _isLoaded = false;
  return {
    then: function(callback) {_isLoaded && callback() || _callbacks.push(callback);},
    init: function() {
      _callbacks.forEach(function(cb) {cb();});
      _isLoaded = true;
      $rootScope.$apply();
    }
  }
})


.service('$youtube', function($http, $q, $rootScope) {
  var _callbacks = [];
  var _isLoaded = false;
  return {
    then: function(callback) {_isLoaded && callback() || _callbacks.push(callback);},
    init: function() {
      gapi.client.setApiKey('AIzaSyDUwEesNnAiq6t96IUtkA3cx2fzPG4shJ0');
      gapi.client.load('youtube', 'v3', function() {
        _callbacks.forEach(function(cb) {cb();});
        _callbacks = [];
        _isLoaded = true;
        $rootScope.$apply();
      });
    },

    search: function(id) {
      var deferred = $q.defer();

      var request = gapi.client.youtube.search.list({
        id: id,
        part: 'id,snippet'
      });

      request.execute(function(response){
        // console.log(response);
      });

      return deferred.promise;
    }
  }
});
