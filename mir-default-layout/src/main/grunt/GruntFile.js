module.exports = function (grunt) {
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-replace');
  var fs = require('fs');
  var globalConfig = {
    lessFile : grunt.option('lessFile'),
    lessDirectory : function() {
      var lessFile = grunt.config('globalConfig.lessFile');
      return lessFile.substring(0, Math.max(lessFile.lastIndexOf("/"), lessFile.lastIndexOf("\\")));
    },
    targetDirectory : grunt.option('targetDirectory'),
    lastModified:new Date(0)
  };
  var dirLastModified = function(dir, date) {
    var src = grunt.file.expand(dir + '/**/*.less');
    var modified = [];
    src.forEach(function(file, index) {
      var stat = fs.statSync(file);
      modified[index] = stat.mtime;
    });
    return new Date(Math.max.apply(Math, modified));
  };
  var createFileIfNotExist = function(filepath) {
    if (!grunt.file.exists(filepath)) {
      grunt.file.write(filepath);
    }
  };
  var needRebuild=function(dest){
    var destModified = fs.existsSync(dest) ? fs.statSync(dest).mtime : new Date(0);
    var srcModified = grunt.config('globalConfig.lastModified');
    return srcModified.getTime() > destModified.getTime();
  }
  
  grunt.initConfig({
    globalConfig: globalConfig,
    pkg: grunt.file.readJSON('package.json'),
    bootstrap: grunt.file.readJSON('bower_components/bootstrap/package.json'),
    banner: '/*!\n' +
            ' * <%= pkg.name %> v${project.version}\n' +
            ' * Homepage: <%= pkg.homepage %>\n' +
            ' * Copyright 2013-<%= grunt.template.today("yyyy") %> <%= pkg.author %> and others\n' +
            ' * Licensed under <%= pkg.license %>\n' +
            ' * Based on Bootstrap and Bootswatch\n' +
            '*/\n',
    mir: {
      amelia:{}, cerulean:{}, cosmo:{}, cyborg:{}, "default":{},
      flatly:{}, journal:{}, lumen:{}, readable:{},
      simplex:{}, slate:{}, spacelab:{}, superhero:{},
      united:{}, yeti:{}
    },
    replace: {
      dist: {
        options: {
          patterns:[
            // resolve css from google fonts on build time
            {
              match: /@import url\("\/\/fonts/,
              replacement: '@import (inline) url("http://fonts'
            }
          ]
        },
        files: [
           {
             expand: true,
             // flatten: true,
             src: ['bower_components/bootswatch/*/bootswatch.less'],
             // dest: 'build/'
           }
        ]
      }
    },
    concat: {
      options: {
        banner: '<%= banner %>',
        stripBanners: false
      },
      dist: {
        src: [],
        dest: ''
      }
    },
    less: {
      dist: {
        options: {
          compress: false,
          cleancss: false,
          ieCompat: false,
          sourceMap: true,
          sourceMapURL: "",
          sourceMapFilename: "",
          outputSourceFiles: true,
          modifyVars: {
            bootswatch_theme: "readable",
            "icon-font-path": "'//netdna.bootstrapcdn.com/bootstrap/<%= bootstrap.version %>/fonts/'",
          }
        },
        files: {}
      }
    }
  });
  grunt.registerTask('none', function() {});
  grunt.registerTask('build', 'build a regular theme', function(theme, compress) {
    var target=grunt.config('globalConfig.targetDirectory')+'/'+theme+'.css';
    if (needRebuild(target)){
      var compress = compress == undefined ? true : compress;
      
      var concatSrc;
      var concatDest;
      var lessDest;
      var lessSrc;
      var files = {};
      var dist = {};
      lessDest = 'build.css';
      lessSrc = [ '<%=globalConfig.lessFile%>' ];
      concatSrc = lessDest;
      concatDest = '<%=globalConfig.targetDirectory%>/'+ theme + '.css';
      dist = {src: concatSrc, dest: concatDest};
      grunt.config('concat.dist', dist);
      
      files = {}; files[lessDest] = lessSrc;
      grunt.config('less.dist.files', files);
      grunt.config('less.dist.options.compress', false);
      grunt.config('less.dist.options.cleancss', false);
      grunt.config('less.dist.options.modifyVars.bootswatch_theme', theme);
      grunt.config('less.dist.options.sourceMap', true);
      grunt.config('less.dist.options.sourceMapURL', theme + '.css.map');
      grunt.config('less.dist.options.sourceMapFilename', '<%=globalConfig.targetDirectory%>/' + theme + '.css.map');
      grunt.log.writeln('compiling file ' + lessSrc + ' ==> ' + lessDest);
      
      grunt.task.run(['less:dist', 'concat',
                      compress ? 'compress:'+concatDest+':'+'<%=globalConfig.targetDirectory%>/' + theme + '.min.css':'none']);
    } else {
      grunt.log.writeln('do not need to rebuild '+target);
    }
  });

  grunt.registerTask('compress', 'compress a generic css', function(fileSrc, fileDst) {
    var files = {}; files[fileDst] = fileSrc;
    grunt.log.writeln('compressing file ' + fileSrc);

    grunt.config('less.dist.files', files);
    grunt.config('less.dist.options.compress', true);
    grunt.config('less.dist.options.cleancss', true);
    grunt.config('less.dist.options.sourceMap', false);
    grunt.task.run(['less:dist']);
  });

  grunt.registerMultiTask('mir', 'build a theme', function() {
    var t = this.target;
    grunt.task.run('build:'+t);
  });

  grunt.registerTask('default', 'build a theme', function() {
    grunt.log.writeln('less directory: '+grunt.config('globalConfig').lessDirectory());
    grunt.task.run('replace');
    grunt.config(
        'globalConfig.lastModified',
        new Date(
            Math.max(
                dirLastModified(grunt.config('globalConfig').lessDirectory()),
                dirLastModified('bower_components')
            )
        )
    );
    createFileIfNotExist('bower_components/bootswatch/default/variables.less');
    createFileIfNotExist('bower_components/bootswatch/default/bootswatch.less');
    grunt.task.run('mir');
  });
	
}