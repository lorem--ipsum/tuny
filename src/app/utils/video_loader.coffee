angular.module('youtube', [])

.service 'videoLoader', ($q) ->
  return {
    getInfo :(urlOrId) ->
      deferred = $q.defer()

      youtubedl.getInfo urlOrId, [], {}, (err, info) ->
        if err
          deferred.reject(err)
          console.error(err)
          return

        deferred.resolve({id: info.id, title: info.title})

      return deferred.promise

    load: (id) ->
      name = $q.defer()
      data = $q.defer()

      tmp = app.getPath('cache') + '/Tuny/'

      loadStuff = ->
        youtubedl.getInfo(
          id
          ['-f 141/171/140', '--restrict-filenames', '--get-filename', '--verbose']
          {}
          (err, info) ->
            console.log('A', err, info)
            if err?
              console.error(err)
              name.reject(err)
              return

            name.resolve(tmp + info._filename.trim())

            petite = youtubedl(
              id
              ['-f 141/171/140', '--restrict-filenames']
              {cwd: tmp}
              (err, output) ->
                console.log('B', err, output)
                if error?
                  console.error(err)

                else
                  data.resolve()
            )

            petite
              .pipe(fs.createWriteStream(tmp + info._filename.trim()))
              .on('close', -> data.resolve())
        )
      fs.exists(tmp, (exists) -> if exists then loadStuff() else fs.mkdir(tmp, loadStuff))

      return $q.all([name.promise, data.promise])
    }
