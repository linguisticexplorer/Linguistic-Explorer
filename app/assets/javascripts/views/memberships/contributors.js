(function(){

	// Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Memberships = this.Terraling.Memberships || {};

  var memberships = this.Terraling.Memberships;

  memberships.contributors = {
    init: setupPage
  };

  var resourceId = 'member';

  function setupPage(){

    $('.expertises').popover({
      title: "Languages List:",
      trigger: "hover",
      animation: 500,
      placement: "top"
    });
    

    // reuse other modules code
    memberships.index.init();

  }
	
	
})();