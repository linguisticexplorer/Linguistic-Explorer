// Now load the module
(function(){

    // Init the Lings module here
    this.Terraling = this.Terraling || {};
    this.Terraling.Properties = this.Terraling.Properties || {};

    var properties = this.Terraling.Properties;

    properties.show = {
        init: setupPage
    };

    var resourceId = 'property';
    var currentId, currentName,
        resourceTemplate,
        resourcesDict;

    function setupPage(){
      setupAnalysis();

      if($('#addValue').length){
        setupAddValueModal();
      }
    }

    function setupAnalysis(){

      currentName = $('#details').data('name');
      currentId = $('#details').data('id');

      // Setup the resource "cache"
      // we use it to prevent duplicates on the list
      resourcesDict = {};
      resourcesDict[currentName] = currentId;

      var tplPath = T.controller.toLowerCase() + '/' + T.action.toLowerCase();
      resourceTemplate = HoganTemplates[tplPath];

      // init the typeahead
      setupTypeahead('property', propertyResolver, onItemSelected);

      $(document)
        .on('click', '.remove-items', removeProperties)
        .on('click', '.remove-item' , removeProperty);

      // load Map
      $("#mapButton").one('click', loadMap);
    }

    function loadMap(){
      var options = {
        name: currentId,
        type: 'property',
        markerStyler: getStyler()
      };
      // one color per property value
      T.Visualization.Map.init('property-map', options);
    }

    function getStyler(){

      function styler(entry){
        var color = 'blue';
        // TODO:
        // Just show a marker for the moment...
        // Later will add later the popup data to the marker
        return {
          markerColor: color,
          iconColor: 'white',
          icon: 'info'
        };
      }

      return null;
    }

    function setupTypeahead(type, resolver, onSelection){

      T.Search.quickTemplate(
        type,
        {type: type, template: 'resource'},
        {nameResolver: resolver, onSelection: onSelection}
      );
    }

    function propertyResolver(){
      return T.groups[T.currentGroup].property_name;
    }

    function setupAddValueModal(){
      $('#lingsModal').modal({show: false});
      setupTypeahead('ling', lingResolver, onLingSelected);

      $('body').on('click', '#addValue', function(){
        $('#lingsModal').modal('toggle');
      });
    }

    function lingResolver(){
      return T.groups[T.currentGroup].ling0_name;
    }

    function onLingSelected(evt, ling, name){
      // go to the supported edit page within the right anchor
      var params = '?commit=Select&prop_id='+currentId+'#value-select';
      window.location.href = '/groups/'+T.currentGroup+'/lings/'+ling.id+'/supported_set_values'+params;
    }

    function onItemSelected(evt, prop, name){

      if(!resourcesDict[prop.name]){

        resourcesDict[prop.name] = ''+prop.id;

        $('#selected-props').append(resourceTemplate.render(prop));

        checkButtons(true);
      }

      $('#'+resourceId+'-search-field').typeahead('val', '');

    }

    function checkButtons(criteria){
      var buttons = $('div#compare-buttons a');
      if(criteria){
        buttons.removeAttr('disabled');
      } else {
        buttons.attr('disabled', 'disabled');
      }
    }

    // remove a language from the cache
    function removeProperty(){
      var item = $(this).parent();

      var name = item.text().substring(1);

      delete resourcesDict[name];

      item.remove();

      checkButtons($('#selected-props li').length);

      evt.preventDefault();
    }

    function removeProperties() {
      document.querySelectorAll("#selected-props li").forEach(function(prop) {
          prop.remove();
      });
      // reset the cache
      resourcesDict = {};

      checkButtons(false);


      // evt.preventDefault();
    }

})();