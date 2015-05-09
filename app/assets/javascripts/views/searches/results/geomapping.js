(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.show = searches.preview || {};

  searches.preview.map = {
    init: initMap
  };

  var getTemplatePath, getType;
  var resultsJson;
  var slicedJson;

  function initMap(data, templateFn){
    resultsJson = JSON.parse(JSON.stringify(data));

    getTemplatePath = templateFn;

    return {
      create: createMap,
      destroy: destroy
    };
  }

  function createMap(){
    // iterate throught the rows and find all the lings
    var isRegular = resultsJson.type === 'default';

    // change the page template with the map one
    var mapTemplate = HoganTemplates[getTemplatePath('map')];

    // TODO: finish the panel!
    // var htmlMap = mapTemplate.render({width: isRegular ? 12 : 10, panel: !isRegular});
    var htmlMap = mapTemplate.render({width: 12, panel: false});
    $(".js-pagination").html('');
    $('#paginated-results').html(htmlMap);

    var resultsRenderer = searches.preview[resultsJson.type].init(resultsJson);

    // now ask the server for all the coords for the given lings
    var options = {
      name: resultsRenderer.getLings(),
      markerStyler: resultsRenderer.mapStyler()
    };
    T.Visualization.Map.init('mapResults', options, function(){
      // here the map is done, do some more stuff
      loadPanel(!isRegular);
    });

  }

  function destroy(){
    T.Visualization.Map.remove('mapResults');
  }

  function loadPanel(isActive){
    if(isActive){
      indexData(function(){
        // index prepared here
      });
    }
  }

  function progressUpdater(progress){
    var percent = Math.log(progress + 1) * 100;
    $('#indexProgress').width(percent+'%');
  }

  function indexData(fn){

    slicedJson = T.Util.makeChunks(resultsJson.rows, 200);

    // now index the data based on the type
    if(searches.preview[resultsJson.type].indexer){
      searches.preview[resultsJson.type].indexer(slicedJson, progressUpdater, fn);
    }
  }

})();