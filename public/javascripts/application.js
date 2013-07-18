// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
/* On DOM loaded */
$(function() {
  // PAGINATION CODE
	// Text and image while loading
    var img = "<img src='/images/loader.gif' class='loading'/>",
    once = false;
    // Manage the AJAX pagination and changing the URL
     $(document).on("click", ".apple_pagination.will-paginate .pagination a", function(e) {
        //jQuery.setFragment({ "page" : jQuery.queryString(this.href).page })
        $(".pagination").html(img);
        $.get(this.href, function(result) {
          $(".pagination").html($(".pagination", result)[0]);
          $("#pagination_table").html($("#pagination_table", result));
        });
        history.pushState(null, document.title, this.href);
        e.preventDefault();
    });
    
    $(window).bind("popstate", function() {
      if (once) {
        $(".pagination").html(img);
        $.get(location.href, function(result) {
            $(".pagination").html($(".pagination", result));
            $("#pagination_table").html($("#pagination_table", result));
      });
    } else {
      once = true;
    }
    });

    // SEARCH PAGE CODE
    hide_div('#show_impl');

    enable_similarity_radial_tree();
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

/*menu handler*/
$(function(){
  function stripTrailingSlash(str) {
    if(str.substr(-1) == '/') {
      return str.substr(0, str.length - 1);
    }
    return str;
  }

  var url = window.location.pathname;  
  var activePage = stripTrailingSlash(url);

  $('.nav li a').each(function(){  
    var currentPage = stripTrailingSlash($(this).attr('href'));

    if (activePage == currentPage) {
      $(this).parent().addClass('active'); 
    } 
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
//    console.log("Reset!");
    show_includes();
    hide_div('#show_impl');
    enable("input[id^=search_group_impl]:radio");
    enable("input[id^=search_group_clust]:radio");
    enable('input[id$=_cross]:radio');
    enable('input[id$=_compare]:radio');
    show_delete();
}

name = "";
/* Function triggered by selecting an Implication radio button */
function implication_on(){
//    console.log("implication_on");
    show_div('#show_impl');
    hide_includes();    
    name = "Universal Implication";
    disable('input[id$=_cross]:radio');
    disable('input[id$=_compare]:radio');
    disable("input[id^=search_group_clust]:radio");
}

function clustering_on(){
//    console.log("clustering_on");
    hide_includes();
    name = "Similarity";
    disable('input[id$=_cross]:radio');
    disable('input[id$=_compare]:radio');
    disable("input[id^=search_group_impl]:radio");
    display_delete();
}

// Function triggered by selecting a Cross radio button
function cross_on(radio_element){
    hide_includes();
    hide_div('#show_impl');
    name = "Constraints Cross On";
    disable('input[id$=_compare]:radio');
    disable("input[id^=search_group_impl]:radio");
    disable("input[id^=search_group_clust]:radio");

    // TODO: disable Value Pairs boxes
    disable("input[id=category_0_value_pairs_options]");
    disable_except('input[id$=_cross]:radio', radio_element);
}

// Function triggered by selecting a Compare radio button
function compare_on(radio_element){
//    console.log("compare_on =>"+ radio_element.id);
    hide_includes();
    hide_div('#show_impl');
    name = "Constraints Compare On";
    disable('input[id$=_cross]:radio');
    disable("input[id^=search_group_impl]:radio");
    disable("input[id^=search_group_clust]:radio");

    var is_depth_1 = /1_compare$/;
    if(radio_element.id.match(is_depth_1))
    { disable('input[id$=0_compare]:radio'); }
    else
    { disable('input[id$=1_compare]:radio'); }

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
function disable(element){
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
    name = "Constraints";
    disable($(elements_regexp).not(except));
}

function enable_similarity_radial_tree(){
    var label = '<label for="search_group_clust_hamming1" class="radio inline">'  +
    '<input id="search_group_clust_hamming1" name="search[advanced_set][clustering]" type="radio" value="hamming_r">' +
    ' Radial Tree' +
    '</label>';
    // console.log($("#clustering"));
    $("#clustering").append(label);
}

/**
 * Newick format parser in JavaScript.
 *
 * Copyright (c) Jason Davies 2010.
 *  
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *  
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *  
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * Example tree (from http://en.wikipedia.org/wiki/Newick_format):
 *
 * +--0.1--A
 * F-----0.2-----B            +-------0.3----C
 * +------------------0.5-----E
 *                            +---------0.4------D
 *
 * Newick format:
 * (A:0.1,B:0.2,(C:0.3,D:0.4)E:0.5)F;
 *
 * Converted to JSON:
 * {
 *   name: "F",
 *   branchset: [
 *     {name: "A", length: 0.1},
 *     {name: "B", length: 0.2},
 *     {
 *       name: "E",
 *       length: 0.5,
 *       branchset: [
 *         {name: "C", length: 0.3},
 *         {name: "D", length: 0.4}
 *       ]
 *     }
 *   ]
 * }
 *
 * Converted to JSON, but with no names or lengths:
 * {
 *   branchset: [
 *     {}, {}, {
 *       branchset: [{}, {}]
 *     }
 *   ]
 * }
 */
(function(exports) {
  exports.parse = function(s) {
    var ancestors = [];
    var tree = {};
    var tokens = s.split(/\s*(;|\(|\)|,|:)\s*/);
    for (var i=0; i<tokens.length; i++) {
      var token = tokens[i];
      switch (token) {
        case '(': // new branchset
          var subtree = {};
          tree.branchset = [subtree];
          ancestors.push(tree);
          tree = subtree;
          break;
        case ',': // another branch
          var subtree = {};
          ancestors[ancestors.length-1].branchset.push(subtree);
          tree = subtree;
          break;
        case ')': // optional name next
          tree = ancestors.pop();
          break;
        case ':': // optional length next
          break;
        default:
          var x = tokens[i-1];
          if (x == ')' || x == '(' || x == ',') {
            tree.name = token;
          } else if (x == ':') {
            tree.length = parseFloat(token);
          }
      }
    }
    return tree;
  };
})(
    // exports will be set in any commonjs platform; use it if it's available
    typeof exports !== "undefined" ?
    exports :
    // otherwise construct a name space.  outside the anonymous function,
    // "this" will always be "window" in a browser, even in strict mode.
    this.Newick = {}
);
