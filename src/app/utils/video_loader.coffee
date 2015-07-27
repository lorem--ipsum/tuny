angular.module('youtube', [])

.service 'videoLoader', ($q) ->
  return {
    load: (id) ->
      name = $q.defer()
      data = $q.defer()

      tmp = app.getPath('cache') + '/Tuny/'

      loadStuff = ->
        youtubedl.getInfo(
          id
          ['-f 141/171/140', '--restrict-filenames', '--get-filename']
          {}
          (err, info) ->
            if err?
              name.reject(err)
              return

            name.resolve(tmp + info._filename.trim())

            petite = youtubedl(
              id
              ['-f 141/171/140', '--restrict-filenames']
              {cwd: tmp}
              (err, output) -> if error? then data.reject(error) else data.resolve()
            )

            petite
              .pipe(fs.createWriteStream(tmp + info._filename.trim()))
              .on('close', -> data.resolve())
        )
      fs.exists(tmp, (exists) -> if exists then loadStuff() else fs.mkdir(tmp, loadStuff))

      return $q.all([name.promise, data.promise])
    }
