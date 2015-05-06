(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  searches.preview = searches.preview || {};

  searches.preview.save ={
    init: init
  };

  var listenersOn = false;

  function init(json, getTemplate){
    var resultsJson = json;
    var templateFn = getTemplate;

    if(!listenersOn){
      onSubmit();
      listenersOn = true;
    }

    function onSubmit(){
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
      } else if(T.Util.isFileSaverSupported()){
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

        var tableBuilder = searches.preview.table.init(resultsJson, templateFn);

        var result = tableBuilder.createTable(0, 10000);

        // compile the rows in a meaninful way
        var csvString = getCSVTemplate(resultsJson.type).render(result);
        // make a Blob
        var blob = new Blob([csvString], {type: 'text/plain;charset=utf-8'});
        // download it
        saveAs(blob, 'terraling-search-results.csv');
      }
    }

    function getCSVTemplate(type){
      var htmlTemplate = getTemplate(resultsJson.type);
      return HoganTemplates[htmlTemplate.replace(/\/results\//, '/download/')];
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

    return {
      showModal: showModal,
      download : download
    };
  }
})();