let accessKeys = undefined;

function getParameterByName(name, url = window.location.href) {
    name = name.replace(/[\[\]]/g, '\\$&');
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
    results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
}

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

function getObjectById(objects, id) {
    for (key in objects) {
        if (objects.hasOwnProperty(key)) {
            const object = objects[key];
            if (object.hasOwnProperty('id')) {
                if (object['id'] == id) {
                    return object;
                }
            }
        }
    }

    return undefined;
}

$(document).ready(function() {
    const objectId = getParameterByName('objectid'); 

    $("#accessKeyNew").click(function() {
        const type = $("#accessKeyType").val();
        const value = $("#accessKeyValue").val();
        const accessKey = {"type": type, "value": value};

        $.ajax({
            url: webApplicationBaseURL + "rsc/miraccesskeyinformation/" + objectId + "/accesskey",
            type: 'PUT',
            data: JSON.stringify(accessKey),
            contentType: 'application/json',
            success: function(data) {
                addAccessKeyTableRow(accessKey);
                $('#accessKeyModal').modal('hide');
            }   
        });
    });

    $(document).on("click", ".newAccessKeyModal", function () {
        $("#accessKeyValue").val("");
        $("#accessKeyType option")[0].selected = true;
        $('#accessKeyDelete').hide();
        $('#accessKeyUpdate').hide();
        $('#accessKeyNew').show();
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
    });

    $('#accessKeyDelete').click(function() {
        const accessKeyId = $(this).data('id');
        $.ajax({
            url: webApplicationBaseURL + "rsc/miraccesskeyinformation/" + objectId + "/accesskey/" + accessKeyId,
            type: 'DELETE',
            success: function(data) {
                //TODO delete from row
                $('#accessKeyModal').modal('hide');
            }   
        });
    });

    $('#accessKeyUpdate').click(function() {
        const accessKeyId = $(this).data('id');
        const type = $("#accessKeyType").val();
        const value = $("#accessKeyValue").val();
        const accessKey = {"id": accessKeyId, "type": type, "value": value};
        
        console.log(accessKey);

        $.ajax({
            url: webApplicationBaseURL + "rsc/miraccesskeyinformation/" + objectId + "/accesskey",
            type: 'POST',
            data: JSON.stringify(accessKey),
            contentType: 'application/json',
            success: function(data) {
                $('#accessKeyModal').modal('hide');
            }   
        });
    });



    $.ajax({
        url: webApplicationBaseURL + "rsc/miraccesskeyinformation/" + objectId,
        error: function() {
            console.log("errror");
        },
        success: function(data) {
            proccessAccessKeyInformation(data);
        },
        type: 'GET'
    });
});

