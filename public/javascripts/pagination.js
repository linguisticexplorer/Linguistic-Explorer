// To avoid conflict with Prototype library
jQuery.noConflict();

jQuery(function() {

    // Text and image while loading
    var img = "<img src='/images/loader.gif' class='loading'/>"
    var text = "<span class='loading'>Page is loading...</span>"

    // Manage the AJAX pagination and changing the URL
    jQuery(".pagination a").live("click", function(e) {
        //jQuery.setFragment({ "page" : jQuery.queryString(this.href).page })
        jQuery.getScript(this.href);
        jQuery(".pagination").html(text+img);
        history.pushState(null, document.title, this.href);
        e.preventDefault();
    });

    // Let navigate the browser throught the AJAX history
    jQuery(window).bind("popstate", function() {
        jQuery.getScript(location.href);
        jQuery(".pagination").html(text+img);
    });
});
