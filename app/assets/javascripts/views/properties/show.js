// Now load the module
(function(){

    // Init the Lings module here
    this.Terraling = this.Terraling || {};
    this.Terraling.Properties = this.Terraling.Properties || {};

    var properties = this.Terraling.Properties;

    properties.show = {
        init: setupAnalysis
    };

    var resourceId = 'property';
    var resourceTemplate,
        resourcesDict;

    function setupAnalysis(){

      // Setup the resource "cache"
      // we use it to prevent duplicates on the list
      resourcesDict = {};

      var tplPath = T.controller.toLowerCase() + '/' + T.action.toLowerCase();
      resourceTemplate = HoganTemplates[tplPath];

      // init the typeahead
      setupTypeahead();

      $(document)
        .on('click', '.remove-items', removeProperties)
        .on('click', '.remove-item' , removeProperty);

      // load Map
      $("#mapButton").one('click', loadMap);
    }

    function loadMap(){
      var options = {
        name: $('#details').data('id'),
        type: 'property'
      };
      T.Visualization.Map.init('property-map', options);
    }

    function setupTypeahead(){

      T.Search.quickTemplate(
        resourceId,
        {type: 'property', template: 'resource'},
        {nameResolver: nameResolver, onSelection: onLingSelected}
      );
    }

    function nameResolver(){
      return T.groups[T.currentGroup].property_name.split(' ').join(' - ');
    }

    function onLingSelected(evt, prop, name){

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

      checkButtons($('ul#selected-items li').length);

      evt.preventDefault();
    }

    function removeProperties() {
      $('#selected-items li').each( function () {
          var item = $(this);
          item.remove();
      });
      // reset the cache
      resourcesDict = {};

      checkButtons(false);


      evt.preventDefault();
    }

})();