(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};

  searches.preview.renderCompare = compareMapping;

  function compareMapping(columns, entry){
    var func_dict = {
      // This is a common key
      'compare_property' : getProperty('parent'),
      // This is a common-only key-value
      'common_values'    : getValue('parent'),
      // This is a diff-only key-value
      'ling_value'       : getValue('child')
    };

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

    var col, ling,
        new_entry = {};

    // if entry is common
    if(isCommon(entry)){

      new_entry.common = true;
      // With this code will going to render multiple columns with the same values
      // new_entry['compare_property'] = func_dict['compare_property'](entry, 0);
      // new_entry['common_values']    = [];
      // // we need to iterate the other columns by the number of languages
      // for( col = 0; col < entry.lings.length; col++){
      //   new_entry['common_values'].push(func_dict['ling_value'](entry,0));
      // }
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

})();