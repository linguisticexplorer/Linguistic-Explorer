(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;

  var me = searches.preview = searches.show = searches.preview || {};

  me.init = getResults;

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

  var tableBuilder, mapper, saver;

  var embed = false;
  var navbarOn = true;
  var embedController = 'searches';

  function getResultsForComparison(){
    getResults(true);
  }

  function getResults(toEmbed, hideNavbar){

    embed = !!toEmbed;
    navbarOn = !hideNavbar;

    $('#waiting').html(HoganTemplates['waiting'].render({medium: true, color: '#5bc0de'}));

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
      result_groups: $('#search_results').data('resultGroups'),
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
        e.preventDefault();
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

    // Download  => Clustering || New Browsers
    // Save      => Default
    // Visualize => All but Default
    // Map       => All but Clustering
    var isClustering = type === 'clustering',
        isDefault    = type === 'default';

    var canDownload = isClustering || T.Util.isFileSaverSupported();

    toggleNavbarButton('#table'     , !isClustering , showTable);
    toggleNavbarButton('#saveit'    , isDefault     , saver.showModal);
    toggleNavbarButton('#vizit'     , isClustering  , vizFn); // Later it will be !isDefault
    toggleNavbarButton('#downloadit', canDownload   , saver.download);
    toggleNavbarButton('#mapit'     , !isClustering , mapFn);

    if(navbar.is(':hidden')){
      if(isClustering){
        $('#table, #vizit').parent().toggleClass('active');
      }
      navbar.fadeIn('slow');
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

      // Save the type of the result (unify all the implication types)
      resultsJson.type = setType(resultsJson.type);
      // Setup all the associated controllers (Maps, Table, Viz, etc...)
      initAssociatedControllers();

      makeNewPage(resultsJson, 0, true);

    }


  }

  function initAssociatedControllers(){
    // Map Controller
    mapper       = me.map.init(resultsJson, getTemplatePath);
    tableBuilder = me.table.init(resultsJson, getTemplatePath, makeNewPage);
    saver        = me.save.init(resultsJson, getTemplatePath);
  }

  function makeNewPage(json, offset, bar){
    // Data variables
    var table, template, htmlRows;
    // Pagination variables
    var paginationData, htmlPagination;

    if(bar){
      setBar(50, 'Data received');
    }

    for( var type in templateMapping){
      if( (new RegExp(type)).test(json.type) ){
        template = HoganTemplates[getTemplatePath(type)];
        break;
      }
    }

    var rows_per_page = json["rows_per_page"] || 25;
    table = tableBuilder.createTable(offset, rows_per_page);
    paginationData = tableBuilder.createPagination(offset, rows_per_page);


    if(bar){
      setBar(80, 'Data processed');
    }

    htmlRows = template.render(table || {});

    if(paginationData.pages.length > 1){

      var paginationTemplate = HoganTemplates[getTemplatePath('pagination')];
      htmlPagination = paginationTemplate.render(paginationData);
    } else {
      htmlPagination = '';
    }

    if(bar){
      setBar(100, 'Preparing the results');
    }

    setTimeout(function(){

      // cache it for later reuse
      templateCompiled.table = htmlRows;
      templateCompiled.pagination = htmlPagination;

      tableBuilder.render(templateCompiled, '#paginated-results', ".js-pagination");

      if(navbarOn){
        enableNavbar(json.type);
      }

    }, 500);
  }

  function setType(type){
    return (/implication/).test(type) ? 'implication' : type;
  }

  function vizFn(e){
  }

  function mapFn(e){
    cleanPage();
    mapper.create();
  }

  function showTable(e){
    cleanPage();
    makeNewPage(resultsJson, 0, true);
  }

  function cleanPage(){
    mapper.destroy();
    $(".js-pagination").empty();
    $('#paginated-results').empty().html('<p class="strong" style="text-align: center;">Loading...</p>');
  }

})();