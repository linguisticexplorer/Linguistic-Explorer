(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};
  searches.preview.compare = {};

  searches.preview.compare = {
    init: create
  };

  function create(json){
    var resultsJson = json;

    function compareHeaders(){
      function mapLingName(el){
        return el.ling.name;
      }
      var headers = resultsJson.header;
      var lings = resultsJson.rows[0].lings;
      return {header: headers, rows: [], lings: $.map(lings, mapLingName).join(', ') };
    }

    function getProperty(level){
      return function (entry, i){
        return T.Util.isThere(entry, level, i, 'lings_property', 'property') ? entry[level][i].lings_property.property.name : ' ';
      };
    }

    function getValue(level){
      return function (entry, i){
        return T.Util.isThere(entry, level, i, 'lings_property') ? entry[level][i].lings_property.value : ' ';
      };
    }

    function isCommon(entry){
      return entry.child.length === 1;
    }

    function compareMapping(columns, entry){
      var func_dict = {
        // This is a common key
        'compare_property' : getProperty('parent'),
        // This is a common-only key-value
        'common_values'    : getValue('parent'),
        // This is a diff-only key-value
        'ling_value'       : getValue('child')
      };

      var col, ling,
          new_entry = {};

      // if entry is common
      if(isCommon(entry)){

        new_entry.common = true;

        for( col in columns.commons){
          new_entry[col] = func_dict[col](entry, 0);
        }
        
      }
      // entry diff
      else {
        for( col in columns.differents){
          
          if(col === 'ling_value'){
            new_entry[col] = [];
            for( ling = 0; ling<columns.differents[col].length; ling++){
              new_entry[col].push( func_dict[col](entry, ling) );
            }
          } else {
            new_entry[col] = func_dict[col](entry, 0);
          }
        }
      }
      
      return new_entry;
    }

    function refineTable(table){
    // redefine rows property:
      var oldRows = table.rows;
      table.rows = {commons: [], differents: []};
      
      $.each(oldRows, function (index, row){
        // pick common rows and put them in a commons property
        // pick diff rows and put them in a diff property  
        table.rows[(row.common ? 'commons' : 'differents')].push(row);
      });
      table.commons    = !!table.rows.commons.length;
      table.differents = !!table.rows.differents.length;
      return table;
    }

    function getLingIds(){
      // iterate through the rows and get all the lings in it
      return $.map(resultsJson.rows[0].lings, function (el){
        return el.ling.id;
      });
    }

    function getStyler(){
      // how may lings are in the results?
      var colors = ['red', 'blue', 'green', 'purple', 'orange', 'darkred', 'lightred', 'beige', 'darkblue', 'darkgreen',
                    'cadetblue', 'darkpurple', 'white', 'pink', 'lightblue', 'lightgreen', 'gray', 'black', 'lightgray'];
      var counter=0;

      var popups = preparePopup(resultsJson);

      function styler(entry){
        return {
          markerColor: colors[counter++],
          iconColor: 'white',
          icon: 'info',
          text: popups[entry.id]
        };
      }
      return styler;
    }

    function preparePopup(json){

      var commons = 0;
      $.each(json.rows, function (i, row){
        if(isCommon(row)){
          commons++;
        }
      });

      var lingNames = {};
      $.each(json.rows[0].lings, function (i, el){
        if(!lingNames[el.ling.id]){
          lingNames[el.ling.id] = {name: el.ling.name, row1: "Properties in common: "+commons, row2: "Properties not in common: "+(json.rows.length - commons)};
        }
      });

      // get the template now
      var template = HoganTemplates['searches/results/map_popup'];

      for( var id in lingNames){
        var entry = lingNames[id];
        lingNames[id] = template.render(entry);
      }

      return lingNames;
    }

    function inverseIndexer(slices, updater, callback){

      var index = {};

      function indexer(rows, next){
        // give it a chance to draw
        setTimeout(next, 25);
      }

      async.forEach(slices, indexer, callback);
    }

    return {
      makeRow      : compareMapping,
      makeTable    : compareHeaders,
      finalize     : refineTable,
      getLings     : getLingIds,
      mapStyler    : getStyler,
      lingIndex    : inverseIndexer
    };
  }

})();