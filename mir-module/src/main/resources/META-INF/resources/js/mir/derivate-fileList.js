(function() {

	let iconsMapping = null;

	/**
	 * @typedef {Object} FileTypeDefinition
	 * @property {string} icon - Font Awesome icon class
	 * @property {string[]} mimeTypes - Array of associated MIME types
	 */

	/**
	 * Mapping of file categories to their icons and optional MIME types.
	 * Used as a fallback or static default mapping if dynamic loading fails.
	 *
	 * @type {Object.<string, FileTypeDefinition>}
	 */
	const fileIcons = {
		PDF: {
			icon: "fa-file-pdf",
			mimeTypes: []
		},
		Archive: {
			icon: "fa-file-archive",
			mimeTypes: []
		},
		Image: {
			icon: "fa-file-image",
			mimeTypes: []
		},
		Text: {
			icon: "fa-file-alt",
			mimeTypes: []
		},
		Code: {
			icon: "fa-file-code",
			mimeTypes: ["application/vnd.wolfram.mathematica.package"]
		},
		Audio: {
			icon: "fa-file-audio",
			mimeTypes: []
		},
		Video: {
			icon: "fa-file-video",
			mimeTypes: []
		},
		Word: {
			icon: "fa-file-word",
			mimeTypes: []
		},
		Excel: {
			icon: "fa-file-excel",
			mimeTypes: []
		},
		Powerpoint: {
			icon: "fa-file-powerpoint",
			mimeTypes: []
		},
		Database: {
			icon: "fa-database",
			mimeTypes: []
		},
		_default: {
			icon: "fa-file",
			mimeTypes: []
		}
	};


	$(document).ready(function() {

		/**
		 * Loads the MIME type to icon mapping from the backend.
		 *
		 * Falls back to default mapping (`fileIcons`) if the request fails.
		 * * @async
		 *  * @function loadMimetypeMapping
		 *  * @returns {Promise<Object>} Resolves to a valid mapping object.
		 *  * @throws Will re-throw on network or response errors.
		 *  */
		async function loadMimetypeMapping() {
			try {
				const response = await fetch(webApplicationBaseURL + "rsc/mimetypeMappingList/get", {
					method: "GET",
					headers: {
						"Accept": "application/json",
						"Content-Type": "application/json; charset=utf-8"
					}
				});

				if (!response.ok) {
					throw new Error(`HTTP error! status: ${response.status}`);
				}

				return await response.json();
			} catch (error) {
				console.error('Error loading mimetype mapping:', error);
				throw error;
			}
		}

		// Load the mapping and handle fallback
		loadMimetypeMapping()
			.then(mapping => {
				iconsMapping = mapping;
			})
			.catch(error => {
				iconsMapping = fileIcons
				console.warn("Fallback to default mapping due to error:", error);
			});


		if ($(".file_box_files").length > 0) {
			Handlebars.registerHelper('is', function(a, b, options) {
				if (a === b) {
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
				if (a !== b) {
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
				if (a.indexOf(b) === -1) {
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
				if (lang === "en") {
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

		// functions
		function getDerivate(token) {
			$.ajax({
				url : webApplicationBaseURL + "api/v1/objects/" + objID + "/derivates/" + deriID + "/contents?format=json",
				type : "GET",
				dataType : "json",
				beforeSend: function (xhr) {
					if (token !== undefined) {
						xhr.setRequestHeader("Authorization", token.token_type + " " + token.access_token);
					}
				},
				success : function(data) {
					data.mainDoc = mainDoc;
					data.serverBaseURL = webApplicationBaseURL;
					data.permWrite = aclWriteDB === "true";
					data.permDelete = aclDeleteDB === "true";

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
			if (hbs[templateName] === undefined) {
				$.ajax({
					url: webApplicationBaseURL + "hbs/" + templateName,
					type : "GET",
					success : function(data) {
						hbs[templateName] = data;
						if (templates[templateName] === undefined) {
							templates[templateName] = Handlebars.compile(hbs[templateName]);
						}
						if (templateName === "derivate-fileList.hbs") {
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
			if (json.children !== undefined) {
				for (var i = 0; i < json.children.length; i++) {
					var child = json.children[i];
					var returnJson = getFolder(child, path);
					if (returnJson !== undefined) {
						return returnJson;
					}
				}
			}
			return undefined;
		}

		function setPath(path) {
			if (fileBox.data("path") !== path)
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
			if (json.path !== "/") {
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
			while (currentPath !== "/") {
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
			var pageCount = Math.floor(children.length / numPerPage) + (children.length % numPerPage !== 0 ? 1 : 0);
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
				if (a.path === "/" + mainDoc) {
					return -1;
				}
				if (b.path === "/" + mainDoc) {
					return 1;
				}
				if (a.type === "directory" && b.type !== "directory") {
					return -1;
				}
				if (b.type === "directory" && a.type !== "directory") {
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
			if (path !== "/" && path !== "") {
				if (path.lastIndexOf("/") === path.length - 1) {
					path = path.substring(0, path.length - 1);
				}
				return path.substring(0, path.lastIndexOf("/") + 1);
			}
		}

		function getCurrentElm(path) {
			if (path.lastIndexOf("/") === path.length - 1) {
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
			if (vID !== undefined && vID !== "") {
				$("#videoChooser").val(vID);
				$("#videoChooser").change();
			}
		}

		function getVideoID(vDeriID, name) {
			if ($("#videoChooser").length > 0) {
				return $("#videoChooser optgroup[label='" + vDeriID + "'] > option").filter(function() {
					return $(this).html() === name;
				}).val();
			}
			return "";
		}

		/**
		 * Strips any charset or additional parameters from the content-type string.
		 *
		 * @param {string} [contentType=""] - The full Content-Type string (e.g., "text/plain; charset=utf-8")
		 * @returns {string} - Clean MIME type without parameters (e.g., "text/plain")
		 */
		function stripCharset(contentType = "") {
			return contentType.split(";")[0].trim();
		}

		/**
		 * Returns the icon class for the given MIME type.
		 *
		 * Priority:
		 * 1. Exact match from loaded `iconsMapping`
		 * 2. Heuristic fallback via `getHeuristicType()`
		 * 3. Default icon
		 *
		 * @param {string} contentType - MIME type (e.g., "application/pdf")
		 * @returns {string} Font Awesome icon class (e.g., "fa-file-pdf")
		 */
		function getFileIcon(contentType = "") {
			const cleanType = stripCharset(contentType?.toLowerCase() || "");
			let typeKey = "";

			// Exact match
			for (const [key, value] of Object.entries(iconsMapping)) {
				if (value.mimeTypes?.includes(cleanType)) {
					typeKey = key;
					break;
				}
			}

			// Heuristic fallback
			if (!typeKey) {
				typeKey = getHeuristicType(cleanType);
			}

			return iconsMapping[typeKey]?.icon || iconsMapping._default.icon;
		}



		// for the test of differnt formats can you use this link: https://www.filesampleshub.com/format
		/**
		 * Heuristic mapping for MIME types not explicitly listed in iconsMapping.
		 *
		 * @param {string} contentType - Clean MIME type string
		 * @returns {string} The determined category key from fileIcons
		 */
		function getHeuristicType(contentType = "") {
			if (contentType === "text/plain") {
				return "Text";
			}

			if (contentType.startsWith("text/")) {
				const subtype = contentType.split("/")[1];
				const codeSubtypes = [
					"markdown", "html", "xml", "css", "javascript", "typescript",
					"x-java-source", "x-java", "java", "ms-java", "x-python", "x-c", "x-c++", "x-csharp",
					"x-ruby", "x-php", "x-perl", "x-shellscript", "x-sql", "x-scala", "x-go"
				];
				if (codeSubtypes.includes(subtype)) {
					return "Code";
				}
			}

			if (contentType.startsWith("application/")) {
				const subtype = contentType.split("/")[1];
				const codeAppTypes = [
					"javascript", "json", "xml", "xhtml+xml", "rdf+xml",
					"x-httpd-php", "x-sh", "x-java-source", "x-java", "java", "ms-java", "x-python-code",
					"x-csharp", "x-perl", "x-ruby", "x-latex", "yaml", "rdf+xml"
				];
				if (codeAppTypes.includes(subtype)) {
					return "Code";
				}
			}

			if (contentType.startsWith("image/")) return "Image";
			if (contentType.startsWith("audio/")) return "Audio";
			if (contentType.startsWith("video/")) return "Video";
			if (contentType.includes("pdf")) return "PDF";
			if (/zip|tar|x-7z-compressed|vnd\.rar/.test(contentType)) return "Archive";
			if (contentType.includes("word")) return "Word";
			if (contentType.includes("excel")) return "Excel";
			if (contentType.includes("powerpoint")) return "Powerpoint";
			if (contentType.includes("sql") || contentType.includes("db")) return "Database";

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

						if (path !== "/") {
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
					if (args !== undefined) {
						for (let i = 0; i < args.length; i++) {
							text = text.replace(RegExp("\\{" + i + "\\}", 'g'), args[i]);
						}
					}
					return text;
				});


				/**
				 * Handlebars helper to return a file icon class based on the MIME type.
				 *
				 * @function getFileIcon
				 * @memberof Handlebars.helpers
				 * @param {string} contentType - MIME type (e.g., "image/png")
				 * @returns {string} Font Awesome icon class (e.g., "fa-file-image")
				 */
				Handlebars.registerHelper("getFileIcon", function(contentType) {
					return getFileIcon(contentType);
				});

				/**
				 * Handlebars helper to get file category label based on the MIME type.
				 * Note: Not reliable in async or repeated use unless adapted per item.
				 *
				 * @function getFileLabel
				 * @memberof Handlebars.helpers
				 * @param {string} contentType - MIME type
				 * @returns {string} File type label (e.g., "Image", "PDF")
				 */
				Handlebars.registerHelper("getFileLabel", function(contentType) {
					const cleanType = stripCharset(contentType?.toLowerCase() || "");
					let typeKey = "";

					for (const [key, value] of Object.entries(iconsMapping)) {
						if (value.mimeTypes?.includes(cleanType)) {
							typeKey = key;
							break;
						}
					}
					if (!typeKey) {
						typeKey = getHeuristicType(cleanType);
					}
					return typeKey;
				});


				if (objID !== undefined && objID !== "" && deriID !== undefined && deriID !== "") {
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
