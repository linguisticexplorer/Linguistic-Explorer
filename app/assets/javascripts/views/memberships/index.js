(function(){

	// Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Memberships = this.Terraling.Memberships || {};

  var memberships = this.Terraling.Memberships;

  memberships.index = {
    init: setupSearch
  };

  var resourceId = 'member';

  function setupSearch(){

    function memberResolver(entry){
      return {name: entry.membership.member.name.replace(/\\/g, ''), id: entry.membership.id };
    }

    function goToResourceURL(evt, resource, name){
      // get controller name here
      window.location.href = '/groups/'+T.currentGroup+'/'+T.controller.toLowerCase()+'/'+resource.id;
    }

    T.Search.quickTemplate(
      resourceId,
      {name: 'Member', type: 'membership', template: 'resource'},
      {resolver: memberResolver, onSelection: goToResourceURL}
    );

  }
	
	
})();