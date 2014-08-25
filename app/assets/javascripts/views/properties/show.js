// Now load the module
(function(){

    // Init the Lings module here
    this.Terraling = this.Terraling || {};
    this.Terraling.Properties = this.Terraling.Properties || {};

    var properties = this.Terraling.Properties;

    properties.show = {
        init: setupAnalysis
    };

    function setupAnalysis(){
      // load Map
      $("#mapButton").one('click', getSureness);
    }

    function loadMap(stylingFn){
      var options = {
        name: $('#details').data('id'),
        type: 'property',
        colors: stylingFn
      };
      T.Visualization.Map.init('property-map', options);
    }

    function getSureness(){
      var id = $('#details').data('id');

      var url = '/groups/'+T.currentGroup+'/properties/sureness?id='+id;

      var sureness_values = {
        'certain': 'green',
        'revisit': 'orange',
        'need_help': 'red'
      };

      $.get(url).always(function (json){
        var dict;

        if(json.success){
          dict = {};
          $.each(json.values, function(i, val){
            dict[val[0]] = sureness_values[val[1]];
          });
        }
        var stylingFn = surenessFn(dict);

        loadMap(stylingFn);
      });
    }

    function surenessFn(values){
      return function (entry){
        if(values){
          return values[entry.id] || 'green';
        } else {
          return 'red';
        }
      };
    }

})();