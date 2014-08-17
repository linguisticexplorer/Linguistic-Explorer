(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};

  searches.preview.initSave = initSaveSearch;

  function initSaveSearch(){

    var saveButton = $('#saveit');

    var saveEnabled = saveButton.length;

    if(saveEnabled){

      saveButton.click(function(){

        var queryJsonString = JSON.stringify(query.search, null, 0);

        var resultsJsonString = JSON.stringify(makeResultsJson(), null, 0);

        // add search query
        $('[name="search[query_json]"]').val(queryJsonString);

        // add results json
        $('[name="search[result_groups_json]"]').val(resultsJsonString);

        $('#save-modal').modal('show');

      });


      $('#save-form').on('submit', function (e){
        var params = $(this).serialize();
        
        $('#save-search').button('loading');

        // Prevent page change: use AJAX power!
        e.preventDefault();

        saveSearch(params);
        
      });
    }
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
    $.post("/groups/"+T.currentGroup+"/searches", data, function (json){

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
      
    });
  }
})();