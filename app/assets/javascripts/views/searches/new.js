(function(){

  // Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Searches = this.Terraling.Searches || {};

  var searches = this.Terraling.Searches;
  
  // new is a reserved word in JS...
  searches['new'] = {init: formValidator };

  function formValidator(){
    
    // SEARCH PAGE CODE
    hide_impl();

    // Function to reset the form to the initial state
    $("input:reset").click( reset_form );
    $("input[id^=search_group_impl]:radio").click( implication_on );
    $('input[id$=_cross]:radio').click( cross_on );
    $('input[id$=_compare]:radio').click( compare_on );
    $("input[id^=search_group_clust]:radio").click( clustering_on );
    // click happens before submit
    $("#submit-button").click( changeJavascriptFlag );
  }

  function toggle(elems, fn){
    elems = $.isArray(elems) ? elems : [elems];
    $.each(elems, function (index, el){
      if(fn){
        fn(el.id, el.name);
      } else {
        $(el.id)[el.action]('slow');
      }
    });
  }

  /* Function triggered by clicking the reset button */
  function reset_form(){

    show_includes();
    show_delete();
    hide_impl();

    var toEnable = [
      "input[id^=search_group_impl]:radio", "input[id^=search_group_clust]:radio",
      'input[id$=_cross]:radio', 'input[id$=_compare]:radio'
    ];

    toggle(mapToName(toEnable, ''), enable);
  }

  /* Function triggered by selecting an Implication radio button */
  function implication_on(){

    hide_includes();
    show_impl();

    var name = "Universal Implication";

    var toDisable = [
      'input[id$=_cross]:radio', 'input[id$=_compare]:radio',
      "input[id^=search_group_clust]:radio"
    ];

    toggle(mapToName(toDisable, name), disable);
  }

  function mapToName(array, name){
    return $.map(array, function (value){
      return {id: value, name: name };
    });
  }

  function clustering_on(){

    hide_includes();
    hide_delete();

    var name = "Similarity";

    var toDisable = [
      'input[id$=_cross]:radio', 'input[id$=_compare]:radio',
      "input[id^=search_group_impl]:radio"
    ];

    toggle(mapToName(toDisable, name), disable);
  }

  // Function triggered by selecting a Cross radio button
  function cross_on(event){

    var id = '#'+event.target.id;
    var name = "Constraints Cross On";

    hide_includes();
    hide_impl();

    var toDisable = [
      'input[id$=_compare]:radio', "input[id^=search_group_impl]:radio",
      "input[id^=search_group_clust]:radio", "input[id=category_0_value_pairs_options]"
    ];

    toggle(mapToName(toDisable, name), disable);

    disable_except('input[id$=_cross]:radio', id);
  }

  // Function triggered by selecting a Compare radio button
  function compare_on(event){

    var id = '#'+event.target.id;
    var name = "Constraints Compare On";
    var depth    = /1_compare$/.test(id) ? '0' : '1';
    var selector = 'input[id$='+depth+'_compare]:radio';

    hide_includes();
    hide_impl();

    var toDisable = [
      'input[id$=_cross]:radio', "input[id^=search_group_impl]:radio",
      "input[id^=search_group_clust]:radio", selector
    ];

    toggle(mapToName(toDisable, name), disable);
  }

  function show_impl(){
    toggle({id: '#show_impl', action: 'show'});
  }

  function hide_impl(){
    toggle({id: '#show_impl', action: 'hide'});
  }

  /* Function to hide divs of display section of the search */
  function hide_delete(){
    toggle([{id: '#display', action: 'hide'}, {id: '#display_text', action: 'hide'}]);
  }

  /* Function to show hidden divs of display section of the search */
  function show_delete(){
    toggle([{id: '#display', action: 'show'}, {id: '#display_text', action: 'show'}]);
  }

  /* Function to group the hiding of includes div */
  function hide_includes(){
    toggle([{id: '#show_parent', action: 'hide'}, {id: '#show_child', action: 'hide'}]);
  }

  /* Function to group the showing of includes div */
  function show_includes(){
    toggle([{id: '#show_parent', action: 'show'}, {id: '#show_child', action: 'show'}]);
  }

  /* Function to disable an element */
  function disable(element, name){
    var el     = $(element);
    var parent = el.parent();

    el.attr("disabled", true);
    parent.addClass("gray");
    parent.parent().children(".blue").remove();
    var tplPath = T.controller.toLowerCase() + '/form_field_disabled';
    parent.parent().append(HoganTemplates[tplPath].render({name: name}));
  }

  /* Function to enable an element */
  function enable(element){
    var el     = $(element);
    var parent = el.parent();

    el.attr("disabled", false);
    parent.removeClass("gray");
    parent.parent().children(".blue").remove();
  }

  function disable_except(elements_regexp, except){
    var name = "Constraints";
    disable($(elements_regexp).not($(except)), name);
  }

  function enable_similarity_radial_tree(){
    var label = HoganTemplates[T.controller.toLowerCase() + '/form_radial_tree_field'].render();
    $("#clustering").append(label);
  }

  function changeJavascriptFlag(){
    // change the flag
    $('#hidden_javascript').val(true);
  }

})();