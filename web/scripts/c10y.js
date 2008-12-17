// AWS state

var AWS = {
    addresses: [],
    images: [],
    instances: [],
    snapshots: [],
    volumes: []
};

// Cloudability API, depends on jQuery.

var c10y = {

    INTERVAL: 1000, // milliseconds
    TIMEOUT: 5000, // milliseconds
    username: '',
    token: '',

    // Perform a named assertion

    assert: function(test, name) {
        if (!test) throw('Assertion failed: ' + name);
    },

    // Initialize the Cloudability web interface 

    init: function() {
        $.ajaxSetup({
            type: 'POST',
            timeout: c10y.TIMEOUT,
            dataType: 'json',
            error: function(xhr) {
                $('#information').text('Error: ' + xhr.status + ' ' + xhr.statusText);
            }
        });

        setInterval(function () { c10y.run() }, c10y.INTERVAL);
    },

    run: function() {
        this.dialogs();
    },

    dialogs: function() {
        if (this.token == '') {
            $('#dialog').jqm({ajax: 'dialogs/login.html', modal: true});
            $('#dialog').jqmShow();
            this.token = '?';
        } else if (this.token != '?') {
            $('#dialog').jqmHide();
        }
    }
};
