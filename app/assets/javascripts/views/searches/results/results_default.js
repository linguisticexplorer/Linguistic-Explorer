(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};
  var me = searches.preview.default = {
    init: create
  };

  function create(json){
    var resultsJson = json;
    var offspringCache = {},
        lingsCache;

    function mapRegularHeader(){
      return {header: resultsJson.header, rows: []};
    }

    function getLingID(level){
      return function (entry){
        return T.Util.isThere(entry, level, 'lings_property', 'id') ? entry[level].lings_property.id : ' ';
      };
    }

    function getLing(level){
      return function (entry){
        return T.Util.isThere(entry, level, 'lings_property', 'ling') ? entry[level].lings_property.ling.name : ' ';
      };
    }

    function getProperty(level){
      return function (entry){
        return T.Util.isThere(entry, level, 'lings_property', 'property') ? entry[level].lings_property.property.name : ' ';
      };
    }

    function getValue(level){
      return function (entry){
        return T.Util.isThere(entry, level, 'lings_property') ? entry[level].lings_property.value : ' ';
      };
    }

    function getExamples(level){
      return function (entry){
        var list = [];
        if(T.Util.isThere(entry, level, 'lings_property', 'examples')){
          var examples = entry[level].lings_property.examples;

          for( var i=0; i < examples.length; i++){
            list.push(examples[i].name);
          }
        }
        return list.join(',') || ' ';
      };
    }

    function includeLingIds(columns){
      if (columns["ling_0"]) {
        columns["ling_0_id"] = "1";
      }
      if (columns["ling_1"]) {
        columns["ling_1_id"] = "1";
      }
    }

    function defaultMapping(columns, entry){
      var func_dict = {
        'ling_0_id' : getLingID('parent'),
        'ling_0'    : getLing('parent'),
        'property_0': getProperty('parent'),
        'value_0'   : getValue('parent'),
        'example_0' : getExamples('parent'),
        'ling_1_id' : getLingID('child'),
        'ling_1'    : getLing('child'),
        'property_1': getProperty('child'),
        'value_1'   : getValue('child'),
        'example_1' : getExamples('child')
      };

      //This is the point that I include ling ids to column result.
      //After that it possible to extract the lings ids for the feature tests
      includeLingIds(columns);

      var new_entry = {};
      for( var c in columns ){
        if(columns.hasOwnProperty(c)){
          new_entry[c] = func_dict[c](entry);
        }
      }
      return new_entry;
    }

    function getLingIds(){
      if(!lingsCache){
        // iterate the parents and children
        var ids = [];
        
        $.each(resultsJson.rows, function (index, row){
          if(row.parent && row.parent.lings_property && !offspringCache[row.parent.lings_property.ling.id]){
            ids.push(row.parent.lings_property.ling.id);
            offspringCache[row.parent.lings_property.ling.id] = {name: row.parent.lings_property.ling.name, count: 1};
          }
          if(row.child && row.child.lings_property){
            ids.push(row.child.lings_property.ling.id);
            if(row.parent && row.parent.lings_property){
              offspringCache[row.parent.lings_property.ling.id].count++;
            }
          }
        });
        lingsCache = ids;
      }
      return lingsCache;
    }

    function getStyler(){
      var popups = preparePopup(resultsJson);

      function styler(entry){
        return {
          markerColor: 'blue',
          iconColor: 'white',
          icon: 'info',
          text: popups[entry.id]
        };
      }
      return styler;
    }

    function preparePopup(json){
      // get the template now
      var template = HoganTemplates['searches/results/map_popup'];
      
      var popups = {};
      for( var id in offspringCache){
        var entry = offspringCache[id];
        popups[id] = template.render({name: entry.name, row1: entry.count > 1 ? 'Has '+entry.count+' '+T.groups[T.currentGroup].ling1_name : ''});
      }
      return popups;
    }

    return  {
      makeRow   : defaultMapping,
      makeTable : mapRegularHeader,
      finalize  : $.noop,
      getLings  : getLingIds,
      mapStyler : getStyler,
      lingIndex : $.noop
    };
  }

})();