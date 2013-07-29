var dict_lang, items_lang = [],
    dict_prop, items_prop = [],
    base_url = location.href.replace(/(groups\/[0-9]+\/).*/, "$1");
    
    $.get(base_url + "lings/dict" , function(data) {
      dict_lang = data;
      $.each(dict_lang, function(key, val) {
        items_lang.push(key);
      });    
    }).done( function() {
        $('#auto_ling').typeahead({
          source: items_lang
        });
        $('#auto_ling').attr("placeholder", "Start typing to search through properties").removeAttr('disabled');
    });
 
    $.get(base_url + "properties/dict" , function(data) {
      dict_prop = data;
      $.each(dict_prop, function(key, val) {
        items_prop.push(key);
      });    
    }).done( function() {
        $('#auto_prop').typeahead({
          source: items_prop
        });
        $('#auto_prop').attr("placeholder", "Start typing to search through properties").removeAttr('disabled');
    });
