(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};

  searches.preview.init = getResults;

  var templateMapping = {
    'cross': 'cross_results',
    'compare': 'compare_results',
    'implication': 'cross_results',
    'default': 'regular_results',
    'clustering': 'clustering_results',
    'pagination': 'pagination_bar'
  };

  function getTemplatePath(type){
    return T.controller.toLowerCase() + '/results/' + templateMapping[type];
  }

  var loadingInterval,
      query,
      resultsJson;

  var currentPage;
  var paginationSetup;

  function getResults(){

    var timeoutMillis = 50000,
        refreshRate   = 100;

    query = {
      authenticity_token: $('meta[name=csrf-token]').attr('content'),
      search: $('#results_loading_text').data('query')
    };
  
    $.post(getResultsURL(), query)
    .success(compileResults)
    .error(notifyError);
    
    var progress = 0,
        step = 50 / (timeoutMillis / refreshRate);

    function notifyError(err){
      if(err){
        progress = 100;
      }

      setBar(progress);

      if(progress > 50){
        clearInterval(loadingInterval);
        // show an error
        $('#results_loading_text').text('An error occurred');
      }
    }

    loadingInterval = setInterval(function(){
      progress += step;
      notifyError();
    }, refreshRate);

  }

  function setBar(value, msg){
    $('#results_loading_bar').width(value+'%');
    if(msg){
      $('#results_loading_text').text(msg);
    }
  }

  function getResultsURL(params){
    return '/groups/'+T.currentGroup+'/searches/get_results';
  }

  function enableNavbar(type){
    var navbar = $('#results_navbar');
    
    // show download button only for clustering
    if(!(/clustering/).test(type)){
      $('#downloadit').hide();
    } else {
      $('#saveit, #mapit, #vizit').hide();
    }
    
    // hide save button for non-regular searches
    if(!(/default/).test(type)){
      $('#saveit').hide();
    } else {
      $('#vizit').hide();
    }

    if(navbar.is(':hidden')){
      navbar.fadeIn('slow', searches.preview.initSave);
    }
  }

  function compileResults(json){

    resultsJson = json;

    clearInterval(loadingInterval);

    if(!json.success){

      setBar(100, '');

      $('#error_message').
        prepend($('p').text(json.errors)).
        show('slow');

    } else {
      
      makeNewPage(resultsJson, 0, true);
      
    }

    
  }

  function makeNewPage(json, offset, bar){
    // Data variables
    var table, template, htmlRows;
    // Pagination variables
    var paginationData, paginationTemplate, htmlPagination;

    if(bar){
      setBar(50, 'Data received');
    }
    // var template_id = 'default';

    var isClustering = (/clustering/).test(json.type);

    for( var type in templateMapping){
      if( (new RegExp(type)).test(json.type) ){
        template = HoganTemplates[getTemplatePath(type)];
        break;
      }
    }

    if(!isClustering){

      table = createTable(json, offset);
      paginationData = createPagination(json, offset);

    }

    if(bar){
      setBar(80, 'Data processed');
    }
    
    // we need the template in case of clustering anyway...
    // template = Handlebars.compile($(template_id).html());

    if(!isClustering){
      
      // paginationTemplate = Handlebars.compile($('#pagination_bar').html());
      paginationTemplate = HoganTemplates[getTemplatePath('pagination')];

    }
    
    if(bar){
      setBar(100, 'Preparing the results');
    }

    htmlRows = template.render(table || {});

    if(!isClustering){
      htmlPagination = paginationTemplate.render(paginationData);
    }
    

    setTimeout(function(){

      $('#pagination_table').html(htmlRows);

      if(isClustering){

        // draw philogram
        drawPhilogram(json.rows[1]);

      } else {

        $(".js-pagination").html(htmlPagination);

        bindPagination();

      }

      enableNavbar(json.type);
      
    }, 700);
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
    initPageForType(json.type);
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

  function initPageForType(type){
    var fn_name = 'init'+type[0].toUpperCase()+type.substring(1);
    
    if(searches.preview[fn_name]){
      searches.preview[fn_name](resultsJson);
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
        return searches.preview.renderDefault(columns, entry);
      case 'cross':
      case 'implication':
        return searches.preview.renderCross(columns, entry, index);
      case 'compare':
        return searches.preview.renderCompare(columns, entry);
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
       $(document).on("click", ".apple_pagination.js-pagination a", function (e) {

          var offset = getOffset(e.target.id);
          var current = getCurrentPage();

          $(".js-pagination").html(img);
          makeNewPage(resultsJson, offset);
          
          
          history.pushState(current, document.title + '- Page '+current, '#');
          e.preventDefault();
      });
      
      $(window).bind("popstate", function (e) {
        // console.log(e.originalEvent.state);
        // if (e.originalEvent.state) {
        //   var offset = e.originalEvent.state;
        //   $(".js-pagination").html(img);
        //   makeNewPage(resultsJson, offset);
        // }
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