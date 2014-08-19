(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};

  searches.preview.initSave = initSaveSearch;

  var resultsJson;

  function initSaveSearch(json){
    // deal with async check of the button:
    // it will check live to trigger or not the function
    $(document).on('click', '#saveit:enabled', function(){

        var queryJsonString = $('#search_results').data('query');

        // resultsJson = json;
        resultsJson = null;

        // add search query
        $('[name="search[query_json]"]').val(JSON.stringify(queryJsonString));

        // add results json
        $('[name="search[result_groups_json]"]').val(JSON.stringify(resultsJson));

        $('#save-modal').modal('show');

      });

    // don't worry: in case it's forced the server will reject it anyway
    $('#save-form').on('submit', function (e){
      var params = $(this).serialize();
      
      $('#save-search').button('loading');

      // Prevent page change: use AJAX power!
      e.preventDefault();

      saveSearch(params);
      
    });
  }


  function makeResultsJson(){

    var rows = resultsJson.rows;
    var saveJson = {};

    function mapChild(sub){
      return sub.lings_property.id;
    }
    
    // do it async:
    // make buckets of 100 entries
    // then iterate async
    for( var i =0; i<rows.length; i++){
      saveJson[rows[i].parent.lings_property.id] = [];
      if(rows[i].child && rows[i].child.lings_property){
        saveJson[rows[i].parent.lings_property.id] = $.map(rows[i].child, mapChild);
      }
    }
    return saveJson;
  }

  function saveSearch(data){
    $.post("/groups/"+T.currentGroup+"/searches", data)
    .done(onSuccess)
    .fail(onSuccess);

    function onSuccess(json){

      var idToShow = json.success ? 'success-explanation' : 'error-messages',
          errorMessages = json.success ? '' : json.errors;

      if(errorMessages){
        // var source = $('#errors_template').html();
        // var template = Handlebars.compile(source);
        var template = HoganTemplates[T.controller.toLowerCase() + 'errors_template'];
        var html = template.render(template);

        $('#'+idToShow).append(html);
      }

      $('#'+idToShow).fadeIn();
      // hide the button so the user can only close the modal
      $('#save-search').hide();
      
    }
  }
})();