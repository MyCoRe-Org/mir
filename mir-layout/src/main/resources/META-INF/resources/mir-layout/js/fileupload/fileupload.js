var bytesUploaded = 0;
var bytesTotal = 0;
var previousBytesLoaded = 0;
var intervalTimer = 0;
var chosenFiles = new Array();
var toggables = new Array();
var xhr = new XMLHttpRequest();

var UPLOAD_STATES = { start: 1, filesSelected: 2, uploading: 3, finished: 4, cancelled: 5, failed: 6 };
var currentUploadState = UPLOAD_STATES.start;

var dropbox = document.getElementById('dropbox');
dropbox.ondragenter = dragEnter;
dropbox.ondragleave = dragLeave;
dropbox.ondragover = noop;
dropbox.ondrop = drop;

function dragEnter(evt) {
    noop(evt);
    jQuery('#dropbox').toggleClass('highlight');
}
function dragLeave(evt) {
    noop(evt);
    jQuery('#dropbox').toggleClass('highlight');
}
function drop(evt) {

    currentUploadState = UPLOAD_STATES.filesSelected;
    noop(evt);
    var dropbox = jQuery('#dropbox');
    
    jQuery('#dropAdvice').remove();
    
    dropbox.toggleClass('highlight');
    
    var files = evt.dataTransfer.files;
    var count = files.length;
    if (count > 0) {
        for (i = 0; i < count; i++) {
            appendFile(files[i]);
        }
    }
}

function noop(evt) {
    evt.stopPropagation();
    evt.preventDefault();
}

function fileSelected() {

    currentUploadState = UPLOAD_STATES.filesSelected;
    var file = document.getElementById('fileToUpload').files[0];
    appendFile(file);
    
}

function appendFile(file) {
    chosenFiles.push(file);
    var filesContainer = jQuery('#files');
    filesContainer.append('<span class="fileContainer"><span class="filename">' + file.name + '</span><button class="removeFile" /><span>');
    calcSize();
    toggleActions();
}

function calcSize() {
    var fileSize = 0;
    for (i in chosenFiles) {
        var file = chosenFiles[i];
        fileSize = fileSize + file.size;
    }
    if (fileSize > 1024 * 1024)
        fileSize = (Math.round(fileSize * 100 / (1024 * 1024)) / 100).toString() + 'MB';
    else
        fileSize = (Math.round(fileSize * 100 / 1024) / 100).toString() + 'KB';
    jQuery('#fileSize').text('Größe: ' + fileSize);
}

function cancelUpload() {
    xhr.abort();
}

function uploadFile() {
    currentUploadState = UPLOAD_STATES.uploading;
    toggleActions();

    previousBytesLoaded = 0;
    jQuery('#progressNumber').text('');
    var progressBar = jQuery('#progressBar');
    progressBar.css('display', 'block');
    progressBar.css('width', '0px');
    var url = formUploadUrl;
    var params = getUrlVars(url);

    var fd = new FormData();
    for (i in chosenFiles) {
        var key = "/upload/path/" + chosenFiles[i].name;
        var value = chosenFiles[i];
        fd.append(key, value);
    }
    for (key in params) {
        fd.append(key, params[key]);
    }

    xhr.upload.addEventListener("progress", uploadProgress, false);
    xhr.addEventListener("load", uploadComplete, false);
    xhr.addEventListener("error", uploadFailed, false);
    xhr.addEventListener("abort", uploadCanceled, false);
    xhr.open("POST", url);
    xhr.send(fd);

    intervalTimer = setInterval(updateTransferSpeed, 500);
}

function updateTransferSpeed() {
    var currentBytes = bytesUploaded;
    var bytesDiff = currentBytes - previousBytesLoaded;
    if (bytesDiff == 0)
        return;
    previousBytesLoaded = currentBytes;
    bytesDiff = bytesDiff * 2;
    var bytesRemaining = bytesTotal - previousBytesLoaded;
    var secondsRemaining = bytesRemaining / bytesDiff;

    var speed = "";
    if (bytesDiff > 1024 * 1024)
        speed = (Math.round(bytesDiff * 100 / (1024 * 1024)) / 100).toString() + 'MBps';
    else if (bytesDiff > 1024)
        speed = (Math.round(bytesDiff * 100 / 1024) / 100).toString() + 'KBps';
    else
        speed = bytesDiff.toString() + 'Bps';
    jQuery('#transferSpeedInfo').text(speed);
    jQuery('#timeRemainingInfo').text('| ' + secondsToString(secondsRemaining));
}

function secondsToString(seconds) {
    var h = Math.floor(seconds / 3600);
    var m = Math.floor(seconds % 3600 / 60);
    var s = Math.floor(seconds % 3600 % 60);
    return ((h > 0 ? h + ":" : "")
            + (m > 0 ? (h > 0 && m < 10 ? "0" : "") + m + ":" : "0:")
            + (s < 10 ? "0" : "") + s);
}

