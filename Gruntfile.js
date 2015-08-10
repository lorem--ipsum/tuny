module.exports = function(grunt) {

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-exec');

  var pkg = grunt.file.readJSON('package.json');

  grunt.initConfig({

    electronDir: 'Tuny.app/Contents/Resources/app',

    coffee: {
      dist: {
        options: {bare: true},
        files: {
          '<%= electronDir %>/app.js': ['src/app/**/*.coffee'],
          '<%= electronDir %>/main.js': ['src/main.coffee']
        }
      }
    },

    sass: {
      dist: {
        options: {style: 'expanded', sourcemap: 'none'},
        files: {'<%= electronDir %>/app.css': 'src/styles/app.scss'}
      }
    },

    copy: {
      html: {
        files: [{expand: true, cwd: 'src/', src: 'index.html', dest: '<%= electronDir %>/'}]
      },
      node_modules: {
        files: [{
          expand: true, src: '**', cwd: 'node_modules', dest: '<%= electronDir %>/node_modules/',
          filter: function(filePath) {
            return !!pkg.dependencies[filePath.replace(/^node_modules\/([^/]+)\/.*$/, '$1')];
          }
        }]
      },
      package_json: {
        files: [{src: 'package.json', dest: '<%= electronDir %>//'}]
      },
      assets: {
        files: [{expand: true, cwd: 'src/app/', src: 'assets/**/*', dest: '<%= electronDir %>/'}]
      }
    },

    watch: {
      coffee: {
        files: ['src/**/*.coffee'],
        tasks: ['coffee']
      },
      sass: {
        files: ['src/styles/**/*.scss'],
        tasks: ['sass']
      },
      package_json: {
        files: ['package.json'],
        tasks: ['copy:package_json']
      },
      html: {
        files: ['src/index.html'],
        tasks: ['copy:html']
      }
    },

    exec: {
      compress: {
        cmd: function() {
          return 'ditto -c -k --sequesterRsrc --keepParent Tuny.app Tuny-' + pkg.version + '.app.zip';
        }
      }
    }
  });


  grunt.registerTask('default', ['coffee', 'sass', 'copy']);
  grunt.registerTask('build', ['default', 'exec:compress']);
  grunt.registerTask('w', ['default', 'watch']);
};
