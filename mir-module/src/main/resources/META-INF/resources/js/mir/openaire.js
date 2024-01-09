$﻿(document).ready(function() {
  $(".mir-openAIRE-container").each(function() {
    var container = $(this);
    var children = container.find("input");

    var tags = [];
    var projectName = children[0];
    var projectAcronym = children[1];
    var projectId = children[2];
    var fundingProgramm = children[3];
    var funder = children[4];
    var save = children[5];

    readIdentification($(save).val());

    container.find("input[id]").each(function() {
      var id = $(this).attr("id");
      $(this).typeahead({
        source: function(query, process) {
          display = [];
          map = {};

          if(id == "name") {
            loadMIRProject(saveMIRData, query);
          }
          loadProjects(saveData, id, query);


          setTimeout(function() {
            $.each(tags, function(i, data) {
              map[data.id + " - " + data.display] = data;
              display.push(data.id + " - " + data.display);
            });

            tags = [];

            process(display);
          }, 400);
        },
        updater: function(item) {
          readIdentification(map[item].value);
          $(save).val(map[item].value);
          var returnString = id == "name" ? map[item].value.split("/")[6] : map[item].display;
          return returnString;
        },
        items: 10
      });
    });

    function loadMIRProject(callback, append) {
      $.ajax({
        url: webApplicationBaseURL + 'servlets/solr/find?condQuery=' + append + '&XSL.Style=xml',
        type: "GET",
        success: function(data) {
          callback(data);
        },
        error: function(error) {
          console.log(error);
        }
      });
    }

    function loadProjects(callback, kind, append) {
      $.ajax({
        url: webApplicationBaseURL + "servlets/MIRGetOpenAIREProjectsServlet?" + kind + "=" + append,
//				url: "http://api.openaire.eu/search/projects?" + kind + "=" + append,
        type: "GET",
        success: function(data) {
          callback(data, kind);
        },
        error: function(error) {
          console.log(error);
        }
      });
    }
      function saveMIRData(data) {
      var identifier;
      $(data).find("doc").each(function() {
        identifier = $(this).find("arr[name='mods.identifier']");
        $(identifier).children().each(function() {
          if($(this).text().indexOf("info:eu-repo/grantAgreement") >= 0) {
            tags.push({
              display: $(data).find("arr[name='mods.title']").text(),
              value: $(this).text(),
              id: "MIR - " + $(this).text().split("/")[4]
            });
          }
        });
      });
    }

    function saveData(data, kind) {
      var tmpProjectName;
      var tmpProjectAcr;
      var tmpProjectID;
      var tmpfundingProgramm;
      var tmpFunder;
      var tmpJurisdiction;
      var tmpComplet;
      $(data).find("result").each(function() {
        tmpProjectName = $(this).find("title").text();
        tmpProjectAcr = $(this).find("acronym").text();
        tmpProjectID = $(this).find("code").text();
        tmpfundingProgramm = $(this).find("funding_level_0");
        tmpFunder = $(tmpfundingProgramm).find("class").text();
        tmpFunder = tmpFunder.split(":")[0];
        tmpfundingProgramm = $(tmpfundingProgramm).find("name").text();
        tmpJurisdiction = tmpFunder == "wt" ? "" : "EU";
        tmpComplet = "info:eu-repo/grantAgreement/"
          + tmpFunder.toUpperCase() + "/"
          + tmpfundingProgramm + "/"
          + replaceSlash(tmpProjectID) + "/"
          + tmpJurisdiction + "/"
          + tmpProjectName + "/";

        if(tmpProjectAcr != "") {
          tmpComplet = tmpComplet + replaceSlash(tmpProjectAcr);
        }

        tags.push({
          display: kind == "name" ? tmpProjectName : tmpProjectAcr,
          value: tmpComplet,
          id: tmpProjectID
        });
      });
    }

    function readIdentification(id) {
      if(id != "") {
        var identifier = id.split("/");
        $(funder).val(identifier[2]);
        $(fundingProgramm).val(identifier[3]);
        $(projectId).val(replaceEscapedSlash(identifier[4]));
        $(projectName).val(identifier[6]);
        $(projectAcronym).val("");
        if(identifier[7] != "") {
          $(projectAcronym).val(decodeURIComponent(identifier[7]));
        }
      }
    }

    container.find("input").each(function() {
      $(this).on("keyup", function() {
        writeIdentification();
      });
    });

    function writeIdentification() {
      if($(funder).val() != "" && $(fundingProgramm).val() != "" && $(projectId).val() != "") {
        var identifier = "info:eu-repo/grantAgreement/"
          + $(funder).val() + "/"
          + $(fundingProgramm).val() + "/"
          + replaceSlash($(projectId).val()) + "/EU/"
          + $(projectName).val() + "/";

        if($(projectAcronym).val() != "") {
          identifier = identifier + replaceSlash($(projectAcronym).val());
        }
        $(save).val(identifier);
      }

      if($(funder).val() == "" || $(fundingProgramm).val() == "" || $(projectId).val() == "") {
        $(save).val("");
      }
    }

    function replaceSlash(text) {
      return text.replace(/\//g, "%2F");
    }

    function replaceEscapedSlash(text) {
      return text.replace(/%2F/g, "/");
    }

  });
});
