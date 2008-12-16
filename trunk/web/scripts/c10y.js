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

    username: '',
    token: '',

    // Perform a named assertion

    assert: function(test, name) {
        if (!test) throw('Assertion failed: ' + name);
    },

    // Display an information message

    inform: function(message) {
        $('#information').text(message);
    }
};
