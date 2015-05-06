(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.show = searches.preview || {};

  searches.preview.table = {init: initTable };

  function initTable(data, templateFn, pageMaker){

    var resultsJson = data;
    var makeNewPage = pageMaker;
    var getTemplate = templateFn;
    var renderer;


    var currentPage;
    var paginationSetup;


    function render(data, tableId, paginationId){
      if(data.table){
        $(tableId).html(data.table);
      }
      if(data.pagination){
        $(paginationId).html(data.pagination);
        bindPagination();
      }
    }

    function createTable(offset, max_rows){
      // Set first some default params
      var max_rows_per_page = max_rows || 25,
          rows = resultsJson.rows;

      var offsetLimit = max_rows_per_page * (offset + 1),
          rowsLimit   = rows.length;

      offset = offset || 0;

      // create a renderer in case is not set yet
      renderer = renderer || searches.preview[resultsJson.type].init(resultsJson, getTemplate);
      // create the table with the header and basic scaffolding
      var table = renderer.makeTable();
      
      // headers have different format
      var header = getHeader(table);
      
      for(var i=offset * max_rows_per_page; i< rowsLimit && i< offsetLimit; i++){
        table.rows.push(renderer.makeRow(header, rows[i], i));
      }

      renderer.finalize(table);

      return table;
    }

    function getHeader(table){
      switch (resultsJson.type){
        case 'compare':
        case 'default':
          return table.header;
        case 'cross':
        case 'implication':
          return table;
        default:
          // Fail silently....
          return {};
      }
    }
    
    // PAGINATION CODE
    function createPagination(offset, max_rows){

      function pageToShow(n, avg, max, cur){
        // First two pages
        return n === 1      || n === 2      ||
        // Pages in the middle
               n === avg-1  || n === avg    || n === avg+1 ||
        // Last pages
               n === max-1  || n === max    ||
        // Pages around the chosen one
               n === cur-1  || n === cur    || n === cur+1;
      }

      // start to count from 1 instead of 0
      var page_offset = offset + 1;
      var max_rows_per_page = max_rows || 25;

      var pages = [];
      var prev = {disabled: (page_offset === 1) },
          next = {disabled: (!resultsJson.rows[page_offset*max_rows_per_page]) };

      var pages_total = Math.ceil(resultsJson.rows.length / max_rows_per_page),
          half_total  = pages_total / 2;

      var middle_page = Math.floor(half_total) === half_total ?
            half_total :
            Math.floor(half_total) + 1;

      for(var page = 1; page<=pages_total; page++){

        // if there are 15 pages or less it's ok, otherwise check for specific pages
        if(pages_total < 16 || pageToShow(page, middle_page, pages_total, page_offset)){
          pages.push({number: page, current: (page === page_offset)});
          // save the current offset
          if(page === page_offset){
            currentPage = page;
          }
        }
        else {
          // add a gap only if it's not there yet...
          if(!pages[pages.length - 1].gap){
            pages.push({gap: true});
          }
        }
        
        // add prev and next buttons
        if(!prev.disabled && page + 1 === page_offset){
          prev.number = page;
        }

        if(!next.disabled && page - 1 === page_offset){
          next.number = page;
        }
      }
      return {pages: pages, prev: prev, next: next};
    }

    function bindPagination(){

      if(!paginationSetup){


        // Text and image while loading
        // TODO: Make this check somehow to see if a .js.erb file exists
        // Alterntaively, create one for every view, but not recommended
        
        var img = HoganTemplates['waiting'].render({medium: true, color: '#5bd0de'}),
            once = false;
        // Manage the AJAX pagination and changing the URL
         $(document).on("click", ".js-pagination a", function (e) {

            var offset = getOffset(e.target.id);
            var current = getCurrentPage();

            $(".js-pagination").html(img);
            makeNewPage(resultsJson, offset);
            
            
            history.pushState(current, document.title + '- Page '+current, '#');
            e.preventDefault();
        });
        
        $(window).bind("popstate", function (e) {
          // console.log(e.originalEvent.state);
          if (e.originalEvent.state) {
            var offset = e.originalEvent.state;
            $(".js-pagination").html(img);
            makeNewPage(resultsJson, offset);
            e.preventDefault();
          }
        });

        paginationSetup = true;
      }
    }

    function getCurrentPage(){
      return currentPage;
    }

    function getOffset(clicked_id){
      // the user clicked something if clicked is defined...
      var current_page = getCurrentPage();
      if(clicked_id){
        // check if the user clicked on prev/next buttons
        if((/(next|prev)/).test(clicked_id)){
          return clicked_id.indexOf('next') > 0 ? (current_page) : (current_page - 2);
        }
        // the user clicked on a page number...
        else {
          return + clicked_id.replace(/page-/, '') - 1;
        }
      }
      // the user pressed the back button of the browser
      else {
        return (current_page - 2);
      }
      
    }

    return {
      createTable: createTable,
      createPagination: createPagination,
      render: render
    };
  }

})();