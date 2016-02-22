module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-bowercopy');
  var fs = require('fs');
  var path = require('path');
  var util = require('util');
  var getAbsoluteDir = function(dir) {
    return path.isAbsolute(dir) ? dir : path.resolve(process.cwd(), dir);
  }
  var globalConfig = {
    assetsDirectory : getAbsoluteDir(grunt.option('assetsDirectory')),
    assetsDirectoryRelative : path.basename(grunt.option('assetsDirectory')),
  };
  grunt.initConfig({
    globalConfig : globalConfig,
    bowercopy : {
      deps : {
        options : {
          destPrefix : '<%=globalConfig.assetsDirectory%>/'
        },
        files : {
          'bootstrap/css' : 'bootstrap/dist/css',
          'bootstrap/fonts' : 'bootstrap/dist/fonts',
          'bootstrap/js' : 'bootstrap/dist/js',

          'font-awesome/css' : 'font-awesome/css',
          'font-awesome/fonts' : 'font-awesome/fonts',

          'jquery' : 'jquery/dist',

          'jquery/plugins/jquery-confirm' : 'jquery-confirm/*.js',
          'jquery/plugins/jquery-placeholder' : 'jquery.placeholder/*.js',
          'jquery/plugins/typeahead' : 'typeahead.js/dist/*.js',
          'jquery/plugins/bootstrap3-typeahead' : 'bootstrap3-typeahead/bootstrap*.js',
          'jquery/plugins/shariff' : 'shariff/build',
          'jquery/plugins/dotdotdot' : 'jQuery.dotdotdot/src/js',

          'bootstrap-datepicker/js':'bootstrap-datepicker/dist/js/',
          'bootstrap-datepicker/css':'bootstrap-datepicker/dist/css/',
          'bootstrap-datepicker/locales':'bootstrap-datepicker/dist/locales/',

          'moment' : 'moment/',

          'handlebars': 'handlebars/'
        },
      }
    }
  });
  grunt.registerTask('none', function() {
  });
  grunt.registerTask('default', 'build assets directory', function() {
    grunt.task.run('bowercopy');
  });
}
