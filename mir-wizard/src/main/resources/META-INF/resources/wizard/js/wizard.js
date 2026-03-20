/*
 * $Id$
 * $Revision$ $Date$
 *
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * This program is free software; you can use it, redistribute it
 * and / or modify it under the terms of the GNU General Public License
 * (GPL) as published by the Free Software Foundation; either version 2
 * of the License or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program, in a file called gpl.txt or license.txt.
 * If not, write to the Free Software Foundation Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 */
jQuery(document).ready(function() {
	/*
	 * FILL FORM WITH DEFAULT
	 *
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
	 *
	 * Description: Loads database default from given XML.
	 */
	jQuery.get(jQuery.wizard.WebApplicationBaseURL + "wizard/config/dbtypes.xml", function(xml) {
		jQuery.wizard.dbTypes = jQuery(xml);
	}).done(function() {
		wizFillForm();
	});

	/*
	 * HIDE DATABASE OPTIONS
	 *
	 * Description: Hide database options on startup or on deselect.
	 */
	if (jQuery("#dbType").val() == "") {
		jQuery.each(jQuery.wizard.dbToggleElms, function(index, elm) {
			jQuery(elm).parents("div.mir-form-group").hide();
		});
	}

	/*
	 * TOGGLE DATABASE OPTIONS
	 *
	 * Description: Toggles database options and fill with defaults.
	 */
	jQuery("#dbType").change(function() {
		jQuery.each(jQuery.wizard.dbToggleElms, function(index, id) {
			var elm = jQuery(id).parents("div.mir-form-group");
			if (jQuery("#dbType").val() != "")
				elm.slideDown();
			else
				elm.slideUp();
		});

		wizFillForm();
	});

	/*
	 * TOOLTIP
	 *
	 * Description: Initialize all Bootstrap Tooltips.
	 */
	document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function(el) {
		new bootstrap.Tooltip(el);
	});

	const formGroupSelector = '.mir-form-group.row';

	/**
	 * Set the visibility of the closest form group of the given element ID.
	 * @param {string} containedElementID
	 * @param {boolean} visible
	 * @returns {void}
	 */
	const setFormGroupVisible = (containedElementID, visible) => {
		const el = document.querySelector(`#${containedElementID}`);
		if (!el) return;
		const group = el.closest(formGroupSelector);
		if (!group) return;
		group.style.display = visible ? '' : 'none';
	};

	const updateCreateCoresForms = () => {
		const createCoresCheckbox = document.getElementById('createCores');
		const solrCloudCreationOptions = document.getElementById('solrCloudCreationOptions');
		if (solrCloudCreationOptions) {
			solrCloudCreationOptions.style.display = (createCoresCheckbox && createCoresCheckbox.checked) ? '' : 'none';
		}
	};

	document.addEventListener('change', function(e) {
		if (e.target && e.target.id === 'createCores') {
			updateCreateCoresForms();
		}
	});

	const adminAuthCheckbox = document.getElementById('adminUserEnabled');
	const indexAuthCheckbox = document.getElementById('indexUserEnabled');
	const searchAuthCheckbox = document.getElementById('searchUserEnabled');
	const tikaServerCheckbox = document.getElementById('tikaServer');

	const updateAdminAuthForms = () => {
		setFormGroupVisible('solrAdminUsername', adminAuthCheckbox.checked);
		setFormGroupVisible('solrAdminPassword', adminAuthCheckbox.checked);
	}

	adminAuthCheckbox.addEventListener('change', () => {
		updateAdminAuthForms();
	});

	updateAdminAuthForms();

	const updateIndexAuthForms = () => {
		setFormGroupVisible('solrIndexUsername', indexAuthCheckbox.checked);
		setFormGroupVisible('solrIndexPassword', indexAuthCheckbox.checked);
	}

	indexAuthCheckbox.addEventListener('change', () => {
		updateIndexAuthForms();
	});

	updateIndexAuthForms();

	const updateSearchAuthForms = () => {
		setFormGroupVisible('solrSearchUsername', searchAuthCheckbox.checked);
		setFormGroupVisible('solrSearchPassword', searchAuthCheckbox.checked);
	}

	searchAuthCheckbox.addEventListener('change', () => {
		updateSearchAuthForms();
	});

	updateSearchAuthForms();

	const updateTikaServerForms = () => {
		setFormGroupVisible('tikaServerURL', tikaServerCheckbox.checked);
	}

	tikaServerCheckbox.addEventListener('change', () => {
		updateTikaServerForms();
	});

	updateTikaServerForms();

	// Solr mode handling
	const modeStandaloneRadio = document.getElementById('solrMode-standalone');
	const modeCloudUrlRadio = document.getElementById('solrMode-cloud-url');
	const modeCloudZkRadio = document.getElementById('solrMode-cloud-zk');

	const getCurrentSolrMode = () => {
		if (modeCloudUrlRadio?.checked) return 'cloud-url';
		if (modeCloudZkRadio?.checked) return 'cloud-zk';
		return 'standalone';
	};

	const updateSolrMode = () => {
		const mode = getCurrentSolrMode();
		const isStandalone = mode === 'standalone';
		const isCloudZk = mode === 'cloud-zk';
		const isCloud = !isStandalone;

		setFormGroupVisible('solrServerUrl', !isCloudZk);
		setFormGroupVisible('solrZkUrl', isCloudZk);
		setFormGroupVisible('solrZkChroot', isCloudZk);
		setFormGroupVisible('solrMainCore', isStandalone);
		setFormGroupVisible('solrClassificationCore', isStandalone);
		setFormGroupVisible('solrMainCollection', isCloud);
		setFormGroupVisible('solrClassificationCollection', isCloud);
		setFormGroupVisible('createCores', isCloud);
		if (!isCloud) {
			const solrCloudCreationOptions = document.getElementById('solrCloudCreationOptions');
			if (solrCloudCreationOptions) solrCloudCreationOptions.style.display = 'none';
		} else {
			updateCreateCoresForms();
		}
	};

	[modeStandaloneRadio, modeCloudUrlRadio, modeCloudZkRadio].forEach(radio => {
		if (radio) radio.addEventListener('change', updateSolrMode);
	});

	updateSolrMode();

});
