(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};
  var me  =searches.preview.cross = searches.preview.implication = {
    init: initCross
  };

  var setupModal = false;

  function initCross(json){
    var modal;
    var resultsJson;
    var lingsCache;

    resultsJson = json;

    if(!setupModal){
      bindLingsModal();
      setupModal = true;
    }

    function bindLingsModal(){
      // dynamically bind count links to show a modal with the lings
      $(document).on('click', '[id^="lings_cross_"]', showLingsModal);

      function showLingsModal(){

        var index = + this.id.replace('lings_cross_', '');

        // find the right entry
        var entry = resultsJson.rows[index].child || [];

        var lings = $.map(entry, function (el){
            return el.lings_property.ling;
        });

        // add s if more than one result
        var suffix = lings.length == 1 ? "" : "s";

        // load the modal
        if(!modal){
          modal = HoganTemplates[T.controller.toLowerCase() + '/results/cross_modal'];
          $('body').append(modal.render({name: T.groups[T.currentGroup].ling0_name + suffix}));
        }

        var table = [];
        var lingsPerRow = 1;
        var row = [];

        // set the number of columns responsively
        if (lings.length % 5 == 0) {
          lingsPerRow = 5;
        } else if (lings.length % 4 == 0) {
          lingsPerRow = 4;
        } else if (lings.length % 3 == 0) {
          lingsPerRow = 3;
        } else if (lings.length % 2 == 0) {
          lingsPerRow = 2;
        }
        
        // worst case, just accept the hanging row
        if (lings.length > 25 && lingsPerRow == 1) {
          lingsPerRow = 4;
        }

        for( var i=0; i<lings.length; i++){

          if(i && i%lingsPerRow === 0){
            table.push(row);
            row = [];
          }
          row.push(prepareForRow(lings[i]));
        }
        table.push(row);

        var template = HoganTemplates[T.controller.toLowerCase() + '/results/cross_row_results'];
        var html = template.render({rows: table});

        $('#lings_cross').html(html);
        $('#cross_lings_modal').modal('show');

      }
    }

    function mapCrossHeaders(){
      var headers = resultsJson.header;
      var result = {headers: [], header: {count: headers.count }, rows: []};

      if (resultsJson.rows[0]) {
        var row = resultsJson.rows[0].parent;
        for( var i =0; i<row.length; i++){
          var header = {};
          for( var h in headers){
            if(headers.hasOwnProperty(h) && h !== 'count'){
              header[h] = headers[h];
            }
          }
          result.headers.push(header);
        }
      } else {
        result["headers"] = headers;
      }
      return result;
    }

    function prepareForRow(entry){
      return {name: entry.name, link: getLingURL(entry)};
    }

    function getLingURL(ling){
      return '/groups/'+T.currentGroup+'/lings/'+ling.id;
    }

    function crossMapping(table, entry, index){
      var func_dict = {
        'count'            : getCrossLings,
        'cross_property'   : getProperty('parent'),
        'cross_property_id': getPropertyId('parent'),
        'cross_value'      : getValue('parent'),
        'row_id'           : getValueId('parent')
      };

      function getCrossLings(entry){
        return {text: T.Util.isThere(entry, 'child', 'length') ?  entry.child.length : '0', index: index};
      }

      function getProperty(level){
        return function (entry, i){
          return T.Util.isThere(entry, level, i, 'lings_property', 'property') ? entry[level][i].lings_property.property.name : ' ';
        };
      }

      function getPropertyId(level){
        return function (entry, i){
          return T.Util.isThere(entry, level, i, 'lings_property', 'property', 'id') ? entry[level][i].lings_property.property.id : ' ';
        };
      }

      function getValue(level){
        return function (entry, i){
          return T.Util.isThere(entry, level, i, 'lings_property') ? entry[level][i].lings_property.value : ' ';
        };
      }

      function getValueId(level){
        return function (entry, i){
          return T.Util.isThere(entry, level, i, 'lings_property') ? entry[level][i].lings_property.id : 'NA';
        };
      }

      // columns is an array here!
      var pair_columns = table.headers;
      var property_value = [];
      var new_entry = {pair: [], pair_id: null, property_value: null, count: func_dict.count(entry)};
      for( var pc=0; pc< pair_columns.length; pc++ ){
        var pair_entry = {};
        var pairId = [];
        for(var c in pair_columns[pc]){
          if(pair_columns[pc].hasOwnProperty(c)){
            pair_entry[c] = func_dict[c](entry, pc);
            pairId.push(func_dict.row_id(entry, pc));
          }
        }
        new_entry.pair.push(pair_entry);
        new_entry.pair_id = pairId.join('-');
        property_value.push(func_dict.cross_property_id(entry, pc)+":"+func_dict.cross_value(entry, pc));
      }
      new_entry.property_value = property_value.join('_');

      return new_entry;
    }

    function getLingIds(){
      // for each row collect the languages involved
      // use a dictionary to skip duplicates
      var lings = {};
      var ids   = [];

      if(!lingsCache){

        lingsCache = {};

        // This double loop can go very bad with many rows
        $.each(resultsJson.rows, function (index, row){
          if(row.child && row.child.length){
            $.each(row.child, function (i, child){
              var ling = child.lings_property.ling;
              if(!lings[ling.id]){
                lings[ling.id] = 1;
                ids.push(ling.id);
              }
              if(!lingsCache[ling.id]){
                lingsCache[ling.id] = {name: ling.name, count: 1};
              } else {
                lingsCache[ling.id].count++;
              }
            });
          }
        });
      } else {
        for( var id in lingsCache){
          ids.push(id);
        }
      }

      // sort by number of ling occurencies (the most frequent are shown by default)
      ids.sort(function (id1, id2){
        return lingsCache[id2].count - lingsCache[id1].count;
      });

      return ids;
    }

    function getStyler(){
      // how may lings are in the results?
      var colors = ['red', 'blue', 'green', 'purple', 'orange', 'darkred', 'lightred', 'beige', 'darkblue', 'darkgreen',
                    'cadetblue', 'darkpurple', 'white', 'pink', 'lightblue', 'lightgreen', 'gray', 'black', 'lightgray'];
      var counter=0;

      var popups = preparePopup(resultsJson);

      var colors_by_row = {};

      // associates a color with each id based on row
      // if no color yet associated w/ a row, assign one
      // works up to 20 colors.  Then we run out (TODO: fix) 
      function getColorById(id){
        if(!colors_by_row[rows_by_ling[id]]){
          if(counter < 20){
            colors_by_row[rows_by_ling[id]] = colors[counter++];
          }
        }
        return colors_by_row[rows_by_ling[id]];
      }

      function styler(entry) {
        var entry_color = getColorById(entry.id);
        if (entry_color == null) {
          return null
        }
        return {
          markerColor: entry_color,
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
      for( var id in lingsCache){
        var entry = lingsCache[id];
        popups[id] = template.render({name: entry.name, row1: 'Found in '+entry.count+' rows'});
      }
      return popups;
    }

    return {
      makeRow   : crossMapping,
      makeTable : mapCrossHeaders,
      finalize  : $.noop,
      getLings  : getLingIds,
      mapStyler : getStyler,
      lingIndex : $.noop
    };
  }

})();
