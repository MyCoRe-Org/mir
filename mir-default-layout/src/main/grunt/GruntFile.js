module.exports = function (grunt) {
  grunt.loadNpmTasks('grunt-contrib-less');
  
  var globalConfig = {
  	lessFile: grunt.option('lessFile'),
  	targetDirectory: grunt.option('targetDirectory')
  };
  
  grunt.initConfig({
    globalConfig: globalConfig,
    pkg: grunt.file.readJSON('package.json'),
    banner: '/*!\n' +
            ' * <%= pkg.name %> v<%= pkg.version %>\n' +
            ' * Homepage: <%= pkg.homepage %>\n' +
            ' * Copyright 2013-<%= grunt.template.today("yyyy") %> <%= pkg.author %>\n' +
            ' * Licensed under <%= pkg.license %>\n' +
            ' * Based on Bootstrap and Bootswatch\n' +
            '*/\n',
    mir: {
      readable:{}, spacelab:{}, superhero:{}, yeti:{}
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
          modifyVars: {
            bootswatch_theme: "readable"
          }
        },
        files: {}
      }
    }
  });
  grunt.registerTask('none', function() {});
  grunt.registerTask('build', 'build a regular theme', function(theme, compress) {
    var compress = compress == undefined ? true : compress;

    var concatSrc;
    var concatDest;
    var lessDest;
    var lessSrc;
    var files = {};
    var dist = {};
    lessDest = '<%=globalConfig.targetDirectory%>/' + theme + '.css';
    lessSrc = [ '<%=globalConfig.lessFile%>' ];

    files = {}; files[lessDest] = lessSrc;
    grunt.config('less.dist.files', files);
    grunt.config('less.dist.options.compress', false);
    grunt.config('less.dist.options.modifyVars.bootswatch_theme', theme);
    grunt.log.writeln('compiling file ' + lessSrc + ' ==> ' + lessDest);

    grunt.task.run(['less:dist',
      compress ? 'compress:'+lessDest+':'+'<%=globalConfig.targetDirectory%>/' + theme + '.min.css':'none']);
  });

  grunt.registerTask('compress', 'compress a generic css', function(fileSrc, fileDst) {
    var files = {}; files[fileDst] = fileSrc;
    grunt.log.writeln('compressing file ' + fileSrc);

    grunt.config('less.dist.files', files);
    grunt.config('less.dist.options.compress', true);
    grunt.task.run(['less:dist']);
  });

  grunt.registerMultiTask('mir', 'build a theme', function() {
    var t = this.target;
    grunt.task.run('build:'+t);
  });

  grunt.registerTask('default', 'build a theme', function() {
    grunt.task.run('mir');
  });
	
}