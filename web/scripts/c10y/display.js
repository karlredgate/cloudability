// Display functions

c10y.display = {

    // Translate field names into user-friendly table headers

    fieldNames: {
        aws_architecture: 'Architecture',
        aws_finished_at: 'Finish time',
        aws_image_id: 'Image ID',
        aws_inst_state: 'State',
        aws_instance_id: 'Instance ID',
        aws_private_dns: 'Private DNS',
        aws_progress: 'Completed',
        aws_public_dns: 'Public DNS',
        aws_public_ip: 'Internet IP',
        aws_snapshot_id: 'Snapshot ID',
        aws_volume_id: 'Volume ID',
        aws_started_at: 'Snapshot time',
        aws_state: 'State',
        aws_term_reason: 'Termination reason',
        created_at: 'Create time',
        deleted_at: 'Delete time',
        format_dns: 'DNS addresses',
        format_ip: 'Internet IP',
        format_created_at: 'Create time',
        format_deleted_at: 'Delete time',
        format_finished_at: 'Finish time'
    },

    about: {
        addresses: '<p>IP addresses to associate with running instances</p>',
        images: '<p>Amazon machine images available to run</p>',
        instances: '<p>Running instances of Amazon machine images</p>',
        snapshots: '<p>Snapshots of storage volumes</p>',
        volumes: '<p>Storage volumes to attach to running instances</p>'
    },

    // List the fields shown for each entity

    fields: {
        addresses: ['format_ip', 'aws_instance_id', 'format_created_at', 'format_deleted_at'],
        images: ['aws_image_id', 'aws_architecture', 'aws_state'],
        instances: ['aws_inst_state', 'aws_instance_id', 'aws_image_id', 'format_dns', 'format_finished_at', 'aws_term_reason'],
        snapshots: ['aws_snapshot_id', 'aws_volume_id', 'aws_progress', 'aws_started_at', 'deleted_at'],
        volumes: ['aws_volume_id', 'aws_instance_id']
    },

    // Display a message

    inform: function(message, el) {
        if (!el) el = '#message';
        $(el).text(message);
    },

    // Update the display of an entity list
 
    update: function(entity) {
        c10y.assert(entity, 'c10y.display.update(entity)');
        var html = c10y.display.about[entity];
        c10y.display.format(entity, AWS[entity]);
        html += c10y.display.table(c10y.display.fields[entity], AWS[entity]);
        $('#message').text('');
        $('#'+entity).html(html);
    },

    // Format an entity list to look nice

    format: function(entity, list) {
        for (var l in list) {
            var row = list[l];
            for (r in row) { if (!row[r]) row[r] = '' }
            if (row.aws_public_dns) row.format_dns = '<b>Public:</b> <a href="http://' + row.aws_public_dns + '" target="_blank">' + row.aws_public_dns + '</a><br/><b>Private:</b> ' + row.aws_private_dns;
            if (row.aws_public_ip) row.format_ip = '<a href="http://' + row.aws_public_ip + '" target="_blank">' + row.aws_public_ip + '</a>';
            row.format_created_at = row.created_at ? c10y.display.formatDate(row.created_at) : '';
            row.format_deleted_at = row.deleted_at ? c10y.display.formatDate(row.deleted_at) : '';
            row.format_finished_at = row.aws_finished_at ? c10y.display.formatDate(row.aws_finished_at) : '';
        }
    },

    // Format a date so it looks nicer

    formatDate: function(YYYY_MM_DD_hh_mm_ss) {
        var date = c10y.utils.newDate(YYYY_MM_DD_hh_mm_ss);
        return date.toLocaleString();
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
