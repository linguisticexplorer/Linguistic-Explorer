(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};

  searches.preview.save ={
    init: init
  };

  var resultsJson;
  var saver;

  function init(json){
    if(!saver){
      resultsJson = json;

      // don't worry: in case it's forced the server will reject it anyway
      $('#save-form').on('submit', function (e){
        var params = $(this).serialize();
        
        $('#save-search')
          .button('loading')
          .attr('disabled', true);

        // Prevent page change: use AJAX power!
        e.preventDefault();

        saveSearch(params);
        
      });

      saver = {
        showModal: showModal,
        download : download
      };
    }
    return saver;
  }

  function showModal(){

    var queryJsonString = $('#search_results').data('query');

    // add search query
    $('[name="search[query_json]"]').val(JSON.stringify(queryJsonString));

    // enable the save button in case it was disabled
    $('#save-search').attr('disabled', false);
    $('#save-modal').modal('show');

  }

  function saveSearch(data){
    $.post("/groups/"+T.currentGroup+"/searches", data)
    .done(onSuccess)
    .fail(onSuccess);

    function onSuccess(json){

      var idToShow = json.success ? 'success-explanation' : 'error-messages',
          errorMessages = json.success ? '' : json.errors;

      if(errorMessages){
        var template = HoganTemplates[T.controller.toLowerCase() + '/errors_template'];
        var html = template.render(errorMessages);

        $('#'+idToShow).append(html);
      }

      $('#'+idToShow).fadeIn();
      
    }
  }

  function download(){
    $('#download-modal').modal('show');
    if(resultsJson.type === 'clustering'){
      // just open a new window with the image
      downloadImage();
    } else if(T.Util.downloadTest()){
      newDownload();
    }
  }

  function downloadImage(){
    if(T.Util.isFileSaverSupported()){
      var chart = $('#similarity_tree').html();
      var blob = new Blob([chart], {type: 'image/svg+xml'});
      saveAs(blob, 'similarity_tree.svg');

      $('#processingProgress').text('Done');
    }
  }

  function newDownload(){
    if(T.Util.isFileSaverSupported()){
      // Show a modal where a progress bar will show the progress of the making of the data
      var chunks = T.Util.makeChunks(JSON.parse(JSON.stringify(resultsJson)));
    }

  }
})();