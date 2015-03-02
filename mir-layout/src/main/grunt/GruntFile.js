module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-replace');
  grunt.loadNpmTasks('grunt-contrib-watch');
  var fs = require('fs');
  var path = require('path');
  var util = require('util');
  var getAbsoluteDir = function(dir) {
    return path.isAbsolute(dir) ? dir : path.resolve(process.cwd(), dir);
  }
  var globalConfig = {
    lessDirectory : getAbsoluteDir(path.join('..', '..', 'src', 'main', 'less')),
    targetDirectory : getAbsoluteDir(grunt.option('targetDirectory')),
    layouts : {
      "cosmol" : {},
      "flatmir" : {}
    }
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
  var needRebuild = function(srcModified, dest) {
    var destModified = fs.existsSync(dest) ? fs.statSync(dest).mtime : new Date(0);
    return srcModified.getTime() > destModified.getTime();
  };
  var updateLayout = function(layout) {
    if (layout == undefined) {
      for ( var layout in grunt.config('globalConfig').layouts) {
        updateLayout(layout);
      }
      console.log(util.inspect(globalConfig.layouts));
    }
    var layoutDir = path.resolve(grunt.config('globalConfig.lessDirectory'), layout);
    var layoutInfo = {
      "srcDir" : layoutDir,
      lastModified : dirLastModified(layoutDir, dirLastModified('bower_components'))
    }
    globalConfig.layouts[layout] = layoutInfo;
  };

  var compileLess = function(layout, theme, compress) {
    var themePrefix = grunt.config('globalConfig.targetDirectory') + '/' + layout + '/' + theme;
    var target = themePrefix + '.css';
    var lessSrc = [ '<%=globalConfig.lessDirectory%>' + '/' + layout + '/build.less' ];
    var srcModified = grunt.config('globalConfig.layouts')[layout].lastModified;
    if (needRebuild(srcModified, target)) {
      var compress = compress == undefined ? true : compress;

      var concatSrc;
      var concatDest;
      var lessDest;
      var files = {};
      var dist = {};
      lessDest = 'build.css';
      concatSrc = lessDest;
      concatDest = themePrefix + '.css';
      dist = {
        src : concatSrc,
        dest : concatDest
      };
      grunt.config('concat.dist', dist);

      files = {};
      files[lessDest] = lessSrc;
      grunt.config('less.dist.files', files);
      grunt.config('less.dist.options.compress', false);
      grunt.config('less.dist.options.cleancss', false);
      grunt.config('less.dist.options.modifyVars.bootswatch_theme', theme);
      grunt.config('less.dist.options.sourceMap', true);
      grunt.config('less.dist.options.sourceMapURL', theme + '.css.map');
      grunt.config('less.dist.options.sourceMapFilename', themePrefix + '.css.map');
      grunt.config('less.dist.options.fileSrc', concatDest);
      grunt.config('less.dist.options.fileDst', themePrefix + '.min.css');
      grunt.log.writeln('compiling file ' + lessSrc + ' ==> ' + lessDest);

      grunt.task.run([ 'less:dist', 'concat',
          compress ? 'compress' : 'none' ]);
    } else {
      grunt.log.writeln('do not need to rebuild ' + target);
    }
  };

  grunt.initConfig({
    globalConfig : globalConfig,
    pkg : grunt.file.readJSON('package.json'),
    bootstrap : grunt.file.readJSON('bower_components/bootstrap/package.json'),
    banner : '/*!\n' + ' * <%= pkg.name %> v${project.version}\n' + ' * Homepage: <%= pkg.homepage %>\n'
        + ' * Copyright 2013-<%= grunt.template.today("yyyy") %> <%= pkg.author %> and others\n'
        + ' * Licensed under <%= pkg.license %>\n' + ' * Based on Bootstrap and Bootswatch\n' + '*/\n',
    mir : {
      cerulean : {},
      cosmo : {},
      cyborg : {},
      "default" : {},
      darkly : {},
      flatly : {},
      journal : {},
      lumen : {},
      paper: {},
      readable : {},
      sandstone : {},
      simplex : {},
      slate : {},
      spacelab : {},
      superhero : {},
      united : {},
      yeti : {}
    },
    replace : {
      dist : {
        options : {
          patterns : [
          // resolve css from google fonts on build time
          {
            match : /@import url\("\/\/fonts/,
            replacement : '@import (inline) url("http://fonts'
          } ]
        },
        files : [ {
          expand : true,
          // flatten: true,
          src : [ 'bower_components/bootswatch/*/bootswatch.less' ],
        // dest: 'build/'
        } ]
      }
    },
    concat : {
      options : {
        banner : '<%= banner %>',
        stripBanners : false
      },
      dist : {
        src : [],
        dest : ''
      }
    },
    less : {
      dist : {
        options : {
          compress : false,
          cleancss : false,
          ieCompat : false,
          sourceMap : true,
          sourceMapURL : "",
          sourceMapFilename : "",
          outputSourceFiles : true,
          modifyVars : {
            bootswatch_theme : "default",
            "icon-font-path" : "'//netdna.bootstrapcdn.com/bootstrap/<%= bootstrap.version %>/fonts/'",
          }
        },
        files : {}
      }
    },
    watch : {
      styles : {
        files : [ '../../src/main/less/**/*.less' ] // which files to watch
      }
    }
  });
  grunt.registerTask('none', function() {
  });
  grunt.registerTask('build', 'build a regular theme', function(layout, theme, compress) {
    compileLess(layout, theme, compress);
  });

  grunt.registerTask('compress', 'compress a generic css', function() {
    var fileSrc =  grunt.config('less.dist.options.fileSrc');
    var fileDst =  grunt.config('less.dist.options.fileDst');
    var files = {};
    files[fileDst] = fileSrc;
    grunt.log.writeln('compressing file ' + fileSrc);

    grunt.config('less.dist.files', files);
    grunt.config('less.dist.options.compress', true);
    grunt.config('less.dist.options.cleancss', true);
    grunt.config('less.dist.options.sourceMap', false);
    grunt.task.run([ 'less:dist' ]);
  });

  grunt.registerMultiTask('mir', 'build a theme', function() {
    var t = this.target;

    for ( var layout in grunt.config('globalConfig').layouts) {
      grunt.task.run('build:' + layout + ":" + t);
    }
  });

  grunt.registerTask('default', 'build a theme', function() {
    grunt.log.writeln('less directory: ' + grunt.config('globalConfig').lessDirectory);
    grunt.task.run('replace');
    createFileIfNotExist('bower_components/bootswatch/default/variables.less');
    createFileIfNotExist('bower_components/bootswatch/default/bootswatch.less');
    updateLayout();
    grunt.task.run('mir');
  });

  grunt.registerTask('reBuild', 'rebuild files if necessary', function() {
    updateLayout();
    createFileIfNotExist('bower_components/bootswatch/default/variables.less');
    createFileIfNotExist('bower_components/bootswatch/default/bootswatch.less');
    grunt.task.run('mir');
  });

  grunt.registerTask('watch-forAll', function () {
    grunt.config.merge({
      watch: {
        styles : {
          tasks : [ 'reBuild' ],
        }
      }
    });
    grunt.task.run('watch');
  });

  grunt.registerTask('watch-forCosmoL', function () {
    grunt.config.merge({
      watch: {
        styles : {
          tasks : [ 'reBuildCosmoL' ],
        }
      }
    });
    grunt.task.run('watch');
  });

  grunt.registerTask('watch-forFlatMIR', function () {
    grunt.config.merge({
      watch: {
        styles : {
          tasks : [ 'reBuildFlatMIR' ],
        }
      }
    });
    grunt.task.run('watch');
  });

  grunt.registerTask('reBuildCosmoL', 'rebuild cosmol files if necessary', function() {
    updateLayout();
    compileLess('cosmol', 'cosmo', true);
  });

  grunt.registerTask('reBuildFlatMIR', 'rebuild flatmir files if necessary', function() {
    updateLayout();
    compileLess('flatmir', 'flatly', true);
  });

}
