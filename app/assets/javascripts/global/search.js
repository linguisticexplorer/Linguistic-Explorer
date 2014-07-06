(function(){
	// Init the module here
  this.Terraling = this.Terraling || {};

  var search = this.Terraling.Search = {};

  var currentId;

  function createTypeahead(id, dictionaries){
    currentId = id;

    var options = {
      hint: true,
      minLength: 1,
      highlight: true,
      engine: Handlebars
    };

    $('#'+currentId).typeahead(options, dictionaries);

    var fCode = 70,
        fCodeOsx = 6;

    // bind CTRL/META - f keypress with the search
    $(window).keypress(function (evt){
      if(
        // CTRL / CMD + F in the rest of the World
        evt.which === fCode && (evt.ctrlKey || evt.metaKey) ||
        evt.which === fCodeOsx
      ){
        $('#'+currentId).focus();
        evt.preventDefault();
      }
    });
  }

  function createMatcher(type, resolver){

    function defaultResolver(entry){
      return {name: entry[type].name.replace(/\\/g, ''), id: entry[type].id };
    }

    var engine = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      prefetch: {
        url: getPrefetchURL(type),
        filter: function(list){
          return $.map(list, resolver || defaultResolver);
        }
        // Later add some stuff in here to show a feedback to the user while waiting an async response
        // ,ajax: {
        //   beforeSend: function(){},
        //   complete:   function(){}
        // }
      }
    });

    engine.initialize();
    return engine.ttAdapter();
  }

  function createDictionary(name, type, templateType, entityResolver){
    var matcher = createMatcher(type, entityResolver);

    var template = createTemplate(templateType);

    return {
      name: name,
      source: matcher,
      template: template,
      displayKey: 'name'
    };
  }

  function createTemplate(type){
    var emptyTemplate = ['<div class="empty-message">unable to find any Resource that match the current query</div>'];
    var templates = {
      'expert': {
        empty: emptyTemplate,
        suggestion: '<p><strong>{{name}}</strong></p>'
      },
      'resource':{
        empty: emptyTemplate,
        suggestion: '<p><strong>{{name}}</strong></p>'
      }
    };

    return templates[type] || templates.expert;
  }

  function bindSelection(handler){
    $('#'+currentId).on('typeahead:selected', handler);
  }


  function getPrefetchURL(type){
    return getURL(type);
  }

  var types = {
    'ling': 'lings',
    'property': 'properties',
    'membership': 'memberships'
  };

  function getURL(type){
    var group_id = T.currentGroup;
    return "/groups/"+group_id+"/"+types[type]+"/list";
  }

  search.init = createTypeahead;
  search.createDictionary = createDictionary;
  search.onSelection = bindSelection;

  search.quickTemplate = function (id, options, callbacks){
    var resourceName = options.name,
        resourceType = options.type,
        templateType = options.template;

    var nameResolver = callbacks.nameResolver,
        entityResolver = callbacks.resolver,
        selectionAction = callbacks.onSelection;

    $.when(T.promises.groups).then(function(){

      // here we're sure of groups loaded
      if(!resourceName){
        if(nameResolver){
          resourceName = nameResolver();
        } else {
          nameResolver = 'resource';
        }
      }

      // change placeholder
      $('#'+id +'-search-field').attr('placeholder', 'Type here for a '+resourceName);

      // Setup the Typeahead matcher engine
      var dictionary = T.Search.createDictionary(resourceName, resourceType, templateType, entityResolver);

      T.Search.init(id +'-search-field', [dictionary]);
      T.Search.onSelection(selectionAction);

    });
  };

})();