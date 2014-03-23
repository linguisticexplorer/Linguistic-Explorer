/* On DOM loaded */
$(function() {

    // PAGINATION CODE
    
    var img = "<img src='/images/loader.gif' class='loading'/>",
        once = false;

    // Manage the AJAX pagination and changing the URL
     $(document).on("click", ".apple_pagination.will-paginate .pagination a", function (e) {

        $(".pagination").html(img);
        $.get(this.href, function(result) {
          $(".pagination").html($(".pagination", result)[0]);
          $("#pagination_table").html($("#pagination_table", result));
        });
        history.pushState(null, document.title, this.href);
        e.preventDefault();
    });
    
    $(window).bind("popstate", function() {
      if (once) {
        $(".pagination").html(img);
        $.get(location.href, function(result) {
            $(".pagination").html($(".pagination", result));
            $("#pagination_table").html($("#pagination_table", result));
        });
      } else {
        once = true;
      }
    });

});