(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};

  searches.preview.save ={
    init: init,
    destroy: clearCache
  };

  var resultsJson;
  var saver, renderer;

  function init(json, getTemplate){
    if(!saver){
      resultsJson = json;

      renderer = searches.preview[resultsJson.type].init(resultsJson, getTemplate);

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

  function clearCache(){
    saver = null;
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
    var header;

    function processData(table, list, next){
      list.forEach(function (row, index){
        table.rows.push(renderer.makeRow(header, row, index));
      });

      setTimeout(function(){
        return next(null, table);
      }, 0);
    }

    if(T.Util.isFileSaverSupported()){

      var table = renderer.makeTable();

      header = getHeader(table);

      // Show a modal where a progress bar will show the progress of the making of the data
      var chunks = T.Util.makeChunks(JSON.parse(JSON.stringify(resultsJson)).rows);

      async.reduce(chunks, table, processData, function (err, result){
        // compile the rows in a meaninful way
        // make a Blob
        // download it
      });
    }
  }

  function getHeader(table){
    switch (resultsJson.type){
      case 'compare':
      case 'default':
        return table.header;
      case 'cross':
      case 'implication':
        return table;
      default:
        // Fail silently....
        return {};
    }
  }
})();