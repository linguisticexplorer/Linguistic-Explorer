(function(){
	// Init the module here
  this.Terraling = this.Terraling || {};

  var mapping = this.Terraling.Map = {};

  var maps = {};
  
  function createMap(id, conf, cb){
    // get the data as first step while doing other stuff
    getData(conf.name || '', id);
    
    // create a Leaflet map in the specific id
    var map = new L.Map(id);

    // read the configuration file for more stuff

    // push the data
    $.when(T.promises.map).then(function(){
      
      map.setView(maps[id].value, 13);

      var cloudmade = L.tileLayer('http://{s}.tile.cloudmade.com/{key}/{styleId}/256/{z}/{x}/{y}.png',{
        attribution: 'Map data &copy; 2011 OpenstreetMap contributors, Imagery &copy; 2011 CloudMade',
        key: 'BC9A493B41014CAABB98F0471D759707',
        styleId: 22677
      }).addTo(map);

    });
  }

  function getData(name, mapId){
    var payload = {
      ling_name: name,
      prop_name: 'latlong'
    };

    T.promises.map = $.get(getURL(), payload)
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

  function getURL(){
    return '/groups/'+T.currentGroup+'/lings_properties/exists';
  }

  mapping.init = createMap;

})();