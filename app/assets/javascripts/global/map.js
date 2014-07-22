(function(){
	// Init the module here
  this.Terraling = this.Terraling || {};

  var mapping = this.Terraling.Map = {};

  var maps = {};
  
  function createMap(id, conf, cb){
    // here we store all the promises
    T.promises.map = {};

    // get the data as first step while doing other stuff
    T.promises.map.data = getData(conf.name || '', id);
    
    // create a Leaflet map in the specific id
    var map = new L.Map(id, {minZoom: 1});

    // read the configuration file for more stuff

    // push the data
    $.when(T.promises.map.data).then(function(){
      
      map.setView([0,0], 1);
      
      // add the layer with the map
      var googleMaps = new L.Google();
      map.addLayer(googleMaps);

      // add the marker
      // Creates a red marker with the coffee icon
      var redMarker = L.AwesomeMarkers.icon({
        prefix: 'fa',
        icon: 'users',
        markerColor: 'red'
      });

      L.marker(maps[id].value, {icon: redMarker}).addTo(map);

    });
  }

  function getData(ids, mapId){
    
    var request = getURL(ids);

    return $[request.method](request.url, request.payload)
      .done(parseData(mapId))
      .fail(showError(mapId))
      .always();
  }

  function parseData(id){
    
    return function (json){
      
      if(json.exists){

        maps[id] = json;
        // overwrite the value field with an appropriate array
        maps[id].value = maps[id].value.split(',');
      }
    };

  }

  function showError(){

  }

  function getURL(ids){
    var url;
    var method = 'get';
    var payload = {};


    if($.isArray(ids)){
      url = '/groups/'+T.currentGroup+'/searches/geomapping';
      payload.ids = ids;
      method = 'post';
    } else {
      url = '/groups/'+T.currentGroup+'/lings_properties/exists';
      payload.ling_name = ids;
      payload.prop_name = 'latlong';
    }

    return {url: url, payload: payload, method: method};
  }

  mapping.init = createMap;

})();