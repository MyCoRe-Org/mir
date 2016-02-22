(function() {
    $(document).ready(function () {
        if($(".file_box_files").length > 0) {
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
                if (a.indexOf(b) > - 1) {
                    return options.fn(this);
                }
                return options.inverse(this);
            });
            Handlebars.registerHelper("formatFileSize", function(input) {
                return toReadableSize(input, 0);
            });
            Handlebars.registerHelper("formatDate", function(input) {
                return moment(input).format('DD.MM.YYYY');
            });
            $(".file_box_files").each(function() {
                derivateFileListInstance = new DerivateFileList();
                derivateFileListInstance.init($(this));
            });
        }

        function toReadableSize(size, unit) {
            var conSize = convertSize({number: size, unit: unit});
            var unitString = "";
            switch (conSize.unit){
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
            if (sizeAndUnit.unit < 3){
                if (sizeAndUnit.number > 1024){
                    var size2 = Math.round((sizeAndUnit.number / 1024) * 100)/ 100;
                    return convertSize({number: size2, unit: sizeAndUnit.unit + 1});
                }
            }
            return {number: sizeAndUnit.number, unit: sizeAndUnit.unit};
        }
    });

    var DerivateFileList = function () {
        var objID, deriID, mainDoc, fileBox, aclWriteDB, aclDeleteDB, derivateJson, template, urn;

        //functions
        function getDerivate() {
            $.ajax({
                url: webApplicationBaseURL + "api/v1/objects/" + objID + "/derivates/" + deriID + "/contents?format=json",
                type: "GET",
                dataType: "json",
                success: function(data) {
                    data.mainDoc = mainDoc;
                    data.serverBaseURL = webApplicationBaseURL;
                    data.permWrite = aclWriteDB == "true";
                    data.permDelete = aclDeleteDB  == "true";
                    data.urn = urn == "true";
                    derivateJson = data;
                    getTemplate(derivateJson);
                },
                error: function() {
                    console.log("Derivate request failed for Derivate: "  + deriID);
                }
            });
        }

        function getTemplate(json) {
            $.ajax({
                url: webApplicationBaseURL + "hbs/derivate-fileList.hbs",
                type: "GET",
                success: function(data) {
                    useTemplate(json, data);
                },
                error: function() {
                    console.log("Template request failed");
                }
            });
        }

        function openFolder(path) {
            var json = getFolder(derivateJson, path);
            if (json !== undefined) {
                useTemplate(json);
            }
        }

        function getFolder(json, path) {
            if (json.path === path) {
                return json;
            }
            if (json.children != undefined) {
                for (i = 0; i < json.children.length; i += 1) {
                    var child = json.children[i];
                    var returnJson = getFolder(child, path);
                    if (returnJson != undefined) {
                        return returnJson;
                    }
                }
            }
            return undefined;
        }

        function useTemplate(json, temp) {
            if (template === undefined) {
                template = Handlebars.compile(temp);
            }
            var newJson = clone(derivateJson);
            newJson.children = json.children;
            var fileList = template(newJson);
            $(fileBox).html("");
            if (json.path != "/") {
                $(fileBox).append('<div class="col-xs-12"><div class="file_set file"><span class="file_name derivate_folder go_back" data-path="' + getParentPath(json.path) + '">...</span></div>');
            }
            $(fileBox).append(fileList);
            $('.confirm_deletion').confirm();
        }

        function clone(obj) {
            var target = {};
            for (var i in obj) {
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

        //init
        return {
            init: function (list) {
                fileBox = list;
                objID = $(list).attr("data-objid");
                deriID = $(list).attr("data-deriid");
                mainDoc = $(list).attr("data-maindoc");
                aclWriteDB = $(list).attr("data-writedb");
                aclDeleteDB = $(list).attr("data-deletedb");
                urn = $(list).attr("data-urn");

                $(fileBox).on("click", ".derivate_folder", function() {
                    openFolder($(this).attr("data-path"));
                });

                $(fileBox).on("click", ".go_back", function() {
                    openFolder($(this).attr("data-path"));
                });

                if (objID != undefined && objID != "" && deriID != undefined && deriID != "") {
                    getDerivate();
                }
                else{
                    console.log("Wrong objID or deriID, cant get Derivate");
                    console.log(objID);
                    console.log(deriID);
                }
            }
        };
    }
})();

