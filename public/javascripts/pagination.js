// To avoid conflict with Prototype library
jQuery.noConflict();

jQuery(function() {
    // Manage the AJAX pagination and changing the URL
    jQuery(".pagination a").live("click", function(e) {
        var img = "<img src='/images/loader.gif' class='loading'/>"
        var text = "<span class='loading'>Page is loading...</span>"
        //jQuery.setFragment({ "page" : jQuery.queryString(this.href).page })
        jQuery.getScript(this.href);
        jQuery(".pagination").html(text+img);
        history.pushState(null, document.title, this.href);
        e.preventDefault();
    });

    // Let navigate the browser thru the AJAX history
    jQuery(window).bind("popstate", function() {
        jQuery.getScript(location.href);
    });
});
