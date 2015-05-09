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

    // push the data
    $.when(T.promises.map.data).then(function(){
      
      // create a Leaflet map in the specific id
      var map = new L.Map(id, {minZoom: 1, zoomControl: false, zoom: 2, center: [0,0]});

        // create the tile layer with correct attribution
      var layer = L.tileLayer('http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',{
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://cartodb.com/attributions">CartoDB</a>'
      });
      layer.once('load', fitWorld(map));

      map.addLayer(layer);
      
      map.addControl(createZoomControl());

      // add the marker
      createMarkers(id, conf.markerStyler, map);

      createLegend(id, map);

      maps[id] = map;

      if($.isFunction(cb)){
        cb();
      }

    });
  }

  function fitWorld(map){
    return function(){
      map.fitWorld();
    };
  }

  function destroy(id){
    if(maps[id]){
      maps[id].remove();
      maps[id] = null;
    }
  }

  function createLegend(id, map){
    var div;

    function update(){
      $(div).html('<h4>Note:</h4><p>'+maps[id].markersHidden.length+' languages are not currently shown</p>');
    }

    if(maps[id].markersHidden.length){
      var legend = L.control();

      legend.onAdd = function(map){
        div = L.DomUtil.create('div', 'map-legend');
        update();
        return div;
      };

      legend.update = update;
      legend.addTo(map);
    }
  }

  function createMarkers(id, styler, map){
    maps[id].markersHidden = [];

    $.each(maps[id].values, function (i, entry){
      if(entry.value){
        createMarker(entry, styler, map, id);
      }
    });
  }

  function createMarker(entry, styler, map, id){
    // start with a default style
    var style = {
      markerColor: 'blue',
      icon: 'info',
      iconColor: 'white',
      spin: false
    };
    // overwrite style if a styler is passed
    if(styler){
      style = styler(entry);
    }
    // style can be null if we run out of colours
    if(style){
      // append the prefix: 
      // later because the style can have been overrided by the styler
      style.prefix = 'fa';
      // Creates a red marker with the info icon
      var marker = L.AwesomeMarkers.icon(style);
      // In the value property are stored the coords of the marker
      marker = L.marker(entry.value, {icon: marker}).addTo(map);
      if(style.text){
        marker.bindPopup(style.text);
      }
    } else {
      // show in some place that there are missing markers
      maps[id].markersHidden.push(entry.id);
    }
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

  function createZoomControl(){

    var customZoom = L.Control.extend({
      options: {
        position: 'topleft'
      },

      onAdd: function (map) {
        var zoomName = 'leaflet-control-zoom',
            container = L.DomUtil.create('div', zoomName + ' leaflet-bar');

        var zoomInButton  = createButton('+', 'Zoom In' , zoomName + '-in',  container, zoomIn(map));
        var zoomFitbutton = createButton('<i class="fa fa-home"></>', 'Zoom to Fit', zoomName + '-fit', container, zoomToFit(map));
        var zoomOutButton = createButton('-', 'Zoom Out', zoomName + '-out', container, zoomOut(map));

        return container;
      },

      onRemove: function (map) {
        
      }
    });

    return new customZoom();

    function createButton(html, title, className, container, fn) {
      var link = L.DomUtil.create('a', className, container);
      link.innerHTML = html;
      link.href = '#';
      link.title = title;

      L.DomEvent
          .on(link, 'mousedown dblclick', L.DomEvent.stopPropagation)
          .on(link, 'click', L.DomEvent.stop)
          .on(link, 'click', fn, this);

      return link;
    }

    function zoomIn(map){
      return function(){
        map.zoomIn();
      };
    }

    function zoomOut(map){
      return function(){
        map.zoomOut();
      };
    }

    function zoomToFit(map){

      function fitToPoints(){
        var bounds = [];
        map.eachLayer(function (layer){
          // filter items with latlong properties
          if(layer._latlng){
            bounds.push(layer._latlng);
          }
        });
        if(bounds.length > 1){
          map.fitBounds(bounds);
        } else {
          map.setZoomAround(bounds[0], 8);
        }
      }
      return fitToPoints;
    }
  }

  mapping.init = createMap;
  mapping.remove = destroy;

})();