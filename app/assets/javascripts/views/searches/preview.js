(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.show = searches.preview || {};

  searches.preview.init = getResults;

  // cover the search comparisons as well
  // The SearchComparison controller has a slightly different shape
  this.Terraling.SearchComparisons = {};
  this.Terraling.SearchComparisons.create = {init: getResultsForComparison};

  var templateMapping = {
    'cross': 'cross_results',
    'compare': 'compare_results',
    'implication': 'cross_results',
    'default': 'regular_results',
    'clustering': 'clustering_results',
    'pagination': 'pagination_bar',
    'map': 'map_results'
  };

  var templateCompiled = {
    pagination: null,
    table: null,
    map: null,
    visualization: null
  };

  function getTemplatePath(type){
    // should find a better solution
    return (embed ? embedController : T.controller.toLowerCase()) + '/results/' + templateMapping[type];
  }

  var loadingInterval,
      query,
      resultsJson;

  var tableBuilder, mapper;

  var embed = false;
  var navbarOn = true;
  var embedController = 'searches';

  function getResultsForComparison(){
    getResults(true);
  }

  function getResults(toEmbed, hideNavbar){

    embed = !!toEmbed;
    navbarOn = !hideNavbar;


    function tuneParamsForSearchType(){
      var query = $('#search_results').data('query');
      // if it's an advanced search just double the time to wait
      if(query.advanced_set){
        timeoutMillis *= 2;
      }
    }

    var timeoutMillis = 50000,
        waitThreshold = 70,
        refreshRate   = 100;

    query = {
      authenticity_token: $('meta[name=csrf-token]').attr('content'),
      search: $('#search_results').data('query'),
      id: $('#search_results').data('search-id')
    };
  
    $.post(getResultsURL(), query)
    .success(compileResults)
    .error(notifyError);

    tuneParamsForSearchType();
    
    var progress = 0,
        step = waitThreshold / (timeoutMillis / refreshRate);

    function notifyError(err){
      setBar(progress);

      if(progress > waitThreshold || err){
        clearInterval(loadingInterval);
        if(err){
          setBar(100, "An Error occurred on the server");
        } else {
          // show something
          $('#results_loading_text').text( "The search it's taking longer than expected...");
        }
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

  function toggleNavbarButton(ids, isEnable, fn){
    // get li parents
    var elements     = $(ids);
    var parents = elements.parent();

    elements.attr('disabled', !isEnable);
    parents.toggleClass('disabled', !isEnable);
    
    if($.isFunction(fn)){
      elements.on('click', function (e){
        if(!parents.hasClass('active')){
          $('#results-navbar-collapse ul > li').removeClass('active');
          parents.toggleClass('active');
          fn(e);
        }
      });
    }
  }

  function enableNavbar(type){
    var navbar = $('#results_navbar');

    // Download  => Clustering
    // Save      => Default
    // Visualize => All but Default
    // Map       => All but Clustering
    var isClustering = (/clustering/).test(type),
        isDefault    = (/default/).test(type);
    
    toggleNavbarButton('#table'     , true         , showTable);
    toggleNavbarButton('#saveit'    , isDefault    , saveFn);
    toggleNavbarButton('#vizit'     , !isDefault   , vizFn);
    toggleNavbarButton('#downloadit', isClustering , downloadFn);
    toggleNavbarButton('#mapit'     , !isClustering, mapFn);

    if(navbar.is(':hidden')){
      navbar.fadeIn('slow', function(){
        searches.preview.initSave(resultsJson);
      });
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
      
      initAssociatedControllers();
      makeNewPage(resultsJson, 0, true);
      
    }

    
  }

  function initAssociatedControllers(){
    // Map Controller
    mapper = searches.preview.map.init(getType, getTemplatePath);
    tableBuilder = searches.preview.table.init(getType, initPageForType);
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

      table = tableBuilder.getData(json, offset);
      paginationData = tableBuilder.createPagination(json, offset);

    }

    if(bar){
      setBar(80, 'Data processed');
    }
    
    // we need the template in case of clustering anyway...
    // template = Handlebars.compile($(template_id).html());

    if(!isClustering){
      
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
      // cache it for later reuse
      templateCompiled.table = htmlRows;
      templateCompiled.pagination = htmlPagination;

      $('#paginated-results').html(htmlRows);

      if(isClustering){

        // draw philogram
        initPageForType(json);

      } else {

        $(".js-pagination").html(htmlPagination);

        tableBuilder.bindPagination();

      }
      
      if(navbarOn){
        enableNavbar(json.type);
      }
      
    }, 700);
  }

  function getType(type){
    return (/implication/).test(type) ? 'implication' : type;
  }

  function initPageForType(json){
    if(searches.preview[json.type].init){
      searches.preview[json.type].init(json);
    }
  }

  function vizFn(e){
    e.preventDefault();
  }

  function downloadFn(e){
    e.preventDefault();
  }

  function saveFn(e) {
    e.preventDefault();
  }

  function mapFn(e){
    e.preventDefault();
    mapper.create(resultsJson);
  }

  function showTable(){
    $(".js-pagination").html('');
    $('#paginated-results').html('');
    makeNewPage(resultsJson, 0, true);
  }

})();