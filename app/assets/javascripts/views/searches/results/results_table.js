(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.show = searches.preview || {};

  searches.preview.table = {init: initTable};

  var currentPage;
  var paginationSetup;

  var getType, initPageForType;

  function initTable(typeChecker, typeInitFn){
    getType = typeChecker;
    initPageForType = typeInitFn;

    return {
      getData: createTable,
      createPagination: createPagination,
      bindPagination: bindPagination
    };
  }

  function createPagination(json, offset, max_rows){

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
        next = {disabled: (!json.rows[page_offset*max_rows_per_page]) };

    var pages_total = Math.ceil(json.rows.length / max_rows_per_page),
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

  function createTable(json, offset, max_rows){
    var max_rows_per_page = max_rows || 25;
    // this will clean the type of the search from all the implications subtypes
    json.type = getType(json.type);
    // init the page for the specific type in case
    initPageForType(json);
    // create the header
    var table = headerMapping(json.type, json);

    offset = offset || 0;
    
    for(var i=offset * max_rows_per_page; i<json.rows.length && i< max_rows_per_page * (offset + 1); i++){
      table.rows.push(columnMapping(json.type, getHeader(json.type, table), json.rows[i], i));
    }

    return refineTable(json.type, table);
  }

  function getType(type){
    return (/implication/).test(type) ? 'implication' : type;
  }

  function initPageForType(json){
    if(searches.preview[json.type].init){
      searches.preview[json.type].init(json);
    }
  }

  function refineTable(type, table){
    if(type === 'compare'){
      // redefine rows property:
      var oldRows = table.rows;
      table.rows = {commons: [], differents: []};
      
      $(oldRows).each(function(index, row){
        // pick common rows and put them in a commons property
        // pick diff rows and put them in a diff property  
        table.rows[(row.common ? 'commons' : 'differents')].push(row);
      });
      table.commons    = !!table.rows.commons.length;
      table.differents = !!table.rows.differents.length;
      
    }
    return table;
  }

  function getHeader(type, table){
    switch (type){
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

  function headerMapping(type, json){
    function mapCrossHeaders(headers, row){
      var result = {headers: [], header: {count: headers['count']}, rows: []};
      for( var i =0; i<row.length; i++){
        var header = {};
        for( var h in headers){
          if(headers.hasOwnProperty(h) && h !== 'count'){
            header[h] = headers[h];
          }
        }
        result.headers.push(header);
      }
      return result;
    }

    function mapCompareHeaders(headers, lings){
      function mapLingName(el){
        return el.ling.name;
      }

      return {header: headers, rows: [], lings: $.map(lings, mapLingName).join(', ') };
    }

    function mapRegularHeader(header){
      return {header: header, rows: []};
    }

    switch (type){
      case 'default':
        return mapRegularHeader(json.header);
      case 'cross':
      case 'implication':
        return mapCrossHeaders(json.header, json.rows[0].parent);
      case 'compare':
        return mapCompareHeaders(json.header, json.rows[0].lings);
      default:
        // Fail silently....
        return {};
    }
  }

  function columnMapping(type, columns, entry, index){
    switch (type){
      case 'default':
        return searches.preview.default.render(columns, entry);
      case 'cross':
      case 'implication':
        return searches.preview.cross.render(columns, entry, index);
      case 'compare':
        return searches.preview.compare.render(columns, entry);
      default:
        // Fail silently....
        return {};
    }
  }

    // PAGINATION CODE
  function bindPagination(){

    if(!paginationSetup){


      // Text and image while loading
      // TODO: Make this check somehow to see if a .js.erb file exists
      // Alterntaively, create one for every view, but not recommended
      
      var img = "<img src='/images/loader.gif' class='loading'/>",
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

})();