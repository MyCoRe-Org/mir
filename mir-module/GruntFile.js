module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-npmcopy');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  var fs = require('fs');
  var path = require('path');
  var util = require('util');
  var getAbsoluteDir = function(dir) {
    return path.isAbsolute(dir) ? dir : path.resolve(process.cwd(), dir);
  };
  grunt.initConfig({
    globalConfig : {
        assetsDirectory : getAbsoluteDir(grunt.option('assetsDirectory')),
        assetsDirectoryRelative : path.basename(grunt.option('assetsDirectory')),
        moduleDirectory: grunt.option('moduleDirectory')
    },
    npmcopy : {
      deps : {
        options : {
          destPrefix : '<%=globalConfig.assetsDirectory%>/'
        },
        files : {
          'bootstrap/js' : 'bootstrap/dist/js',
          'ckeditor4' : 'ckeditor4/',
          'ckeditor4/plugins/notification/' : 'ckeditor-notification-plugin',
          'ckeditor4/plugins/wordcount/' : 'ckeditor-wordcount-plugin/wordcount',

          'font-awesome/css' : '@fortawesome/fontawesome-free/css',
          'font-awesome/webfonts' : '@fortawesome/fontawesome-free/webfonts',

          'jquery' : 'jquery/dist',

          'jquery/plugins/jquery-confirm' : 'myclabs.jquery.confirm/jquery.confirm.min.js',
          'jquery/plugins/jquery-placeholder' : 'jquery.placeholder/jquery.placeholder.min.js',
          'jquery/plugins/typeahead' : 'typeahead.js/dist/bloodhound.min.js',
          'jquery/plugins/bootstrap3-typeahead' : 'bootstrap-3-typeahead/bootstrap3-typeahead.min.js',

          'bootstrap-datepicker/js':'bootstrap-datepicker/dist/js/',
          'bootstrap-datepicker/css':'bootstrap-datepicker/dist/css/',
          'bootstrap-datepicker/locales':'bootstrap-datepicker/dist/locales/',

          'moment' : 'moment/',

          'handlebars': 'handlebars/dist/handlebars.min.js',

          'openlayers' : 'openlayers/dist',

          'videojs/js': 'video.js/dist/video.min.js',
          'videojs/css': 'video.js/dist/video-js.min.css',
          'videojs-contrib-hls': 'videojs-contrib-hls/dist/videojs-contrib-hls.min.js',

          'select2/js': 'select2/dist/js',
          'select2/css': 'select2/dist/css/select2.min.css',

          'vue':'vue/dist/'
        },
      }
    },
    uglify: {
      mir: {
        mangle: false,
        options: {
          sourceMap: {
              includeSources : true
          }
        },
        files: {
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/mir/base.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/mir/base.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/mir/derivate-fileList.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/mir/derivate-fileList.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/mir/relatedItem-modal.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/mir/relatedItem-modal.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/mir/relatedItem-autocomplete.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/mir/relatedItem-autocomplete.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/mir/xeditor-form.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/mir/xeditor-form.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/mir/ror-search.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/mir/ror-search.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/mir/openaire.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/mir/openaire.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/mir/classification-modal-select.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/mir/classification-modal-select.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/mir/geo-coords.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/mir/geo-coords.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/mir/select-doctype.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/mir/select-doctype.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/mir/citation.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/mir/citation.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/jquery.search-entity.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/jquery.search-entity.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/epusta.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/epusta.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/assets/ckeditor4/config.min.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/ckeditor-config.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/mir/bootstrap-datepicker-timepicker/bootstrap-datepicker-timepicker.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/mir/bootstrap-datepicker-timepicker/bootstrap-datepicker-timepicker.js',
          '<%= globalConfig.moduleDirectory %>/target/classes/META-INF/resources/js/mir/bootstrap-datepicker-timepicker/bootstrap-datepicker-timepicker.de.js': '<%= globalConfig.moduleDirectory %>/src/main/resources/META-INF/resources/js/mir/bootstrap-datepicker-timepicker/bootstrap-datepicker-timepicker.de.js',
        }
      }
    },
  });
  grunt.registerTask('copy', function() {
    const source = getAbsoluteDir(grunt.option('moduleDirectory'))+'/src/main/resources/META-INF/resources/js/ckeditor-config.js';
    const target = getAbsoluteDir(grunt.option('assetsDirectory')) + '/ckeditor4/config.js';
    fs.copyFile(source, target, (err) => {
      if (err) {
        throw err;
      }
      grunt.log('ckeditor config copied!');
    });
  });
  grunt.registerTask('none', function() {
  });
  grunt.registerTask('default', 'build assets directory', function() {
    grunt.task.run('npmcopy');
    grunt.task.run('copy');
    grunt.task.run('uglify');
  });
};
