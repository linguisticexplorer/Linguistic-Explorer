/* On DOM loaded */
$(function() {

    // SEARCH PAGE CODE
    hide_div('#show_impl');

    // enable_similarity_radial_tree();
//    console.log("OnLoad end");
    // TODO: check javascript capabilities on submit
    // Function to reset the form to the initial state
    $("input:reset").click( function() {
       reset_form();
    });

    $("input[id^=search_group_impl]:radio").click( function() {
      implication_on();
    });

    $('input[id$=_cross]:radio').click( function() {
      cross_on(this);
    });

    $('input[id$=_compare]:radio').click( function() {
      compare_on(this);
    });

    $("input[id^=search_group_clust]:radio").click( function() {
      clustering_on();
    });
});



/* Function to hide a div by id */
function hide_div(id){
    $(id).hide('slow');
}

/* Function to show a div by id */
function show_div(id){
    $(id).show('slow');
}

/* Function triggered by clicking the reset button */
function reset_form(){

    show_includes();
    hide_div('#show_impl');
    enable("input[id^=search_group_impl]:radio");
    enable("input[id^=search_group_clust]:radio");
    enable('input[id$=_cross]:radio');
    enable('input[id$=_compare]:radio');
    show_delete();
}

/* Function triggered by selecting an Implication radio button */
function implication_on(){

    show_div('#show_impl');
    hide_includes();
    var name = "Universal Implication";
    disable('input[id$=_cross]:radio', name);
    disable('input[id$=_compare]:radio', name);
    disable("input[id^=search_group_clust]:radio", name);
}

function clustering_on(){

    hide_includes();
    var name = "Similarity";
    disable('input[id$=_cross]:radio', name);
    disable('input[id$=_compare]:radio', name);
    disable("input[id^=search_group_impl]:radio", name);
    display_delete();
}

// Function triggered by selecting a Cross radio button
function cross_on(radio_element){
    hide_includes();
    hide_div('#show_impl');
    var name = "Constraints Cross On";
    disable('input[id$=_compare]:radio', name);
    disable("input[id^=search_group_impl]:radio", name);
    disable("input[id^=search_group_clust]:radio", name);

    // TODO: disable Value Pairs boxes
    disable("input[id=category_0_value_pairs_options]", name);
    disable_except('input[id$=_cross]:radio', radio_element);
}

// Function triggered by selecting a Compare radio button
function compare_on(radio_element){

    hide_includes();
    hide_div('#show_impl');
    var name = "Constraints Compare On";
    disable('input[id$=_cross]:radio', name);
    disable("input[id^=search_group_impl]:radio", name);
    disable("input[id^=search_group_clust]:radio", name);

    var is_depth_1 = /1_compare$/;
    if(radio_element.id.match(is_depth_1))
    { disable('input[id$=0_compare]:radio', name); }
    else
    { disable('input[id$=1_compare]:radio', name); }

}

/* Function to hide divs of display section of the search */
function display_delete(){
  hide_div('#display');
  hide_div('#display_text');
}

/* Function to show hidden divs of display section of the search */
function show_delete(){
  show_div('#display');
  show_div('#display_text');
}

/* Function to group the hiding of includes div */
function hide_includes(){
  hide_div('#show_parent');
  hide_div('#show_child');
}

/* Function to group the showing of includes div */
function show_includes(){
  show_div('#show_parent');
  show_div('#show_child');
}

/* Function to disable an element */
function disable(element, name){
  //console.log("disable "+element);
  $(element).attr("disabled", true);
  $(element).parent().addClass("gray");
  $(element).parent().parent().children(".blue").remove();
  $(element).parent().parent().append("<div class='italic blue ten'>Disabled by " + name + " settings</div>");
}

/* Function to enable an element */
function enable(element){
//  console.log("enable "+element);
  $(element).attr("disabled", false);
  $(element).parent().removeClass("gray");
  $(element).parent().parent().children(".blue").remove();
}

function disable_except(elements_regexp, except){
    var name = "Constraints";
    disable($(elements_regexp).not(except), name);
}

function enable_similarity_radial_tree(){
    var label = '<label for="search_group_clust_hamming1" class="radio inline">'  +
    '<input id="search_group_clust_hamming1" name="search[advanced_set][clustering]" type="radio" value="hamming_r">' +
    ' Radial Tree' +
    '</label>';

    $("#clustering").append(label);
}