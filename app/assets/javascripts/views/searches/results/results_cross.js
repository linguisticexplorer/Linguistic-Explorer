(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};

  searches.preview.renderCross = crossMapping;

  var modal;
  var resultsJson;

  searches.preview.initCross   = function(json){

    resultsJson = json;

    // dynamically bind count links to show a modal with the lings
    $(document).on('click', '[id^="lings_cross_"]', showLingsModal);

    function showLingsModal(){
      var index = + this.id.replace('lings_cross_', '');
      
      // find the right entry
      var entry = resultsJson.rows[index].child || [];

      // fill a list of lings names
      var lings_names = $.map(entry, function (el){
        return el.lings_property.ling.name;
      });

      // append the list in the modal
      // var source = $('#lings_cross_template').html();
      // var template = Handlebars.compile(source);
      var template = HoganTemplates[T.controller.toLowerCase() + '/results/cross_row_results'];
      var html = template.render({rows: lings_names});

      $('#lings_cross').html(html);

      // show the modal
      if(!modal){
        modal = HoganTemplates[T.controller.toLowerCase() + '/results/cross_modal'];
        $('body').append(modal.render({name: T.groups[T.currentGroup].ling0_name }));
      }
      $('#cross_lings_modal').modal('show');

    }
  };

  function crossMapping(table, entry, index){
    var func_dict = {
      'count'         : getCrossLings,
      'cross_property': getProperty('parent'),
      'cross_value'   : getValue('parent')
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
    // columns is an array here!
    var pair_columns = table.headers;

    var new_entry = {pair: [], count: func_dict['count'](entry)};
    for( var pc=0; pc< pair_columns.length; pc++ ){
      var pair_entry = {};
      for(var c in pair_columns[pc]){
        if(pair_columns[pc].hasOwnProperty(c)){
          pair_entry[c] = func_dict[c](entry, pc);
        }
      }
      new_entry.pair.push(pair_entry);
    }

    return new_entry;
  }

})();