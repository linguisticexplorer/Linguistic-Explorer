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

  function initMap(typeFn, templateFn){
    getTemplatePath = templateFn;
    getType = typeFn;
    return {
      create: createMap
    };
  }

  function createMap(json){
    // iterate throught the rows and find all the lings
    var lingIds = getLings(json);
    var isRegular = getType(json.type) === 'default';

    // change the page template with the map one
    var mapTemplate = HoganTemplates[getTemplatePath('map')];
    var htmlMap = mapTemplate.render({width: isRegular ? 12 : 10, panel: !isRegular});
    $(".js-pagination").html('');
    $('#paginated-results').html(htmlMap);

    // now ask the server for all the coords for the given lings
    var options = {
      name: lingIds,
      markerStyler: getStyler(json)
    };
    T.Visualization.Map.init('mapResults', options, function(){
      // here the map is done, clean some stuff
    });

  }

  function getStyler(json){
    var fn = null;
    if(searches.preview[json.type].getMapStyler){
      fn = searches.preview[json.type].getMapStyler(json);
    }
    return fn;
  }

  function getLings(json){
    var ids;
    if(searches.preview[json.type].getMapLings){
      ids = searches.preview[json.type].getMapLings(json);
    }
    return ids || [];
  }

})();