// Just some cookie utils from: http://www.quirksmode.org/js/cookies.html
var Cookie = { 
    create: function(name, value, days) {
        if (days) {
            var date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            var expires = "; expires=" + date.toGMTString();
        }
        else var expires = "";
        document.cookie = name + "=" + value + expires + "; path=/";
    },

    read: function(name) {
        var nameEQ = name + "=";
        var ca = document.cookie.split(';');
        for (var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1, c.length);
            }
            if (c.indexOf(nameEQ) == 0) {
                return c.substring(nameEQ.length, c.length);
            }
        }
        return null;
    },

    erase: function(name) {
        createCookie(name, "", -1);
    }
}

window.addEventListener('beforeunload', pageClosed, false);
window.addEventListener('load', pageOpened, false);

function pageOpened() {
    var timestampString = Cookie.read('closeTester');
    if (timestampString) {
        var timestamp = new Date(timestampString);
        var temp = new Date();
        temp.setMinutes(temp.getMinutes() - 1, temp.getSeconds() - 30);

        // If this is true, the load is a re-load/refresh
        if (timestamp > temp) {
            var counter = Cookie.read('counter');
            if (counter) {
                counter++;
                Cookie.create('counter', counter);
            } else {
                Cookie.create('counter', 1);
            }
        }
        Cookie.erase('closeTester');
    }
}

function pageClosed() {
    Cookie.create('closeTester', new Date());
}