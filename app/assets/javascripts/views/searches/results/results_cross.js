(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};
  searches.preview.cross = searches.preview.implication = {};

  searches.preview.cross.render       = crossMapping;
  searches.preview.cross.init         = initCross;
  searches.preview.cross.getMapLings  = getLingIds;
  searches.preview.cross.getMapStyler = getStyler;

  var modal;
  var resultsJson;

  function initCross(json){

    resultsJson = json;

    // dynamically bind count links to show a modal with the lings
    $(document).on('click', '[id^="lings_cross_"]', showLingsModal);

    function showLingsModal(){

      // load the modal
      if(!modal){
        modal = HoganTemplates[T.controller.toLowerCase() + '/results/cross_modal'];
        $('body').append(modal.render({name: T.groups[T.currentGroup].ling0_name }));
      }

      var index = + this.id.replace('lings_cross_', '');
      
      // find the right entry
      var entry = resultsJson.rows[index].child || [];

      var lings = $.map(entry, function (el){
        return el.lings_property.ling;
      });

      var table = [];
      var lingsPerRow = 4;
      var row = [];
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

  function prepareForRow(entry){
    return {name: entry.name, link: getLingURL(entry)};
  }

  function getLingURL(ling){
    return '/groups/'+T.currentGroup+'/lings/'+ling.id;
  }

  function crossMapping(table, entry, index){
    var func_dict = {
      'count'         : getCrossLings,
      'cross_property': getProperty('parent'),
      'cross_value'   : getValue('parent'),
      'row_id'        : getValueId('parent')
    };

    function getCrossLings(entry){
      return {text: T.Util.isThere(entry, 'child', 'length') ?  entry['child'].length : '0', index: index};
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

    function getValueId(level){
      return function (entry, i){
        return T.Util.isThere(entry, level, i, 'lings_property') ? entry[level][i].lings_property.id : 'NA';
      };
    }

    // columns is an array here!
    var pair_columns = table.headers;

    var new_entry = {pair: [], pair_id: null, count: func_dict.count(entry)};
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
    }

    return new_entry;
  }

  function getLingIds(json){
    // iterate through the rows and get all the lings in it
    return $.map(json.rows[0].parent, function (el){
      return el.ling.id;
    });
  }

  function getStyler(json){
    // how may lings are in the results?
    var colors = ['red', 'blue', 'green', 'purple', 'orange', 'darkred', 'lightred', 'beige', 'darkblue', 'darkgreen',
                  'cadetblue', 'darkpurple', 'white', 'pink', 'lightblue', 'lightgreen', 'gray', 'black', 'lightgray'];
    var counter=0;
    function styler(value){
      return {
        markerColor: colors[counter++],
        iconColor: 'white',
        icon: 'info',
        text: value
      };
    }
    return styler;
  }

  function getFilter(value){

  }

})();