$(function() {
  var dict_lang, items_lang = [],
      dict_prop, items_prop = [],
      base_url = location.href.replace(/(groups\/[0-9]+\/).*/, "$1"),
      auto_ling = $("#auto_ling"), auto_prop = $("#auto_prop"),
      isLoading = false;

  var searchLp = function() {
    if (!isLoading && auto_prop.val().length > 0 &&
          auto_ling.val().length > 0) {
      isLoading = true;
      ling_name = auto_ling.val();
      prop_name = auto_prop.val();
      console.log("ling", ling_name);
      console.log("prop", prop_name);
      var img = "<img src='/images/loader.gif' class='loading'/>";
      $("#lp-status").html("Loading..." + img);
    }
  };
      
  if (!auto_ling.hasClass("locked")) {
      $.get(base_url + "lings/dict" , function(data) {
        dict_lang = data;
        $.each(dict_lang, function(key, val) {
          items_lang.push(key);
        });    
      }).done( function() {
          auto_ling.typeahead({
            source: items_lang
          });
          auto_ling.attr("placeholder", "Start typing to search through properties").removeAttr('disabled');
      });
    }
   
    if (!auto_prop.hasClass("locked")) {
      $.get(base_url + "properties/dict" , function(data) {
        dict_prop = data;
        $.each(dict_prop, function(key, val) {
          items_prop.push(key);
        });    
      }).done( function() {
          auto_prop.typeahead({
            source: items_prop,
            updater: function(val) {
              setTimeout(function() {
               auto_prop.val(val); 
              }, 10);
              if (auto_prop.val().length > 0) {
                searchLp();
              }
            }
          });
          auto_prop.attr("placeholder", "Start typing to search through properties").removeAttr('disabled');
      });
    }
    
    auto_prop.blur(function(e) {
      if (auto_prop.val().length > 0) {
        searchLp();
      }
    });

    auto_ling.blur(function(e) {
      if (auto_prop.val().length > 0) {
        searchLp();   
      }
    });

    auto_prop.keypress(function(e) {
      if (e.which == 13) {
        e.preventDefault();
        searchLp();
      }
    });

    auto_ling.keypress(function(e) {
      if (e.which == 13) {
        e.preventDefault();
        searchLp();
      }
    });

});
