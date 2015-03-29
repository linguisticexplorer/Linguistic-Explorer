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

  function renderClustering(json){
    phylogramBuilder = T.Visualization.Phylogram;

    var width = $('#'+containerId).width();
    
    // save it in case we want to swap between regular - radial
    resultsJson = json.rows[1];

    var options = {width: width, radial: false};

    phylogramBuilder.init(containerId, resultsJson, options);

    // add a button to swap
  }

})();

