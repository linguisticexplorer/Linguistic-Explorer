(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};
  searches.preview.clustering = {};

  searches.preview.clustering = {
    init: renderClustering
  };

  var containerId = 'similarity_tree';

  function renderClustering(json, templateFn){
    var phylogramBuilder = T.Visualization.Phylogram;
    var getTemplate = templateFn;
    
    // save it in case we want to swap between regular - radial
    var resultsJson = json;


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

    return {
      makeRow   : $.noop,
      makeTable : makeTable,
      finalize  : makeGraph,
      getLings  : $.noop,
      mapStyler : $.noop,
      lingIndex : $.noop
    };
  }

})();

