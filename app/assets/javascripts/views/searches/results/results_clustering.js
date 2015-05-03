(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};
  searches.preview.clustering = {};

  searches.preview.clustering.init = renderClustering;

  var resultsJson;
  var containerId = 'similarity_tree';
  var phylogramBuilder;
  var getTemplate;

  var cachedRender;

  function renderClustering(json, templateFn){
    if(!cachedRender){
      phylogramBuilder = T.Visualization.Phylogram;
      getTemplate = templateFn;
      
      // save it in case we want to swap between regular - radial
      resultsJson = json;

      cachedRender = {
        makeRow   : $.noop,
        makeTable : makeTable,
        finalize  : makeGraph,
        getLings  : $.noop,
        mapStyler : $.noop,
        lingIndex : $.noop
      };
    }
    return cachedRender;
  }

  function makeTable(){
    return {header: ['clustering'], rows: []};
  }

  function makeGraph(table){
    var template = HoganTemplates[getTemplate(resultsJson.type)];
    // render the element now
    $('#paginated-results').html(template.render({}));
    // now make the chart
    options = $.extend({}, {width: $('#'+containerId).width(), height: 600, radial: false});

    phylogramBuilder.init(containerId, resultsJson.rows[1], options);

    // add a button to swap to radial mode
  }

})();

