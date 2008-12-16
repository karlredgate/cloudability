// Display functions

c10y.display = {

    // Translate field names into user-friendly table headers

    fieldNames: {
        aws_architecture: 'Architecture',
        aws_image_id: 'Image ID',
        aws_instance_id: 'Instance ID',
        aws_public_ip: 'Internet IP',
        aws_snapshot_id: 'Snapshot ID',
        aws_volume_id: 'Volume ID',
        aws_state: 'State',
        created_at: 'Create time',
        deleted_at: 'Delete time'
    },

    // List the fields shown for each entity

    fields: {
        addresses: ['aws_public_ip', 'aws_instance_id', 'created_at', 'deleted_at'],
        images: ['aws_image_id', 'aws_architecture', 'aws_state'],
        instances: ['aws_instance_id'],
        snapshots: ['aws_snapshot_id'],
        volumes: ['aws_volume_id']
    },

    // Update the display of an entity list
 
    update: function(entity) {
        c10y.assert(entity, 'c10y.display.update(entity)');
        var html = c10y.display.table(c10y.display.fields[entity], AWS[entity]);
        $('#information').text('');
        $('#'+entity).html(html);
    },

    // Turn a list of objects into a table of fields

    table: function(fields, list) {
        var html = '<table><tr>';
        for (var f in fields) {
            var field = fields[f];
            if (c10y.display.fieldNames[field]) {
                field = c10y.display.fieldNames[field];
            }
            html += '<th>' + field + '</th>';
        }
        html += '</tr>';
        for (var l in list) {
            html += c10y.display.row(fields, list[l]);
        }
        html += '</table>';
        return html;
    },

    // Extract fields from an item to make a table row

    row: function(fields, item) {
        var html = '<tr>';
        for (var f in fields) {
            var field = fields[f];
            html += '<td>' + item[field] + '</td>';
        }
        html += '</tr>';
        return html;
    }
};