function uploadProgress(evt) {
    if (evt.lengthComputable) {
        bytesUploaded = evt.loaded;
        bytesTotal = evt.total;
        var percentComplete = Math.round(evt.loaded * 100 / evt.total);
        var bytesTransfered = '';
        if (bytesUploaded > 1024 * 1024)
            bytesTransfered = (Math.round(bytesUploaded * 100 / (1024 * 1024)) / 100).toString() + 'MB';
        else if (bytesUploaded > 1024)
            bytesTransfered = (Math.round(bytesUploaded * 100 / 1024) / 100).toString() + 'KB';
        else
            bytesTransfered = (Math.round(bytesUploaded * 100) / 100).toString() + 'Bytes';

        jQuery('#progressNumber').text(percentComplete.toString() + '%');
        jQuery('#progressBar').css('width', percentComplete.toString() + '%');
        jQuery('#transferBytesInfo').text(bytesTransfered);
    } else {
        jQuery('#progressBar').text('unable to compute');
    }
}

function uploadComplete(evt) {
    currentUploadState = UPLOAD_STATES.finished;
    toggleActions();

    clearInterval(intervalTimer);
    jQuery('#progressNumber').text('100%');
    jQuery('#progressBar').css('width', '100%');
    showUploadResponse();
    jQuery('#uploadDone p').text(msgUploadSuccessful);
    clearFiles();
}

function uploadFailed(evt) {
    currentUploadState = UPLOAD_STATES.failed;
    toggleActions();
    
    clearInterval(intervalTimer);
    showUploadResponse();
    jQuery('#uploadDone p').text(msgUploadFailed);
}

function uploadCanceled(evt) {
    currentUploadState = UPLOAD_STATES.cancelled;
    toggleActions();
    
    clearInterval(intervalTimer);
    showUploadResponse();
    jQuery('#uploadDone p').text(msgUploadFailed);
}

function getUrlVars(url) {
    var vars = {};
    var parts = url.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
        vars[key] = value;
    });
    return vars;
}

function showUploadResponse() {
    jQuery('#uploadResponse').css('display', 'block');
}

function clearFiles() {

    currentUploadState = UPLOAD_STATES.start;
    toggleActions();
    
    chosenFiles = new Array();
    var delay = 0;
    jQuery('#files span').each(function() {
        jQuery(this).fadeOut(400, function() {
            jQuery(this).remove();
            calcSize();
        });
    });
    jQuery('#fileToUpload').val('');
}

function toggleActions() {

    for (key in toggables) {
      var object = toggables[key];
      object.button.detach();
      object.isAttached = false;
    }
    
    switch (currentUploadState) {
        case UPLOAD_STATES.start:
        case UPLOAD_STATES.finished:
            hideButton(toggables['uploadBtn']);
            hideButton(toggables['cancelBtn']);
            hideButton(toggables['clearBtn']);
            showButton(toggables['backBtn']);
            break;
        case UPLOAD_STATES.filesSelected:
        case UPLOAD_STATES.cancelled:
        case UPLOAD_STATES.failed:
            showButton(toggables['uploadBtn']);
            hideButton(toggables['cancelBtn']);
            showButton(toggables['clearBtn']);
            showButton(toggables['backBtn']);
            break;
        case UPLOAD_STATES.uploading:
            hideButton(toggables['uploadBtn']);
            showButton(toggables['cancelBtn']);
            hideButton(toggables['clearBtn']);
            hideButton(toggables['backBtn']);
            break;
    }
}

function showButton(object) {
    var parent = object.parent;
    var toggable = object.button;
    
    if (!object.isAttached) {
      parent.append(toggable);
      object.isAttached = true;
    }
}

function hideButton(object) {
    var parent = object.parent;
    var toggable = object.button;
    
    if (object.isAttached) {
      toggable.detach();
      object.isAttached = false;
    }
}

jQuery(document).ready(function() {
    
    if (!!window.FileReader && Modernizr.draganddrop) {
        jQuery('#uploadContainer').css('display', 'block');
        
        jQuery('#files').delegate('button', 'click', function(evt) {
            noop(evt);
            var fileContainer = jQuery(this).parent();
            index = fileContainer.index();
            
            chosenFiles.splice(index, 1);
            jQuery(fileContainer).fadeOut(400, function() {
                fileContainer.remove();
            });
            calcSize();
        });
        jQuery('.appletUpload').remove();
        
        jQuery('.toggable').each(function() {
          toggables[jQuery(this).attr('id')] = {
            'parent': jQuery(this).parent(),
            'button': jQuery(this),
            'isAttached' : true 
          };
        });
        toggleActions();
    }
});
