(function(){

	// Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Properties = this.Terraling.Properties || {};

  var properties = this.Terraling.Properties;

  properties.index = {
    init: setupSearch
  };

  var resourceId = 'property';

  function setupSearch(){

    function goToResourceURL(evt, resource, name){
      // get controller name here
      window.location.href = '/groups/'+T.currentGroup+'/'+T.controller+'/'+resource.id;
    }

    T.Search.quickTemplate(
      resourceId,
      {name: 'Property', type: 'property', template: 'resource'},
      { onSelection: goToResourceURL }
    );

  }
	
	
})();