remote = require('remote')
globalShortcut = remote.require('global-shortcut')

angular.module('shortcuts', [])

.service '$shortcuts', ($commands, $rootScope) ->
  return {
    register: (acc, command) ->
      return if !acc

      globalShortcut.register acc, ->
        $commands.trigger(command)
        $rootScope.$apply()
        return
      return

    unregisterAll: ->
      globalShortcut.unregisterAll()
  }

.directive 'shortcutItem', ($shortcuts) ->
  return {
    restrict: 'E'
    replace: true
    scope: {shortcut: '='}
    link: (scope, element, attrs) ->
      return
    template: """
      <div class="shortcut-item">
        <div class="label">{{shortcut.label}}</div>
        <input class="accelerator" ng-model="shortcut.acc">
      </div>
    """
  }

.directive 'shortcutsEditor', ($settings, $shortcuts) ->
  return {
    restrict: 'E'
    scope: {open: '='}
    replace: true
    link: (scope, element, attrs) ->
      scope.shortcuts = [
        {label: 'Play', key: 'play', command: 'keyboard:play', acc: undefined}
        {label: 'Next', key: 'next', command: 'keyboard:next', acc: undefined}
        {label: 'Previous', key: 'previous', command: 'keyboard:previous', acc: undefined}
      ]

      $settings.get('shortcuts').then (shortcuts) ->
        accelerators = JSON.parse(shortcuts or "{}")

        scope.shortcuts.forEach (shortcut) ->
          shortcut.acc = accelerators[shortcut.key]
          $shortcuts.register(shortcut.acc, shortcut.command)

        return

      scope.cancel = ->
        scope.open = false

      scope.save = ->
        $shortcuts.unregisterAll()

        accelerators = {}
        scope.shortcuts.forEach ({key, acc, command}) ->
          $shortcuts.register(acc, command) if acc?
          accelerators[key] = acc

        $settings.set('shortcuts', JSON.stringify(accelerators, null, 2)).then ->
          scope.open = false
        return

      return
    template: """
    <div class="shortcuts-editor" ng-class="{open: open}">
      <div class="title">System wide shortcuts
        <a class="dark help-button" class="dark" target="_blank" href="https://github.com/atom/electron/blob/master/docs/api/accelerator.md">
          <i class="fa fa-question"></i>
        </a>
      </div>
      <shortcut-item ng-repeat="s in shortcuts" shortcut="s"></shortcut-item>
      <div class="buttons">
        <button class="dark cancel" ng-click="cancel()">Cancel</button>
        <button class="dark save" ng-click="save()">Save</button>
      </div>
    </div>
    """
  }
