(function(){

	// Init the module here
  this.Terraling = this.Terraling || {};
  this.Terraling.Groups = this.Terraling.Groups || {};

  var groups = this.Terraling.Groups;

  groups.show = {
    init: initPage
  };

  var resourceId = 'resources';

  function initPage (){
    $('[data-toggle="popover"]').popover({
      trigger: "hover",
      animation: 500,
      placement: "top"
    });

    createMultiTypeahead();
  }

  function createMultiTypeahead(){

    var id = 'resources';
    
    // create a dictionary for each group
    var resourceName = 'resource';

    var selectionAction = goToResourceURL;

    $.when(T.promises.groups).then(function(){

      // change placeholder
      $('#'+id +'-search-field').attr('placeholder', $('#searchLabel').data('label'));
      
      // multi-dictionary typeahead
      var dictionaries = [];
      $.each(['ling', 'property'], function (index, entityType){
        
        var templateType = 'resources';
        var name = T.groups[T.currentGroup][entityType === 'ling' ? 'ling0_name' : 'property_name'];
        var dictionary = T.Search.createDictionary(name, entityType, templateType);
        dictionaries.push(dictionary);
      });

      // Setup the Typeahead matcher engine
      

      T.Search.init(id +'-search-field', dictionaries);
      T.Search.onSelection(selectionAction);

    });
  }

  function goToResourceURL(evt, resource, name){
    window.location.href = '/groups/'+T.currentGroup+'/'+resource.type+'/'+resource.id;
  }
	
	
})();