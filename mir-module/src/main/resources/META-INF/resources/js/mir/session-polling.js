$(document).ready(function() {
    setInterval(function(){
        $.get(webApplicationBaseURL + 'rsc/echo/ping');
    }, 1740000);
});