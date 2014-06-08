(function(){
	// Init the Lings module here
  this.Terraling = this.Terraling || {};

  var search = this.Terraling.Search = {};

  var currentId;

  function createTypeahead(id, dictionaries){
    currentId = id;

    var options = {
      hint: true,
      minLength: 1,
      highlight: true
    };

    $('#'+currentId).typeahead(options, dictionaries);
  }

  function createMatcher(prefetchURL){
    var engine = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      prefetch: {
        url: prefetchURL,
        filter: function(list){
          return $.map(list, function (entry){

            return {name: entry.ling.name.replace(/\\/g, ''), id: entry.ling.id };

          });
        }
      }
    });

    engine.initialize();
    return engine.ttAdapter();
  }

  function createDictionary(name, role, prefetchURL){
    var matcher = createMatcher(prefetchURL);

    var template = createTemplate(role);

    return {
      name: name,
      source: matcher,
      template: template,
      displayKey: 'name'
    };
  }

  function createTemplate(type){
    var templates = {
      'expert': {
        empty: ['<div class="empty-message">unable to find any Language that match the current query</div>'],
        suggestion: Handlebars.compile('<p><strong>{{name}}</strong></p>')
      }
    };

    return templates[type] || templates.expert;
  }

  function bindSelection(handler){
    $('#'+currentId).on('typeahead:selected', handler);
  }

  search.create = createTypeahead;
  search.createDictionary = createDictionary;
  search.onSelection = bindSelection;

})();