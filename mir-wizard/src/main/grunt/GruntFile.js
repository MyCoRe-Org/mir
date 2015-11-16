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
					'highlightjs/css' : 'highlightjs/styles',
					'highlightjs/js' : 'highlightjs/*.js'
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
