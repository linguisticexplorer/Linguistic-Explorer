/* On DOM loaded */
$(function() {

  // Text and image while loading
  var img = "<img src='/images/loader.gif' class='loading'/>"
  var text = "<span class='loading'>Page is loading...</span>"

  // Manage the AJAX pagination and changing the URL
  $(".pagination a").live("click", function(e) {
      //jQuery.setFragment({ "page" : jQuery.queryString(this.href).page })
      jQuery.getScript(this.href);
      jQuery(".pagination").html(text+img);
      history.pushState(null, document.title, this.href);
      e.preventDefault();
  });

  // Let navigate the browser throught the AJAX history
  $(window).bind("popstate", function() {
      $.getScript(location.href);
      $(".pagination").html(text+img);
  });
});
