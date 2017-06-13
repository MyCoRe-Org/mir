module.exports = function(grunt) {
	grunt.loadNpmTasks('grunt-npmcopy');
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
		npmcopy : {
			deps : {
				options : {
					destPrefix : '<%=globalConfig.assetsDirectory%>/'
				},
				files : {
					'highlightjs/css' : 'highlight.js/styles',
					'highlightjs/js' : 'highlight.js/lib/highlight.js'
				},
			}
		}
	});
	grunt.registerTask('none', function() {
	});
	grunt.registerTask('default', 'build assets directory', function() {
		grunt.task.run('npmcopy');
	});
}
