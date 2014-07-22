
(function(){

    this.Terraling = this.Terraling || {};
    
    // setup the promises store
    this.Terraling.promises = {};

    var util = this.Terraling.Util = {};
    
    var img = "<img src='/images/loader.gif' class='loading'/>",
        previousURL = location.href,
        once = false;

    var cacheEnabled;

    util.init = function(){

      // check for localStorage
      cacheEnabled = Modernizr.localstorage;

      // PAGINATION CODE
      activatePagination();
      
      // DROPDOWN CODE
      activateDropdowns();

      // TOOLTIP CODE
      $("[rel='tooltip']").tooltip();

      // LOAD GROUPS JSON
      loadGroupsData();

      // LOAD Handlebars Templates
      loadTemplates();
    };

    function activatePagination(){
      // Manage the AJAX pagination and changing the URL
       $(document).on("click", ".will-paginate .pagination a", function (e) {
          // local history 
          previousURL = this.href;

          $(".pagination").html(img);
          $.get(this.href, function(result) {
            $("#pagination_table").html($("#pagination_table", result).contents());
          });
          history.pushState(null, document.title, this.href);

          e.preventDefault();

      });
      
      $(window).bind("popstate", function (evt) {
        // prevent requests if the hash is the only change!
        var hashCheck = location.hash;
        if (previousURL.indexOf(hashCheck) < 0) {
          $(".pagination").html(img);
          $.get(location.href, function(result) {
            $("#pagination_table").html($("#pagination_table", result).contents());
          });
        }
      });
    }

    function activateDropdowns(){
      
      function fadeDropdown(){
        $(this).find('.dropdown-menu').stop(true, true).fadeToggle();
      }
      $('ul.nav li.dropdown').hover(fadeDropdown, fadeDropdown);
    }

    function getGroups(url){
      var groups = get(url);
      
      // return null if any of these doesn't pass
      if(!groups || !groups[T.currentGroup] ||
         olderThanOneDay(groups.__ttl) ){
        // refresh groups every day
        return null;
      }
      return groups;
    }

    function olderThanOneDay(date){
      return date - (new Date()).getTime() > 86400000;
    }

    function get(key){
      if(cacheEnabled){
        if(key in localStorage){
          return JSON.parse(localStorage[key]);
        }
      }
    }

    function save(key, value){
      // if localstorage
      if(cacheEnabled){
        localStorage[key] = JSON.stringify(value);
      }
    }

    function loader(url, namespace, cacheFn, processFn){
      // if localstorage is enabled use it
      var request = cacheFn('__'+url);

      if(!request){
        // save the promise
        request = $.get(url)
        // Note: the browser should cache itself the request
        // and reply after the first call with a 304 Status Code
        // in case of no localStorage
          .done(processFn)
          .fail()
          .always();
      } else {
        Terraling[namespace] = request;
      }

      Terraling.promises[namespace] = request;
    }

    function loadGroupsData(){

      var url = '/groups/list';
      // if localstorage is enabled, use it
      request = getGroups('__'+url);
      loader(url, 'groups', getGroups, function (data){

        Terraling.groups = {};
        // map the data to an object in the format id => group
        $.each(data, function (i, wrapper){
          // for the moment just append it to the Terraling object
          Terraling.groups[wrapper.group.id] = wrapper.group;
        });
        // Quick and dirty clone
        var copy = JSON.parse(JSON.stringify(T.groups));
        // set  timestamp
        copy.__ttl = (new Date()).getTime();
        save("__"+url, copy);
      });
    }

    function loadTemplates(){
      var url = '/templates';

      loader(url, 'templates', getTemplates, function (templates){

        Terraling.templates = $(templates);

        // Quick and dirty clone
        var copy = JSON.parse(JSON.stringify({html: templates}));
        // set  timestamp
        copy.__ttl = (new Date()).getTime();
        save("__"+url, copy);

      });

      // just need to replace the current templates in case it was cached
      if(T.templates){
        T.templates = $(T.templates.html);
      }
    }

})();