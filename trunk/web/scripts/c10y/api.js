// API functions

c10y.api = {

    // Refresh the entity lists

    refresh: function() {
        c10y.api.doAWS('dad'); // addresses
        c10y.api.doAWS('dim'); // images
        c10y.api.doAWS('din'); // instances
        c10y.api.doAWS('dsnap'); // snapshots
        c10y.api.doAWS('dvol'); // volumes
    },

    // Login to get an API token

    doLogin: function(username, password) {
        c10y.username = username;
        var params = {
            username: username,
            password: password,
            format: 'json'
        };
        $.getJSON('/api/token.cgi', params, c10y.api.cbLogin);
    },

    // Callback with API token data

    cbLogin: function(data, status) {
        try {
            c10y.assert(status == 'success', 'cbLogin success');
            if (data.error) throw(data.error);

            // Remember our API token

            c10y.assert(data.token, 'cbLogin has a token');
            c10y.token = data.token.text;

            // Update our AWS resources

            c10y.api.refresh();

        } catch(message) {
            c10y.display.inform(message, '#loginError');
        }
    },

    // Perform an AWS command

    doAWS: function(command) {
        var params = {
            token: c10y.token,
            command: command,
            format: 'json'
        };
        $.getJSON('/api/aws.cgi', params, c10y.api.cbAWS);
    },

    // Callback with AWS command results

    cbAWS: function(data, status) {
        try {
            c10y.assert(status == 'success', 'cbAWS success');
            if (data.error) throw(data.error);

            if (data.addresses) c10y.api.update('addresses', data.addresses.address);
            if (data.images) c10y.api.update('images', data.images.image);
            if (data.instances) c10y.api.update('instances', data.instances.instance);
            if (data.snapshots) c10y.api.update('snapshots', data.snapshots.snapshot);
            if (data.volumes) c10y.api.update('volumes', data.volumes.volume);
        } catch(message) {
            c10y.display.inform(message);
        }
    },

    // Update the AWS data and display

    update: function(entity, data) {
        AWS[entity] = data;
        c10y.display.update(entity);
    },

    // Serialize a simple hash as a JSON string

    toJSON: function(hash) {
        var json = '{';
        for (k in hash) {
            var key = k;
            var value = hash[key];
            if (!value) continue;
            if (value instanceof Function) continue;
            if (value.replace instanceof Function) {
                value.replace('"', '\"');
                value = '"' + value + '"';
            } else if (value instanceof Object) {
                value = c10y.api.toJSON(value);
            }
            json += '"' + key + '":' + value + ','; 
        }
        return json.replace(/,$/, '}');
    }
};
