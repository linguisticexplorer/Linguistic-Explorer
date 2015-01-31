(function(){
	// Init the module here
  this.Terraling = this.Terraling || {};

  var search = this.Terraling.Search = {};

  var currentId;

  var binds = 0;

  // something in here to clear the Typeahead cache
  // when the dataset has changed

  function createTypeahead(id, dictionaries){
    currentId = id;

    var options = {
      hint: true,
      minLength: 1,
      highlight: true,
      engine: Hogan
    };

    $('#'+currentId).typeahead(options, dictionaries);

    var fCode = 70,
        fCodeOsx = 6;
    
    // prevent multi-binding for the moment:
    // first comes first wins
    if(binds < 2){
      binds++;

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
  }

  function createMatcher(type, group, resolver){

    function defaultResolver(entry){
      return {name: entry[type].name.replace(/\\/g, '').replace(/\_/, ' '), id: entry[type].id, type: types[type] };
    }

    function dataTransform(list){
      return $.map(list, resolver || defaultResolver);
    }

    var engine = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      prefetch: {
        url: getPrefetchURL(type, group),
        filter: dataTransform
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

  function createDictionary(name, type, templateType, entityResolver, group){
    var matcher = createMatcher(type, group, entityResolver);

    var template = createTemplate(templateType, name);

    return {
      name: name,
      source: matcher,
      templates: template,
      displayKey: 'name'
    };
  }

  function createTemplate(type, name){
    // ensure type string
    type = type || '';
    var emptyTemplate = [
      '<div class="empty-message">unable to find any '+
      type[0].toUpperCase() + type.substring(1)+
      ' that match the current query</div>'
    ];
    var templates = {
      'expert': {
        empty: emptyTemplate,
        // suggestion: Handlebars.compile('<p><strong>{{name}}</strong></p>')
      },
      'resource':{
        empty: emptyTemplate,
        // suggestion: Handlebars.compile('<p><strong>{{name}}</strong></p>')
      },
      'groups':{
        // header: '<div><h4 class="group-header">Group: '+name+'</h4></div>',
        // suggestion: Handlebars.compile('<p><strong>{{name}}</strong></p>')
        header: HoganTemplates['typeahead/multi_search_header'].render({name: name})
      },
      'resources':{
        header: HoganTemplates['typeahead/multi_resource_header'].render({name: name})
      }
    };

    return templates[type] || templates.resource;
  }

  function bindSelection(handler){
    $('#'+currentId).on('typeahead:selected', handler);
  }


  function getPrefetchURL(type, group){
    return getURL(type, group);
  }

  var types = {
    'ling': 'lings',
    'property': 'properties',
    'membership': 'memberships'
  };

  function getURL(type, group){
    var group_id = group || T.currentGroup;
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
          resourceName = 'resource';
        }
      }

      // Setup the Typeahead matcher engine
      var dictionary = createDictionary(resourceName, resourceType, templateType, entityResolver);

      createTypeahead(id +'-search-field', [dictionary]);

      // in theory this stuff should wait the dictionary promise...
      // change placeholder
      $('#'+id +'-search-field').attr('placeholder', 'Looking for a specific '+resourceName + '?');

      bindSelection(selectionAction);

    });
  };

})();