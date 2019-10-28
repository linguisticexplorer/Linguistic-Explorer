(function(){

    // Init the Lings module here
    this.Terraling = this.Terraling || {};
    this.Terraling.Lings = this.Terraling.Lings || {};

    var lings = this.Terraling.Lings;

    lings.show = {
        init: setupAnalysis
    };
    
    // local variable containing the state of the page
    var currentId,
        currentDepth,
        resourceTemplate,
        resourcesDict;

    var resourceId = 'ling';

    var queryTemplate = {
      authenticity_token: $('meta[name=csrf-token]').attr('content'),
      search: {
        // will use it for clustering
        advanced_set : {},
        // will use it for compare
        ling_set: {'0': '', '1': ''},
        // put the lings ids here
        lings: {'0': [], '1': [] },
        // static stuff used to prevent any filter on properties
        property_set: {'0': 'any', '1': 'any'},
        lings_property_set: {'0': 'any', '1': 'any'},
        ling_keywords: {'0': null, '1': null},
        property_keywords: {'0': null, '1': null},
        example_fields: {'0': 'description', '1': 'description'},
        example_keywords: {'0': null, '1': null},
        // enable javascript
        javascript: true
      }
    };

    function setupAnalysis(){
      var field = $('#details');
      // Set the id
      currentId = field.data('id') || '';
      currentName = field.data('name');
      currentDepth = + field.data('depth') || 0;
      // Setup the resource "cache"
      // we use it to prevent duplicates on the list
      resourcesDict = {};
      resourcesDict[currentName] = currentId;

      var tplPath = T.controller.toLowerCase() + '/' + T.action.toLowerCase();
      resourceTemplate = HoganTemplates[tplPath];

      // bind some buttons here
      bindAnalysis('#compare-lings', 'compare');
      bindAnalysis('#similarity-tree', 'clustering');
      // Remember to destroy the renderer once the modal is hidden
      $('#analysis-modal').on('hidden.bs.modal', T.Searches.preview.table.destroy);
    

      // init the typeahead
      setupTypeahead();

      $(document)
        .on('click', '.remove-items', removeLanguages)
        .on('click', '.remove-item' , removeLanguage);

      // load Map
      $("#mapButton").one('click', loadMap);
      // $('#surenessButton').one('click', loadHeatMap);
    }

    function checkButtons(criteria){
      var buttons = $('div#compare-buttons a');
      if(criteria){
        buttons.removeAttr('disabled');
      } else {
        buttons.attr('disabled', 'disabled');
      }
    }

    function addLingsToParams(params){
      // iterate on 
      var ids = $.map( $('#selected-lings li'), function (entry, i) {
          return $(entry).data('id');
      });
      // add the current id
      ids.push(currentId);
      
      // add the ids to the relative depth
      params.lings['' + currentDepth] = ids;
    }

    function addSearchTypeToParams(params, type){
      var isClustering = 'clustering' === type;
      if(isClustering){
        params.advanced_set.clustering = 'hamming';
      } else {
        params.ling_set['' + currentDepth] = 'compare';
      }
    }

    function doAnalysis(type){
      var params = buildQueryParams(type);
      return $.post(analysisURL(), params);
    }

    function buildLingsURL(){
        //TODO: refactor this stuff here!
        return '&search[lings][0][]=' + ($.map( $('#selected-lings li'), function (val, i) {
            return resourcesDict[$.trim($(val).text())];
        })).join('&search[lings][0][]=');
    }

    function buildQueryParams(type){
      params = staticParams();
      // add the type here
      addSearchTypeToParams(params.search, type);
      // add lings here
      addLingsToParams(params.search);
      // return params
      return params;
    }

    // Just save static parameters in somewhere
    function staticParams(){
      return JSON.parse(JSON.stringify(queryTemplate));
    }

    function analysisURL(){
      return '/groups/' + T.currentGroup + '/searches/preview';
    }

    function bindAnalysis(id, type){
      $(document).on('click', id, function (e) {
        if (! $(this).attr("disabled")) {
          // open the modal
          openResultsModal(doAnalysis(type));
        }
      });
    }

    // remove a language from the cache
    function removeLanguage(evt){
      var item = $(this).parent();

      var name = item.text().substring(1);

      delete resourcesDict[name];

      item.remove();

      checkButtons($('ul#selected-lings li').length);

      evt.preventDefault();
    }

    function removeLanguages() {
      document.querySelectorAll("#selected-lings li").forEach(function(ling) {
          ling.remove();
      });
      // reset the cache
      resourcesDict = {};

      checkButtons(false);


      // evt.preventDefault();
    }

    function setupTypeahead(){

      T.Search.quickTemplate(
        resourceId,
        {type: 'ling', template: 'resource'},
        {nameResolver: nameResolver, onSelection: onLingSelected}
      );
    }

    function nameResolver(){
      return T.groups[T.currentGroup]['ling'+currentDepth+'_name'].split(' ').join(' - ');
    }

    function onLingSelected(evt, ling, name){

      if(!resourcesDict[ling.name]){

        resourcesDict[ling.name] = ''+ling.id;

        $('#selected-lings').append(resourceTemplate.render(ling));

        checkButtons(true);
      }

      $('#'+resourceId+'-search-field').typeahead('val', '');

    }

    function loadMap(){
      T.Visualization.Map.init('ling-map', {
        name: $('#map').data('name'),
        type: 'ling'
      });
    }

    function loadHeatMap(){
      $.when(getHeatMapData()).then(function (values){
        
        T.Visualization.Heatmap.init('#sureness-map', values, {
          name: $('#sureness').data('id'),
          type: 'ling'
        });

      });
    }

    function getHeatMapData(){
      // get the data to use for the heatmap
      return $.getJSON('/groups/'+T.currentGroup+'/lings_properties/sureness', {id: $('#sureness').data('id')}).
        done(function (json){
          var result;
          if(exists){
            result = json.data;
          } else {
            result = [];
          }
          return result;
        }).
        fail(function (){
          return [];
        });
    }

    function openResultsModal(promise){
      // clean the modal content
      $('#analysis-results').empty();

      // open the modal
      $('#analysis-modal').modal('show');

      promise.always(function (page){
        
        // get the promise results filtering part of the page
        var html = $('#results-wrapper', page).html();

        // paste the results in the modal
        $('#analysis-results').html(html);

        // init the page js
        T.Searches.preview.init(true, true);
      });

    }

})();
