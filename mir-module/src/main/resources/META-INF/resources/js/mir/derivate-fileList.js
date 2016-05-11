(function() {
	$(document).ready(function() {
		if ($(".file_box_files").length > 0) {
			Handlebars.registerHelper('is', function(a, b, options) {
				if (a == b) {
					return options.fn(this);
				}
				return options.inverse(this);
			});
			Handlebars.registerHelper('isOr', function(a, b, options) {
				if (a || b) {
					return options.fn(this);
				}
				return options.inverse(this);
			});
			Handlebars.registerHelper('isNot', function(a, b, options) {
				if (a != b) {
					return options.fn(this);
				}
				return options.inverse(this);
			});
			Handlebars.registerHelper('contains', function(a, b, options) {
				if (a.indexOf(b) > -1) {
					return options.fn(this);
				}
				return options.inverse(this);
			});
			Handlebars.registerHelper('endsWith', function(a, b, options) {
				if (a.substr(-b.length) === b) {
					return options.fn(this);
				}
				return options.inverse(this);
			});
			Handlebars.registerHelper("formatFileSize", function(input) {
				return toReadableSize(input, 0);
			});
			Handlebars.registerHelper("formatDate", function(input) {
				var lang = $("html").attr("lang");
				if (lang == "en") {
					return moment(input).format("YYYY-MM-DD");
				}
				return moment(input).format('DD.MM.YYYY');
			});
			Handlebars.registerHelper('paginate', function(pagination, options) {
				var type = options.hash.type || 'middle';
				var ret = '';
				var pageCount = Number(pagination.pageCount);
				var page = Number(pagination.page);
				var limit;
				if (options.hash.limit)
					limit = +options.hash.limit;

				// page pageCount
				var newContext = {};
				switch (type) {
				case 'middle':
					if (typeof limit === 'number') {
						var i = 0;
						var leftCount = Math.ceil(limit / 2) - 1;
						var rightCount = limit - leftCount - 1;
						if (page + rightCount > pageCount)
							leftCount = limit - (pageCount - page) - 1;
						if (page - leftCount < 1)
							leftCount = page - 1;
						var start = page - leftCount;

						while (i < limit && i < pageCount) {
							newContext = {
								n : start
							};
							if (start === page)
								newContext.active = true;
							ret = ret + options.fn(newContext);
							start++;
							i++;
						}
					} else {
						for (var i = 1; i <= pageCount; i++) {
							newContext = {
								n : i
							};
							if (i === page)
								newContext.active = true;
							ret = ret + options.fn(newContext);
						}
					}
					break;
				case 'previous':
					if (page === 1) {
						newContext = {
							disabled : true,
							n : 1
						}
					} else {
						newContext = {
							n : page - 1
						}
					}
					ret = ret + options.fn(newContext);
					break;
				case 'next':
					newContext = {};
					if (page === pageCount) {
						newContext = {
							disabled : true,
							n : pageCount
						}
					} else {
						newContext = {
							n : page + 1
						}
					}
					ret = ret + options.fn(newContext);
					break;
				case 'first':
					if (page === 1) {
						newContext = {
							disabled : true,
							n : 1
						}
					} else {
						newContext = {
							n : 1
						}
					}
					ret = ret + options.fn(newContext);
					break;
				case 'last':
					if (page === pageCount) {
						newContext = {
							disabled : true,
							n : pageCount
						}
					} else {
						newContext = {
							n : pageCount
						}
					}
					ret = ret + options.fn(newContext);
					break;
				}

				return ret;
			});
			$(".file_box_files").each(function() {
				derivateFileListInstance = new DerivateFileList();
				derivateFileListInstance.init($(this));
			});
		}

		function toReadableSize(size, unit) {
			var conSize = convertSize({
				number : size,
				unit : unit
			});
			var unitString = "";
			switch (conSize.unit) {
			case 0:
				unitString = "bytes";
				break;
			case 1:
				unitString = "kB";
				break;
			case 2:
				unitString = "MB";
				break;
			case 3:
				unitString = "GB";
				break;
			default:
				unitString = "GB";
				break;
			}
			return conSize.number + " " + unitString;
		}

		function convertSize(sizeAndUnit) {
			if (sizeAndUnit.unit < 3) {
				if (sizeAndUnit.number > 1024) {
					var size2 = Math.round((sizeAndUnit.number / 1024) * 100) / 100;
					return convertSize({
						number : size2,
						unit : sizeAndUnit.unit + 1
					});
				}
			}
			return {
				number : sizeAndUnit.number,
				unit : sizeAndUnit.unit
			};
		}
	});

	var DerivateFileList = function() {
		var objID, deriID, mainDoc, fileBox, aclWriteDB, aclDeleteDB, derivateJson, template, urn, hbs, numPerPage, page;
		var i18nKeys = {};

		// functions
		function getDerivate() {
			$.ajax({
				url : webApplicationBaseURL + "api/v1/objects/" + objID + "/derivates/" + deriID + "/contents?format=json",
				type : "GET",
				dataType : "json",
				success : function(data) {
					data.mainDoc = mainDoc;
					data.serverBaseURL = webApplicationBaseURL;
					data.permWrite = aclWriteDB == "true";
					data.permDelete = aclDeleteDB == "true";
					data.urn = urn == "true";

					setPath("/");
					data.pagination = buildPagination(data.children);

					derivateJson = data;
					getTemplate(derivateJson);
				},
				error : function() {
					console.log("Derivate request failed for Derivate: " + deriID);
				}
			});
		}

		function getTemplate(json) {
			if (hbs == undefined) {
				$.ajax({
					url : webApplicationBaseURL + "hbs/derivate-fileList.hbs",
					type : "GET",
					success : function(data) {
						hbs = data;
						useTemplate(json, hbs);
					},
					error : function() {
						console.log("Template request failed");
					}
				});
			} else {
				useTemplate(json, hbs);
			}
		}

		function openFolder(path) {
			var json = getFolder(derivateJson, path);
			if (json !== undefined) {
				setPath(path);
				json.pagination = buildPagination(json.children);
				useTemplate(json);
			}
		}

		function getFolder(json, path) {
			if (json.path === path) {
				return json;
			}
			if (json.children != undefined) {
				for (var i = 0; i < json.children.length; i++) {
					var child = json.children[i];
					var returnJson = getFolder(child, path);
					if (returnJson != undefined) {
						return returnJson;
					}
				}
			}
			return undefined;
		}

		function setPath(path) {
			if (fileBox.data("path") != path)
				page = 1;
			fileBox.data("path", path);
		}

		function useTemplate(json, temp) {
			if (template === undefined) {
				template = Handlebars.compile(temp);
			}
			var newJson = clone(derivateJson);
			newJson.children = sortChildren(json.children, newJson.mainDoc);

			if (json.pagination) {
				newJson.pagination = buildPagination(newJson.children);
				newJson.children = newJson.children.slice(newJson.pagination.start - 1, newJson.pagination.end);
			} else {
				newJson.pagination = undefined;
			}

			var fileList = template(newJson);
			$(fileBox).html("");
			if (json.path != "/") {
				buildBreadcrumbs(json.path);
			}
			$(fileBox).append(fileList);
			$('.confirm_deletion').confirm();
		}

		function buildBreadcrumbs(path) {
			$(fileBox).append('<div class="col-xs-12"><div class="file_set file"><div class="file_box_breadcrumbs"></div></div>');
			var currentPath = path;
			while (currentPath != "/") {
				var currentElm = getCurrentElm(currentPath);
				$(fileBox).find(".file_box_breadcrumbs").prepend(
						'<span class="file_name derivate_folder"><a href="#" data-path="' + currentPath + '">' + currentElm + '</a></span>');
				var newPath = getParentPath(currentPath);
				if (newPath !== currentPath) {
					currentPath = newPath;
				} else {
					break;
				}
			}
			$(fileBox).find(".file_box_breadcrumbs").prepend('<span class="file_name derivate_folder"><a href="#" data-path="/"> </a></span>');
		}

		function buildPagination(children) {
			var pageCount = Math.floor(children.length / numPerPage) + (children.length % numPerPage != 0 ? 1 : 0);
			var start = ((page || 1) - 1) * numPerPage;
			var end = start + numPerPage;
			(end > children.length) && (end = children.length);

			return pageCount > 1 ? pagination = {
				numPerPage : numPerPage,
				pageCount : pageCount,
				page : page || 1,
				start : start + 1,
				end : end,
				total : children.length
			} : undefined;
		}

		function sortChildren(children, mainDoc) {
			return children.sort(function(a, b) {
				if (a.name == mainDoc) {
					return -1;
				}
				if (b.name == mainDoc) {
					return 1;
				}
				if (a.type == "directory" && b.type != "directory") {
					return -1;
				}
				if (b.type == "directory" && a.type != "directory") {
					return 1;
				}
				return a.name.localeCompare(b.name);
			});
		}

		function clone(obj) {
			var target = {};
			for ( var i in obj) {
				if (obj.hasOwnProperty(i)) {
					target[i] = obj[i];
				}
			}
			return target;
		}

		function getParentPath(path) {
			path = path.trim();
			if (path != "/" && path != "") {
				if (path.lastIndexOf("/") == path.length - 1) {
					path = path.substring(0, path.length - 1);
				}
				return path.substring(0, path.lastIndexOf("/") + 1);
			}
		}

		function getCurrentElm(path) {
			if (path.lastIndexOf("/") == path.length - 1) {
				path = path.substring(0, path.length - 1);
			}
			return path.substr(path.lastIndexOf("/") + 1);
		}

		function loadI18nKeys(lang, callback) {
			var ifsKeyURL = webApplicationBaseURL + "servlets/MCRLocaleServlet/" + lang + "/IFS*";
			var mirKeyURL = webApplicationBaseURL + "servlets/MCRLocaleServlet/" + lang + "/mir.confirm.*";
			var filesKeyURL = webApplicationBaseURL + "servlets/MCRLocaleServlet/" + lang + "/mir.files.*";
			$
					.when($.ajax(ifsKeyURL), $.ajax(mirKeyURL), $.ajax(filesKeyURL))
					.done(
							function(d1, d2, d3) {
								if (d1[0] != {} && d1[0] != "???IFS*???" && d1[0]["IFS"]) {
									i18nKeys = $.extend(d1[0], i18nKeys);
								} else {
									i18nKeys["IFS.fileDelete"] = "Datei l\u00F6schen";
									i18nKeys["IFS.mainFile"] = "Hauptdatei";
									i18nKeys["IFS.directoryDelete"] = "Verzeichnis l\u00F6schen";
								}
								if (d2[0] != {} && d2[0] != "???mir.confirm.*???" && d2[0]["mir.confirm"]) {
									i18nKeys = $.extend(d2[0], i18nKeys);
								} else {
									i18nKeys["mir.confirm.directory.text"] = "Wollen Sie dieses Verzeichnis inkl. aller enthaltenen Dateien und ggf. Unterverzeichnissen l\u00F6schen?";
									i18nKeys["mir.confirm.file.text"] = "Wollen Sie diese Datei wirklich l\u00F6schen?";
								}
								if (d3[0] != {} && d3[0] != "???mir.files.*???" && d3[0]["mir.files"]) {
									i18nKeys = $.extend(d3[0], i18nKeys);
								} else {
									i18nKeys["mir.files.text"] = "Dateien";
									i18nKeys["mir.files.to"] = "bis";
									i18nKeys["mir.files.of"] = "von";
								}
								callback();
							})
					.fail(
							function() {
								i18nKeys["IFS.fileDelete"] = "Datei l\u00F6schen";
								i18nKeys["IFS.mainFile"] = "Hauptdatei";
								i18nKeys["IFS.directoryDelete"] = "Verzeichnis l\u00F6schen";
								i18nKeys["mir.confirm.directory.text"] = "Wollen Sie dieses Verzeichnis inkl. aller enthaltenen Dateien und ggf. Unterverzeichnissen l\u00F6schen?";
								i18nKeys["mir.confirm.file.text"] = "Wollen Sie diese Datei wirklich l\u00F6schen?";
								i18nKeys["mir.files.text"] = "Dateien";
								i18nKeys["mir.files.to"] = "bis";
								i18nKeys["mir.files.of"] = "von";
								callback();
							});
		}

		function changeVideo(elm) {
			var vID = getVideoID($(elm).attr("data-deriid"), $(elm).attr("data-name"));
			if (vID != undefined && vID != "") {
				$("#videoChooser").val(vID);
				$("#videoChooser").change();
			}
		}

		function getVideoID(vDeriID, name) {
			if ($("#videoChooser").length > 0) {
				return $("#videoChooser optgroup[label='" + vDeriID + "'] > option").filter(function() {
					return $(this).html() == name;
				}).val();
			}
			return "";
		}

		// init
		return {
			init : function(list) {
				fileBox = list;
				objID = $(list).attr("data-objid");
				deriID = $(list).attr("data-deriid");
				mainDoc = $(list).attr("data-maindoc");
				aclWriteDB = $(list).attr("data-writedb");
				aclDeleteDB = $(list).attr("data-deletedb");
				urn = $(list).attr("data-urn");
				numPerPage = $(list).attr("data-numperpage") || 10;

				$(fileBox).on("click", ".derivate_folder > a", function() {
					openFolder($(this).attr("data-path"));
				});

				$(fileBox).on("click", ".file_name_video > a", function(evt) {
					if ($("#player_").length > 0) {
						evt.preventDefault();
						changeVideo($(this));
					}
				});

				$(fileBox).on("click", ".pagination > li > a", function(evt) {
					evt.preventDefault();
					var $this = $(this);

					if (!$this.parent().hasClass("disabled")) {
						var path = fileBox.data("path")
						page = $this.data("page");

						if (path != "/") {
							openFolder(path);
						} else {
							useTemplate(derivateJson);
						}
					}
				});

				Handlebars.registerHelper("getI18n", function(input) {
					var text = i18nKeys[input];
					if (text != undefined) {
						return text;
					}
					return "";
				});

				Handlebars.registerHelper("concat", function() {
					var args = Array.prototype.slice.call(arguments);
					args.pop();
					return args.join('');
				});

				if (objID != undefined && objID != "" && deriID != undefined && deriID != "") {
					loadI18nKeys($("html").attr("lang"), function() {
						getDerivate("/");
					});
				} else {
					console.log("Wrong objID or deriID, cant get Derivate");
					console.log(objID);
					console.log(deriID);
				}
			}
		};
	}
})();
