let accessKeys = undefined;

function getParameterByName(name, url = window.location.href) {
    name = name.replace(/[\[\]]/g, '\\$&');
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
    results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
}

function generateKey(plength) {
	var keylistalpha = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
	var keylistint = "123456789";
	var keylistspec = "!@#_%$";
	var temp = '';
	var len = plength / 2;
	var len = len - 1;
	var lenspec = plength - len - len;

	for (i = 0; i < len; i++)
		temp += keylistalpha.charAt(Math.floor(Math.random() * keylistalpha.length));

	for (i = 0; i < lenspec; i++)
		temp += keylistspec.charAt(Math.floor(Math.random() * keylistspec.length));

	for (i = 0; i < len; i++)
		temp += keylistint.charAt(Math.floor(Math.random() * keylistint.length));

	temp = temp.split('').sort(function() {
		return 0.5 - Math.random()
	}).join('');

	return temp;
};

function addAccessKeyTableRow(accessKey) {
    console.log(accessKey);
    const table = document.getElementById("accessKeys");
    const index = table.rows.length++;
    let row = table.insertRow(-1);
    row.className = "d-flex";
    let indexCell = row.insertCell(0);
    indexCell.className = "th-sm col-auto"
    indexCell.innerHTML = index;
    let typeCell = row.insertCell(1);
    typeCell.className = "th-sm col-3 text-center"
    typeCell.innerHTML = accessKey["type"];
    let valueCell = row.insertCell(2);
    valueCell.className = "th-sm col text-center"
    valueCell.innerHTML = accessKey["value"];

    var i = document.createElement('i');
    i.className = "fas fa-edit";
    var a = document.createElement('a');
    a.setAttribute("data-toggle", "modal");
    a.setAttribute("data-id", accessKey["id"]);
    a.setAttribute("data-type", accessKey["type"]);
    a.setAttribute("data-value", accessKey["value"]);
    a.setAttribute("href", "#accessKeyModal");
    a.className = "editAccessKeyModal"
    a.appendChild(i);
    let editCell = row.insertCell(3)
    editCell.className = "th-sm col-auto";
    editCell.appendChild(a);
}

function proccessAccessKeyInformation(accessKeyInformation) {
    accessKeys = accessKeyInformation["accessKeys"];
    for (key in accessKeys) {
        if (accessKeys.hasOwnProperty(key)) {
            const accessKey = accessKeys[key];
            addAccessKeyTableRow(accessKey);
        }
    }
}

function disableButtons() {
    $('#accessKeyUpdate').prop("disabled", true);
    $('#accessKeyDelete').prop("disabled", true);
    $('#accessKeyNew').prop("disabled", true);
    $('.closeModal').prop("disabled", true);
}

function enableButtons() {
    $('#accessKeyUpdate').prop("disabled", false);
    $('#accessKeyDelete').prop("disabled", false);
    $('#accessKeyNew').prop("disabled", false);
    $('.closeModal').prop("disabled", false);
}

$(document).ready(function() {
    const objectId = getParameterByName('objectid'); 

    $("#accessKeyModal").modal({
        backdrop: 'static',
        show:false,
    });


    $("#accessKeyNew").click(function() {
        disableButtons();
        const type = $("#accessKeyType").val();
        const value = $("#accessKeyValue").val();
        const accessKey = {"type": type, "value": value};

        if (value.length == 0) {
            $("#accessKeyValue").addClass("is-invalid");
            enableButtons();
            return;
        } else {
            $("#accessKeyValue").removeClass("is-invalid");
        }
            
        $.ajax({
            url: webApplicationBaseURL + "rsc/accesskey/" + objectId,
            type: 'PUT',
            data: JSON.stringify(accessKey),
            contentType: 'application/json',
            success: function(data) {
                location.reload();
            },
            error: function(data) {
                if (data.status == 400) {
                    $('#accessKeyModalAlert').html(data.responseText);
                    $('#accessKeyModalAlert').show();
                }
                enableButtons();
            }
        });
    });

    $(document).on("click", ".newAccessKeyModal", function () {
        $("#accessKeyValue").val("");
        $("#accessKeyType option")[0].selected = true;
        $('#accessKeyDelete').hide();
        $('#accessKeyUpdate').hide();
        $('#accessKeyNew').show();
        $('#accessKeyModalAlert').hide();
    });

    $(document).on("click", ".editAccessKeyModal", function () {
        const accessKeyId = $(this).data('id');
        const accessKeyValue = $(this).data('value');
        const accessKeyType = $(this).data('type');
        $("#accessKeyValue").val(accessKeyValue);
        if (accessKeyType == "read") {
            $("#accessKeyType option")[0].selected = true;
        } else {
            $("#accessKeyType option")[1].selected = true;
        }
        $('#accessKeyDelete').attr("data-id", accessKeyId); 
        $('#accessKeyUpdate').attr("data-id", accessKeyId); 
        $('#accessKeyDelete').show();
        $('#accessKeyUpdate').show();
        $('#accessKeyNew').hide();
        $("#accessKeyValue").removeClass("is-invalid");
        $('#accessKeyModalAlert').hide();
    });

    $('#accessKeyDelete').click(function() {
        disableButtons();
        const accessKeyId = $(this).data('id');
        $.ajax({
            url: webApplicationBaseURL + "rsc/accesskey/" + objectId + "/" + accessKeyId,
            type: 'DELETE',
            success: function(data) {
                location.reload();
            },
            error: function(data) {
                enableButtons();
            }
        });
    });

    $('#accessKeyGenerator').click(function() {
        const key = generateKey(32);
        $("#accessKeyValue").val(key);
    });

    $('#accessKeyUpdate').click(function() {
        disableButtons();
        const accessKeyId = $(this).data('id');
        const type = $("#accessKeyType").val();
        const value = $("#accessKeyValue").val();
        const accessKey = {"id": accessKeyId, "type": type, "value": value};

        if (value.length == 0) {
            $("#accessKeyValue").addClass("is-invalid");
            enableButtons();
            return;
        }
        
        $.ajax({
            url: webApplicationBaseURL + "rsc/accesskey/" + objectId + "/" + accessKeyId,
            type: 'POST',
            data: JSON.stringify(accessKey),
            contentType: 'application/json',
            success: function(data) {
                location.reload();
            },
            error: function(data) {
                if (data.status == 400) {
                    $('#accessKeyModalAlert').html(data.responseText);
                    $('#accessKeyModalAlert').show();
                }
                enableButtons();
            }
        });
    });

    $.ajax({
        url: webApplicationBaseURL + "rsc/accesskey/",
        error: function() {
            $('#mainError').show();
            $('#manageAccessKeys').hide();
        },
        success: function(data) {
            proccessAccessKeyInformation(data);
        },
        type: 'GET'
    });

});

