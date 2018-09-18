module.exports = function(grunt) {
	grunt.loadNpmTasks('grunt-contrib-concat');
	grunt.loadNpmTasks('grunt-replace');
	grunt.loadNpmTasks('grunt-npmcopy');

    const fs = require('fs');
    const path = require('path');
    const util = require('util');

    const getAbsoluteDir = function(dir) {
        return path.isAbsolute(dir) ? dir : path.resolve(process.cwd(), dir);
    };

    const globalConfig = {
        projectBase: getAbsoluteDir(grunt.option('projectBase')),
        targetDirectory : getAbsoluteDir(grunt.option('targetDirectory')),
        assetsDirectory : getAbsoluteDir(grunt.option('assetsDirectory')),
        assetsDirectoryRelative : path.basename(grunt.option('assetsDirectory'))
    };

    const layouts = ["flatmir", "cosmol"];
    const templates = ["cerulean", "cosmo", "cyborg", "darkly", "flatly", "journal", "lumen", "paper", "readable",
        "sandstone", "simplex", "slate", "spacelab", "superhero", "united", "yeti"];


    grunt.initConfig({
		globalConfig : globalConfig,
		pkg : grunt.file.readJSON('package.json'),
		banner : '/*!\n' + ' * <%= pkg.name %> v${project.version}\n' + ' * Homepage: <%= pkg.homepage %>\n'
				+ ' * Copyright 2013-<%= grunt.template.today("yyyy") %> <%= pkg.author %> and others\n' + ' * Licensed under <%= pkg.license %>\n'
				+ ' * Based on Bootstrap and Bootswatch\n' + '*/\n',

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
        npmcopy : {
			deps : {
				options : {
					destPrefix : '<%=globalConfig.assetsDirectory%>/'
				},
				files : {
					'jquery' : 'jquery/dist',
					'jquery/plugins/jquery-migrate' : 'jquery-migrate/dist/',
                    'jquery/plugins/shariff' : 'shariff/dist',
                'bootswatch': 'bootswatch',
                'bootstrap':'bootstrap-sass/assets'
				}
			}
		}
	});

    grunt.registerTask('default', 'build a theme', function() {
        //grunt.task.run('replace');
        grunt.task.run('npmcopy');
        grunt.task.run("buildTemplates");
    });

    grunt.registerTask('buildTemplates', function () {
        const sassFolder = "META-INF/resources/mir-layout/scss/";

        const done = this.async();

        fs.readFile(globalConfig.projectBase + "/src/main/resources/" + sassFolder + "/template.scss.template", 'utf8', function (err, data) {
            if (err) {
                done();
                return grunt.log.errorlns(err);
            }

            let layoutTemplate = [];
            for (const layout of layouts) {
                for (const template of templates) {
                    layoutTemplate.push([layout, template]);
                }
            }
            grunt.util.async.eachSeries(layoutTemplate, function (el, next) {
                const layout = el[0];
                const template = el[1];

                let result = data
                    .replace(/%layout%/g, layout)
                    .replace(/%template%/g, template);

                const fileName = layout + "-" + template + ".scss";
                const templResultPath = globalConfig.projectBase + "/target/classes/" + sassFolder + "/" + fileName;
                fs.writeFile(templResultPath, result, function (err) {
                    if (err) {
                        return grunt.log.errorlns(err);
                    }
                    grunt.log.writeln("Wrote: " + fileName);
                    next();
                });
            }, done);
        });
    });

};
