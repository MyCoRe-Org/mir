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
            Handlebars.registerHelper('noDirOrURN', function(a, b, options) {
                if (a !== 'directory' || !b) {
                    return options.fn(this);
                }
                return options.inverse(this);
            });
			Handlebars.registerHelper('notContains', function(a, b, options) {
				if (a.indexOf(b) == -1) {
					return options.fn(this);
				}
				return options.inverse(this);
			});
			Handlebars.registerHelper("concat", function() {
				var args = Array.prototype.slice.call(arguments);
				args.pop();
				return args.join('');
			});
			Handlebars.registerHelper("getParent", function (input) {
				return input.substring(0, input.lastIndexOf('/', input.length - 2));
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
		var objID, deriID, mainDoc, fileBox, aclWriteDB, aclDeleteDB, derivateJson, defaultTemplate, templates = new Array(), urn, hbs = new Array(), numPerPage, page;
		var i18nKeys = {};

		var fileIcons = {
			"PDF" : {
				icon : "fa-file-pdf",
				extensions : "pdf|ps"
			},
			"Archive" : {
				icon : "fa-file-archive",
				extensions : "zip|tar|rar|bz|xs|gz|bz2|xz"
			},
			"Image" : {
				icon : "fa-file-image",
				extensions : "tif|tiff|gif|jpeg|jpg|jif|jfif|jp2|jpx|j2k|j2c|fpx|pcd|png"
			},
			"Text" : {
				icon : "fa-file-alt",
				extensions : "txt|rtf"
			},
			"Audio" : {
				icon : "fa-file-audio",
				extensions : "wav|wma|mp3"
			},
			"Video" : {
				icon : "fa-file-video",
				extensions : "mp4|f4v|flv|rm|avi|wmv"
			},
			"Code" : {
				icon : "fa-file-code",
				extensions : "css|htm|html|php|c|cpp|bat|cmd|pas|java"
			},
			"Word" : {
				icon : "fa-file-word",
				extensions : "doc|docx|dot"
			},
			"Excel" : {
				icon : "fa-file-excel",
				extensions : "xls|xlt|xlsx|xltx"
			},
			"Powerpoint" : {
				icon : "fa-file-powerpoint",
				extensions : "ppt|potx|ppsx|sldx"
			},
			"_default" : {
				icon : "fa-file"
			}
		};

		// functions
		function getDerivate(token) {
			$.ajax({
				url : webApplicationBaseURL + "api/v1/objects/" + objID + "/derivates/" + deriID + "/contents?format=json",
				type : "GET",
				dataType : "json",
				beforeSend: function (xhr) {
					if (token != undefined) {
						xhr.setRequestHeader("Authorization", token.token_type + " " + token.access_token);
					}
				},
				success : function(data) {
					data.mainDoc = mainDoc;
					data.serverBaseURL = webApplicationBaseURL;
					data.permWrite = aclWriteDB == "true";
					data.permDelete = aclDeleteDB == "true";

					setPath("/");
					data.pagination = buildPagination(data.children);

					derivateJson = data;
					getTemplate(derivateJson, "derivate-fileList.hbs", useTemplate);
				},
				error: function (resp, title, message) {
					var respObj = {
						mycorederivate: deriID,
						message: resp.status + " " + resp.statusText
					};
					getTemplate(respObj, "error.hbs", function (respObj, template) {
						var filesTable = jQuery("#files" + deriID);
						filesTable.html(template(respObj));
					});
					console.log("Derivate request failed for Derivate: " + deriID);
				},
				cache: false
			});
		}

		function getToken(callback) {
			if ($(fileBox).attr('data-jwt') === 'required') {
				$.ajax({
					url: webApplicationBaseURL + "rsc/jwt",
					type: "GET",
          data: {
            ua: ["acckey_" + objID, "acckey_" + deriID],
            sa: ["acckey_" + objID, "acckey_" + deriID]
          },
          traditional: true,
					dataType: "json",
					success: function (data) {
						if (data.login_success) {
							callback(data);
						}
						else {
							var respObj = {
								mycorederivate: deriID,
								message: "401 UNAUTHORIZED"
							};
							getTemplate(respObj, "error.hbs", function (respObj, template) {
								var filesTable = jQuery("#files" + deriID);
								filesTable.html(template(respObj));
							});
						}
					},
					error: function (resp, title, message) {
						console.log(resp);
						console.log("Token request failed.");
					}
				});
			}
			else {
				callback();
			}
		}

		function getTemplate(json, templateName, cb) {
			if (hbs[templateName] == undefined) {
				$.ajax({
					url: webApplicationBaseURL + "hbs/" + templateName,
					type : "GET",
					success : function(data) {
						hbs[templateName] = data;
						if (templates[templateName] === undefined) {
							templates[templateName] = Handlebars.compile(hbs[templateName]);
						}
						if (templateName == "derivate-fileList.hbs") {
							defaultTemplate = templates[templateName];
						}

						cb(json, templates[templateName]);
					},
					error : function() {
						console.log("Template request failed");
					}
				});
			} else {
				cb(json, templates[templateName]);
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

		function useTemplate(json, template) {
			if (typeof template == "undefined") {
				template = defaultTemplate;
			}
			var newJson = clone(derivateJson);
			newJson.children = sortChildren(json.children, newJson.mainDoc);
			newJson.path = json.path;
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
			mycore.upload.enable($(fileBox)[0]);
			$('.confirm_deletion').confirm();
			$('.rename').click(function (e) {
				let href = $(this).attr("href");
				let hrefURL = new URL(href);
				let fileParam = hrefURL.searchParams.get("file");
				let lastSlashInFile = fileParam.lastIndexOf("/");
				let directory = "";

				// find the directory of the current file
				directory = fileParam.substr(0, lastSlashInFile+1);
				let oldName = fileParam.substr(directory.length);

				let newName = prompt(i18nKeys["IFS.fileRename.to"], decodeURI(oldName));
				if (newName == null) {
					e.preventDefault();
				} else {
					// remove any path parts from the name
					const lastSlashInName = newName.lastIndexOf("/");
					if (lastSlashInName > 0) {
						newName = newName.substr(lastSlashInName);
					}
					$(this).attr("href", href + "&file2=" + encodeURI(directory) + encodeURI(newName));
				}
			});
		}

		function buildBreadcrumbs(path) {
			$(fileBox).append('<div class="col-12"><div class="file_set file"><div class="file_box_breadcrumbs"></div></div>');
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
				if (a.path == "/" + mainDoc) {
					return -1;
				}
				if (b.path == "/" + mainDoc) {
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
			const ifsKeyURL = webApplicationBaseURL + "rsc/locale/translate/" + lang + "/IFS*";
			const mirKeyURL = webApplicationBaseURL + "rsc/locale/translate/" + lang + "/mir.confirm.*";
			const pagiKeyURL = webApplicationBaseURL + "rsc/locale/translate/" + lang + "/mir.pagination.*";
			const uploadKeyURL = webApplicationBaseURL + "rsc/locale/translate/" + lang + "/mir.upload.drop.*";
			const derivateFileKeyURL = webApplicationBaseURL + "rsc/locale/translate/" + lang + "/mir.derivate.file.*";
			const allRequests = Promise.all([ifsKeyURL, mirKeyURL, pagiKeyURL, uploadKeyURL,
				derivateFileKeyURL]
				.map((url)=> fetch(url))
				.map((promise)=> promise.then((response)=> response.json())));

			allRequests.then((translations)=> {
				for (const translation of translations) {
					for (const key in translation) {
						i18nKeys[key] = translation[key];
					}
				}
				callback();
			}, (error)=> {
				console.error("Error while loading i18n keys: " + error);
				callback(); // continue without translations
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

				$(fileBox).on("click", ".derivate_folder > a", function(evt) {
					evt.preventDefault();
					openFolder($(this).attr("data-path"));
				});

				$(fileBox).on("click", ".file_video > a", function(evt) {
					if ($("#player_").length > 0) {
						evt.preventDefault();
						changeVideo($(this));
					}
				});

				$(fileBox).on("click", ".pagination > li > a", function(evt) {
					evt.preventDefault();
					var $this = $(this);

					if (!$this.parent().hasClass("disabled")) {
						var offset = $(".pagination", fileBox).offset();

						var path = fileBox.data("path");
						page = $this.data("page");

						if (path != "/") {
							openFolder(path);
						} else {
							useTemplate(derivateJson);
						}

						var offsetDif = offset.top - $(".pagination", fileBox).offset().top;
						if (offsetDif > 0) {
							$(document).scrollTop($(document).scrollTop() - offsetDif);
						}
					}
				});

				Handlebars.registerHelper("getI18n", function(input, params) {
					let text = i18nKeys[input];
					if(text === undefined) { // this happens if the translation could not be loaded
						text = "???" + input + "???"; // default mycore behaviour
					}
					let args = Array.prototype.slice.call(arguments, 1);
					if (args != undefined) {
						for (let i = 0; i < args.length; i++) {
							text = text.replace(RegExp("\\{" + i + "\\}", 'g'), args[i]);
						}
					}
					return text;
				});

				Handlebars.registerHelper("getFileIcon", function(ext) {
					for ( var label in fileIcons) {
						if (label != "_default" && fileIcons[label].extensions.split("|").includes(ext.toLowerCase()))
							return fileIcons[label].icon;
					}

					return fileIcons["_default"].icon;
				});
				Handlebars.registerHelper("getFileLabel", function(ext) {
					for ( var label in fileIcons) {
						if (label != "_default" && fileIcons[label].extensions.split("|").includes(ext.toLowerCase()))
							return label;
					}

					return "";
				});

				if (objID != undefined && objID != "" && deriID != undefined && deriID != "") {
					loadI18nKeys($("html").attr("lang"), function () {
						getToken(function (data) {
							getDerivate(data);
						});
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
