// Utility functions

c10y.utils = {

    // Create a new date object from a string of the form "YYYY-MM-DD hh:mm:ss"

    newDate: function(YYYY_MM_DD_hh_mm_ss) {
        if (!YYYY_MM_DD_hh_mm_ss) return '';
        var date_time = YYYY_MM_DD_hh_mm_ss.split(' ');
        var d = date_time[0].split('-');
        var t = date_time[1].split(':');
        return (new Date(d[0], d[1]-1, d[2], t[0], t[1], t[2]));
    }
};
