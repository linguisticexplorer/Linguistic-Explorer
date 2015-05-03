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

  var cachedRender;

  function renderClustering(json){
    if(!cachedRender){
      phylogramBuilder = T.Visualization.Phylogram;
      
      // save it in case we want to swap between regular - radial
      resultsJson = json.rows[1];

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
    return {header: [], rows: []};
  }

  function makeGraph(options){
    options = $.extend(options, {width: $('#'+containerId).width(), radial: false});

    phylogramBuilder.init(containerId, resultsJson, options);

    // add a button to swap to radial mode
  }

})();

