module.exports = function(grunt) {

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.initConfig({
    electronDir: 'Tuny.app/Contents/Resources/app',

    coffee: {
      dist: {
        options: {bare: true},
        files: {
          '<%= electronDir %>/app.js': ['src/app/*.coffee'],
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
        files: [{expand: true, src: 'node_modules/**', dest: '<%= electronDir %>/'}]
      },
      package_json: {
        files: [{src: 'package.json', dest: '<%= electronDir %>//'}]
      }
    },

    watch: {
      coffee: {
        files: ['src/**/*.coffee'],
        tasks: ['coffee']
      },
      sass: {
        files: ['src/styles/*.scss'],
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

  });


  grunt.registerTask('default', ['coffee', 'sass', 'copy']);
  grunt.registerTask('w', ['default', 'watch']);

};
