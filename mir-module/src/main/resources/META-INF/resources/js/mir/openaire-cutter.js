$﻿(document).ready(function() {
	$(".mir-openAIRE-container").each(function() {
		var funder;
		var fundingProgramm;
		var projectId;
		var projectName;
		var projectAcronym;
		var container = $(this);
		
		var children = container.find("input");
		projectName = children[0];
		projectAcronym = children[1];
		projectId = children[2]; 
		fundingProgramm = children[4]; 
		funderName = children[5];
		funder = children[6];
		var save = children[7];
		
		if(!!$(save).val()) {
			var identifier = $(save).val();
			identifier = identifier.split("/");
			$(funder).val(identifier[2]);
			$(fundingProgramm).val(identifier[3]);
			$(projectId).val(identifier[4]);
			$(projectName).val(identifier[6]);
			$(projectAcronym).val(identifier[7]);
		}
		
		container.find("input").each(function() {
			$(this).on("keyup", function() {
				buildString();
			});
		});
		
		function buildString() {
			if($(funder).val() != "" && $(fundingProgramm).val() != "" && $(projectId).val() != "") {
				var identifier = "info:eu-repo/grantAgreement/" 
					+ replaceSlash($(funder).val()) + "/" 
					+ replaceSlash($(fundingProgramm).val()) + "/" 
					+ replaceSlash($(projectId).val()) + "/EU/" 
					+ replaceSlash($(projectName).val()) + "/" 
					+ replaceSlash($(projectAcronym).val());
				$(save).val(identifier);
			}
			
			if($(funder).val() == "" || $(fundingProgramm).val() == "" || $(projectId).val() == "") {
				$(save).val("");
			}
		}
		
		function replaceSlash(text) {
			return text.replace(/\//g, "%2F");
		}
	});
});
