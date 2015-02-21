(function(){
	// Init the module here
  this.Terraling = this.Terraling || {};

  var home = this.Terraling.Home = {};

  home.init = function(){
    // Carousel
    $('.carousel').carousel({
      interval: 4000
    });

    // Typeahead
    createMultiTypeahead();

	};

  function createMultiTypeahead(){

    var id = 'resources';
    
    // create a dictionary for each group
    var resourceName = 'resource',
        resourceType = 'ling',
        templateType = 'groups';

    var selectionAction = goToResourceURL;

    function createResolver(group){
      return function (entry){
          return {
            name: entry[resourceType].name.replace(/\\/g, ''),
            id: entry[resourceType].id,
            group: group.name,
            group_id: group.id
          };
        };
    }

    $.when(T.promises.groups).then(function(){
      var placeholder = 'Type here for a '+resourceName+' in Terraling. (e.g. type "eng")';

      // change placeholder
      $('#'+id +'-search-field').attr('placeholder', placeholder);

      var dictionaries = [];
      $.each(T.groups, function (id, group){

        var dictionary = T.Search.createDictionary(group.name, resourceType, templateType, createResolver(group), id);
        dictionaries.push(dictionary);
      });

      // Setup the Typeahead matcher engine
      

      T.Search.init(id +'-search-field', dictionaries);
      T.Search.onSelection(selectionAction);

    });
  }

  function goToResourceURL(evt, ling, name){
    // limit to lings for the moment
    window.location.href = '/groups/'+ling.group_id+'/lings/'+ling.id;
  }

})();
