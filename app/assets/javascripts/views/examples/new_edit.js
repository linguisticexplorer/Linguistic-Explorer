(function(){

	// Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Examples = this.Terraling.Examples || {};

  var examples = this.Terraling.Examples;

  examples['new'] = examples.edit = {
    init: setupSearches,
    destroy: destroySearches
  };

  var resourceId1 = 'ling',
      resourceId2 = 'prop';

  var payload = {};

  function destroySearches(){
    // $('#'+resourceId1+'-search-field').typeahead('destroy');
    // $('#'+resourceId2+'-search-field').typeahead('destroy');
    
  }

  function setupSearches(){

    // update the payload with the current values
    // it's not yet a typeahead, so we can use val() here
    payload.ling_name = $('#'+resourceId1 + '-search-field').val();
    payload.prop_name = $('#'+resourceId2 + '-search-field').val();

    // T.Search.quickTemplate(
    //   resourceId1,
    //   {name: 'Language', type: 'ling', template: 'resource'},
    //   { onSelection: updatePayload('ling') }
    // );

    // T.Search.quickTemplate(
    //   resourceId2,
    //   {name: 'Property', type: 'property', template: 'resource'},
    //   { onSelection: updatePayload('prop') }
    // );

    // // Update the search fields
    // // Now it's a typeahead: don't use val() but its own function
    // $('#'+resourceId1+'-search-field').typeahead('val', payload.ling_name);
    // $('#'+resourceId2+'-search-field').typeahead('val', payload.prop_name);
    
    // at this point it should update itself?
    checkLp();
  }

  function updatePayload(type){

    // parametric updater
    function closure (evt, resource, resLongName){
      payload[type + '_name'] = resource.name;
      payload[type + '_id'] = resource.id;
      checkLp();
    }

    return closure;
  }

  function checkLp(){
    if(payload.ling_name && payload.prop_name){
      $.getJSON(
        '/groups/'+T.currentGroup+'/lings_properties/exists',
        payload)
        .done(updateCheck)
        .fail(serverError)
        .always();
    } else {
      $('#save-example')
        .attr('disabled', '')
        .addClass('disabled');
    }
  }

  function updateCheck(json){
    var text = "No "+T.groups[T.currentGroup].lings_property_name+" Found";
    
    var button = $('#save-example')
      .attr('disabled', '')
      .toggleClass('disabled', !json.exists);

    if(json.exists){
      $("#lp_val").val(json.id);
      text = '"'+json.value+ '"';
      button.removeAttr('disabled');

    }

    $("#lp-status").text(text)
      .toggleClass("alert-success", json.exists)
      .toggleClass("alert-warning", !json.exists);
  }

  function serverError(){
    $("#lp-status")
      .text("An Error occurred on the server")
      .addClass("alert-danger");
  }
	
	
})();