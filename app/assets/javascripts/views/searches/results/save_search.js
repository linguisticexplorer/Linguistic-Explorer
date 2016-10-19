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
        // Prevent page change: use AJAX power!
        e.preventDefault();
        if ($("input#save-search-name").val()) {
          $("#blank-error").hide();
          var params = $(this).serialize();
          $('#save-search')
            .button('loading')
            .attr('disabled', true);

          saveSearch(params);
        } else {
          $("#blank-error").show();
        }
      });
    }

    function showModal(){

      var queryJsonString = $('#search_results').data('query');

      // add search query
      $('[name="search[query_json]"]').val(JSON.stringify(queryJsonString));

      // if @result_group is present then copy it into result_groups_json input
      if ($('[name="search[result_groups_json]"]').length) {
        var resultGroupsJsonString = $('#search_results').data('result-groups');
        $('[name="search[result_groups_json]"]').val(JSON.stringify(resultGroupsJsonString));
      }

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
      newDownload();
    }

    function getImageBlob(){
      var chart = $('#similarity_tree').html();
      return new Blob([chart], {type: 'image/svg+xml'});
    }

    function getTableBlob(){
      var tableBuilder = searches.preview.table.init(resultsJson, templateFn);
      // 10000 rows is the current hard limit
      var result = tableBuilder.createTable(0, 10000);
      // now add the commas (there's no easy way to do this in Mustache)

      // compile the rows in a meaninful way
      var csvString = getCSVTemplate(resultsJson.type).render(result);
      return new Blob([csvString], {type: 'text/plain;charset=utf-8'});
    }

    function newDownload(){

      if(T.Util.isFileSaverSupported()){

        var blob = resultsJson.type === 'clustering' ? getImageBlob() : getTableBlob();
        // download it
        saveAs(blob, 'terraling-search-results-'+resultsJson.type+'.csv');
        $('#processingProgress').text('Done');
      } else {
        $('#processingProgress').text('It is not possible to download the current results.');
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