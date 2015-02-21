(function(){

	// Init the module here
  this.Terraling = this.Terraling || {};
  this.Terraling.Lings = this.Terraling.Lings || {};

  var lings = this.Terraling.Lings;

  lings.index = lings.depth = {
    init: setupSearch
  };

  var resourceId = 'ling';

  function setupSearch(){

    function goToResourceURL(evt, resource, name){
      // get controller name here
      window.location.href = '/groups/'+T.currentGroup+'/'+T.controller.toLowerCase()+'/'+resource.id;
    }

    function nameResolver(){
      return T.groups[T.currentGroup].ling0_name.split(' ').join(' - ');
    }

    T.Search.quickTemplate(
      resourceId,
      {type: 'ling', template: 'resource'},
      {nameResolver: nameResolver, onSelection: goToResourceURL}
    );

  }
	
	
})();