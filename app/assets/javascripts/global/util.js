
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

      // MESSAGE / NOTICE CODE
      activateTimerForMessages();

      // TOOLTIP CODE
      $("[rel='tooltip']").tooltip();
      $(window).bind("popstate", function (evt) {
        $("[rel='tooltip']").tooltip();
      });

      // LOAD GROUPS JSON
      loadGroupsData();
      
      // some handy functions
      util.isThere = isThere;
      util.makeChunks = makeChunks;
      util.isFileSaverSupported = canSave;
    };

    function makeChunks(list, size){
      // take the list and make chunks of the given size
      var steps = Math.floor(list.length / size) + 1;
      
      var chunks = [];
      for( var i=0; i< steps; i++){
        var offset = i * size;
        // slice goes from begin to end-1
        chunks.push(list.slice(offset, offset + size));
      }
      // Handle last bit
      if(list[steps * size]){
        chunks.push(list.slice(steps * size));
      }

      return chunks;
    }

    function isThere(){
      if(arguments.length){
        var array = Array.prototype.slice.call(arguments),
            obj = array.shift(),
            new_obj = obj;
        while(array.length && new_obj){
          new_obj = new_obj[array.shift()];
        }

        return (!array.length && !!new_obj);
      }
      return false;
    }

    function activatePagination(){

      if(!$('.js-pagination').length){
        // Manage the AJAX pagination and changing the URL (Do not bind to alpha_pagination tables)
         $(document).on("click", ".pagination:not(.alpha) a", function (e) {
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
         olderThanOneDay(groups.ttl) ){
        // refresh groups every day
        return null;
      }
      return groups;
    }

    function getTemplates(url){
      var templates = get(url);
      
      // return null if any of these doesn't pass
      if(!templates ||
         olderThanOneDay(templates.ttl) ){
        // refresh templates every day
        return null;
      }
      return teamplates.html;
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
          .fail(function(){
            console.log(arguments);
          })
          .always(function(){
            // console.log(arguments);
          });
      } else {
        Terraling[namespace] = request;
      }

      Terraling.promises[namespace] = request;
    }

    function loadGroupsData(){

      var url = '/groups/list';
      // if localstorage is enabled, use it
      request = getGroups('Terraling:Groups:'+url);
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
        copy.ttl = (new Date()).getTime();
        save("Terraling:Groups:"+url, copy);
      });
    }

    var canSaveVar;

    function canSave(){
      canSaveVar = canSaveVar || saveTest();
      return canSaveVar;
    }

    function saveTest(){
      var isFileSaverSupported;
      try {
        isFileSaverSupported = !!new Blob();
      } catch (e) {}
      return isFileSaverSupported;
    }

    function activateTimerForMessages(){
      var el = $('#messages .alert');
      if(el.length){
        $('.show-header').addClass('messages');
        setTimeout(fadeOut, 5000, el);
      }
    }

    function fadeOut(elements){
      if(elements){
        elements.fadeOut('fast');
        $('.show-header').removeClass('messages');
      }
    }

})();