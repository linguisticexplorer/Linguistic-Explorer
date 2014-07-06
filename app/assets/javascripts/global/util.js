
(function(){

    this.Terraling = this.Terraling || {};
    
    // setup the promises store
    this.Terraling.promises = {};

    var util = this.Terraling.Util = {};
    
    var img = "<img src='/images/loader.gif' class='loading'/>",
        once = false;

    util.init = function(){

      // PAGINATION CODE
      activatePagination();
      
      // DROPDOWN CODE
      activateDropdowns();

      // TOOLTIP CODE
      $("[rel='tooltip']").tooltip();

      // LOAD GROUPS JSON
      loadGroupsData();
    };

    function activatePagination(){
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
    }

    function activateDropdowns(){
      
      function fadeDropdown(){
        $(this).find('.dropdown-menu').stop(true, true).fadeToggle();
      }
      $('ul.nav li.dropdown').hover(fadeDropdown, fadeDropdown);
    }

    function loadGroupsData(){

      // save the promise
      Terraling.promises.groups = $.get('/groups/list')
        .done(function (data){

          Terraling.groups = {};
          // map the data to an object in the format id => group
          $.each(data, function (i, wrapper){
            // for the moment just append it to the Terraling object
            Terraling.groups[wrapper.group.id] = wrapper.group;
          });
        })
        .fail()
        .always();
    }

    var delayBindArray = [];

    function bind(controller, main, other){
      delayBindArray.push({c: controller, from: main, to: other});
    }

})();