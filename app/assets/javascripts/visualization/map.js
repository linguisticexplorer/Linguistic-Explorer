(function(){
	// Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Visualization = this.Terraling.Visualization || {};

  var mapping = this.Terraling.Visualization.Map = {};

  var maps = {};
  
  function createMap(id, conf, cb){
    // here we store all the promises
    T.promises.map = {};

    // get the data as first step while doing other stuff
    T.promises.map.data = getData(conf.name || '', id, conf.type);
    
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
      createMarkers(id, map);

    });
  }

  function createMarkers(id, map){
    $.each(maps[id].values, function (i, entry){
      if(entry.value){
        createMarker(entry.value, map);
      }

    });
  }

  function createMarker(value, map){
    // Creates a red marker with the coffee icon
    var redMarker = L.AwesomeMarkers.icon({
      prefix: 'fa',
      icon: 'language',
      markerColor: 'red'
    });

    L.marker(value, {icon: redMarker}).addTo(map);
  }

  function getData(ids, mapId, type){
    
    var request = getURL(ids, type);

    return $[request.method](request.url, request.payload)
      .done(parseData(mapId))
      .fail(showError(mapId))
      .always();
  }

  function parseData(id){
    
    return function (json){
      
      if(json.exists){
        maps[id] = {};
        // overwrite the value field with an appropriate array
        maps[id].values = [{id: json.id, value: json.value.split(',')}];
      }

      if(json.type === 'coords'){
        maps[id] = {};

        maps[id].values = $.map(json.values, function (val, id){
          return {id: id, value: val };
        });
      }
    };

  }

  function showError(){

  }

  function getURL(ids, type){
    var url;
    var method = 'get';
    var payload = {};

    // Regular search results
    if($.isArray(ids)){
      url = '/groups/'+T.currentGroup+'/maps';
      payload.ling_ids = ids;
      method = 'post';
    } else if(type === 'ling'){
      // show page on a language
      url = '/groups/'+T.currentGroup+'/lings_properties/exists';
      payload.ling_name = ids;
      payload.prop_name = 'latlong';
    } else if(type === 'property'){
      // show page on a property
      url = '/groups/'+T.currentGroup+'/maps';
      payload.prop_ids = ids;
      method = 'post';
    }

    payload.authenticity_token = $('meta[name=csrf-token]').attr('content');

    return {url: url, payload: payload, method: method};
  }

  mapping.init = createMap;

})();