(function(){
	// Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Memberships = this.Terraling.Memberships || {};

  var memberships = this.Terraling.Memberships;

  var resourceId = 'resources';
  
  // some cache vars
  var lingDictionary,
      resourcesDict,
  // what's group name for lings?
      lingsName,
  // button template for resource
      resourceTemplate;

  function setupPage(){
    // Check current role and toggle panel
    enableRolesPanel();

    resourceTemplate = HoganTemplates[T.controller.toLowerCase() + '/edit'];
    mapResourcesRoles();
    
    $('.membership_role').change(enableRolesPanel);

    $('body')
        .on('click', '#remove-resources', removeLanguages)
        .on('click', '.remove-resource' , removeLanguage);

    T.Search.quickTemplate(
      resourceId,
      {type: 'ling', template: 'expert'},
      {nameResolver: nameResolver, onSelection: onLingSelected}
    );
    
  }

  function nameResolver(){
    return T.groups[T.currentGroup].ling0_name.split(' ').join(' - ');
  }

  function mapResourcesRoles(){
    resourcesDict = {};
    $('#selected-resources li').each( function(){
      resourcesDict[$(this).text()] = ''+$(this).data('id');
    });
  }

  function removeLanguage(evt){
    var item = $(this).parent();

    var name = item.text().substring(1);

    delete resourcesDict[name];

    item.remove();
    // refresh hidden field values
    updateResourceField();

    evt.preventDefault();
  }

  function removeLanguages(evt) {
    $('#selected-resources li').each( function () {
        var item = $(this);
        item.remove();
    });
    // clear the cache
    resourcesDict = {};

    updateResourceField();
    
    evt.preventDefault();
  }

  function updateResourceField(){
    $('#membership_'+resourceId).val($.map(resourcesDict, function(value){
      return value;
    }).join(';'));
  }

  function onLingSelected(evt, ling, name){

    if(!resourcesDict[ling.name]){

      resourcesDict[ling.name] = ''+ling.id;

      $('#selected-resources').append(resourceTemplate.render(ling));
    }

    updateResourceField();

    $('#'+resourceId+'-search-field').typeahead('val', '');

  }

  function enableRolesPanel(){
    if(this !== window){
      var isValidRole = $(this).val() === 'expert';
      $('#'+resourceId + '-search , #'+resourceId + '-list ').toggle(isValidRole);
    }
  }

  // make both point to the same JS object
  memberships['new'] = memberships['edit'] = {};
  
  // will work for edit as well
  memberships['new'].init = setupPage;

})();