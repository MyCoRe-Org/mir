jQuery(document).ready(function() {
	/*
	 * FILL FORM WITH DEFAULT
	 * Description: Fills database options with loaded defaults.
	 */
	var wizFillForm = function() {
		if (jQuery("#dbType").val() != "") {
			var db = jQuery.wizard.dbTypes.find("db > driver:contains('" + jQuery("#dbType").val() + "')").parent();
			jQuery("#dbURL").val(db.find("> url").text().replace("{PATH}", jQuery.wizard.MCRDataDir));
			if (db.find("> username")) {
				jQuery("#dbUsername").val(db.find("> username").text());
			}
		}
	};

	/*
	 * LOAD DATABASE DEFAULTS
	 * Description: Loads database default from given XML.
	 */
	jQuery.get(jQuery.wizard.WebApplicationBaseURL + "wizard/config/dbtypes.xml", function(xml) {
		jQuery.wizard.dbTypes = jQuery(xml);
	}).done(function() {
		wizFillForm();
	});

	/*
	 * HIDE DATABASE OPTIONS
	 * Description: Hide database options on startup or on deselect.
	 */
	if (jQuery("#dbType").val() == "") {
		jQuery.each(jQuery.wizard.dbToggleElms, function(index, elm) {
			jQuery(elm).parents("div.form-group").hide();
		});
	}

	/*
	 * TOGGLE DATABASE OPTIONS
	 * Description: Toggles database options and fill with defaults.
	 */
	jQuery("#dbType").change(function() {
		jQuery.each(jQuery.wizard.dbToggleElms, function(index, id) {
			var elm = jQuery(id).parents("div.form-group");
			if (jQuery("#dbType").val() != "")
				elm.slideDown();
			else
				elm.slideUp();
		});

		wizFillForm();
	});
	
	/*
	 * TOOLTIP
	 * Description: Initialize all Bootstrap Tooltips. 
	 */
	$('*[data-toggle="tooltip"]').tooltip();
});