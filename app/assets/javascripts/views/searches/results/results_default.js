(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};

  searches.preview.renderDefault = defaultMapping;

  function defaultMapping(columns, entry){
    var func_dict = {
      'ling_0'    : getLing('parent'),
      'property_0': getProperty('parent'),
      'value_0'   : getValue('parent'),
      'example_0' : getExamples('parent'),
      'ling_1'    : getLing('child'),
      'property_1': getProperty('child'),
      'value_1'   : getValue('child'),
      'example_1' : getExamples('child')
    };

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

    var new_entry = {};
    for( var c in columns ){
      if(columns.hasOwnProperty(c)){
        new_entry[c] = func_dict[c](entry);
      }
    }
    return new_entry;
  }

})();