// Now load the module
(function(){

    // Init the Lings module here
    this.Terraling = this.Terraling || {};
    this.Terraling.Lings = this.Terraling.Lings || {};

    var lings = this.Terraling.Lings;

    lings.show = {
        init: setupAnalysis
    };
    
    // local variable containing the state of the page
    var ling = {};

    var resourceId = 'ling';

    function setupAnalysis(group, id){
        // Perhaps better names?
        ling.list      = [];
        ling.dict      = {};
        ling.group     = group || 0 ;
        ling.currentId = id    || '';

        // bind some buttons here
        bindAnalysis('#compare-lings', '&search[ling_set][0]=compare');
        bindAnalysis('#compare-tree' , '&search[advanced_set][clustering]=hamming');

        // init the typeahead
        setupTypeahead();

        $(window)
          .on('click', '.remove-lings', removeLanguages)
          .on('click', '.remove-ling' , removeLanguage);
    }

    // append some helper functions here
    function makeButton(){
        return '<a class="remove-lang" href="Remove"><i class="glyphicon-remove shift-down"></a>';
    }

    function hideList(){
        $('#languages-container').addClass('hidden');
        $('#analysis').removeClass('col-md-7').addClass('col-md-12');
        $('div#compare-buttons a').attr('disabled', 'disabled');
    }

    function buildLingsURL(){
        //TODO: refactor this stuff here!
        return '&search[lings][0][]=' + ($.map( $('#selected-lings li'), function (val, i) {
            return lings.dict[$.trim($(val).text())];
        })).join('&search[lings][0][]=');
    }

    // Just save static parameters in somewhere
    function staticParams(){
        return "utf8=✓&search[include][ling_0]=1&search[include][property_0]=1&search[include][value_0]=1"+
               "&search[include][example_0]=1&search[ling_keywords][0]=&search[property_keywords][1]="+
               "&search[property_set][1]=any&search[lings_property_set][1]=any&search[example_fields][0]=description"+
               "&search[example_keywords][0]=";
    }

    function searchQuery(params){
        params = params || '';
        return '/groups/' + T.currentGroup +
               '/searches/preview?'+ staticParams() +
               '&search[lings][0][]=' + ling.currentId +
               '&search[example_keywords][0]=' + params +
               buildLingsURL();
    }

    function bindAnalysis(id, url){
        $(window).on('click', id, function (e) {
            if (! $(this).attr("disabled")) {
                window.open(searchQuery(url));
            }
        });
    }

    // remove a language from the list
    function removeLanguage(){
        var item = $(this).parent();
        lings.list.push(item.text());
        item.remove();
        if ( !$('ul#selected-lings li').length ) {
            hideList();
        }
    }

    function removeLanguages() {
        $('#selected-lings li').each( function () {
            var item = $(this);
            lings.list.push(item.text());
            item.remove();
        });
        hideList();
    }

    function setupTypeahead(){

      T.Search.quickTemplate(
        resourceId,
        {type: 'ling', template: 'resource'},
        {nameResolver: nameResolver, onSelection: onLingSelected}
      );
        // dict = json;
        // $.each(dict, function(key, val) {
        //     if (val !== id) {
        //       lings.list.push(key);
        //     }
        // });

      //   $('#auto_compare').typeahead({
      //       source: lings.list,
      //       updater:function (item){
      //         $('#languages-container').removeClass('hidden');
      //         $('#analysis').removeClass('col-md-12').addClass('col-md-7');
      //         $('div#compare-buttons a').removeAttr("disabled");
      //         $('#selected-lings').append($('<li>').html(makeButton() + item));
      //         lings.list.splice(lings.list.indexOf(item),1);
      //   }
      // });
      // $('#auto_compare').attr("placeholder", "Start typing the name of the language").removeAttr('disabled');
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

        $('#selected-resources').append(resourceTemplate(ling));
      }

      updateResourceField();

      $('#'+resourceId+'-search-field').typeahead('val', '');

    }

// var items = [],
//     dict  = {},
// makeButton = function() {
// return '
// %a.remove-lang{:href => "/Remove"}
//   <i class=\'icon-remove shift-down\'>
// ';
// },
// hideList = function () {
// $('#languages-container').addClass('hidden1');
// $('#analysis').removeClass('span7').addClass('span12');
// $('div#compare-buttons a').attr('disabled', 'disabled');
// },
// langsParams = function() {
// return '&search[lings][0][]=' + ($.map( $('#selected-lings li'), function (val, i) { return dict[$.trim($(val).text())] })).join('&search[lings][0][]=');
// },
// searchQuery = function (param) {
// var param = (!param) ? "" : param;
// return '/groups/' + group + '/searches/preview?utf8=✓&search[include][ling_0]=1&search[include][property_0]=1&search[include][value_0]=1&search[include][example_0]=1&search[lings][0][]=' + id + langsParams() + '&search[ling_keywords][0]=&search[property_keywords][1]=&search[property_set][1]=any&search[lings_property_set][1]=any&search[example_fields][0]=description&search[example_keywords][0]=&search[javascript]=1' + param;
// };

// $(window).on('click', '.remove-lang', function (e) {
// items.push(($(this).parent().text()));
// $(this).parent().remove();
// if ( !$('ul#selected-lings li').length ) {
// hideList();
// }
// });

// $(window).on('click', '.remove-langs', function (e) {
// $('#selected-lings li').each( function () {
// items.push($(this).text());
// $(this).remove();
// });
// hideList();
// });

// $(window).on('click', '#compare-langs', function (e) {
// if (! $(this).attr("disabled")) {
// window.open(searchQuery('&search[ling_set][0]=compare'));
// }
// });

// $(window).on('click', '#compare-tree', function() {
// if (! $(this).attr("disabled")) {
// window.open(searchQuery('&search[advanced_set][clustering]=hamming'));
// }
// });

// $(window).on('click', '#compare-radial', function() {
// if (! $(this).attr("disabled")) {
// window.open(searchQuery('&search[advanced_set][clustering]=hamming_r'));
// }
// });
// $(window).on('click', '#map', function() {
// window.open('/groups/' + group + '/searches/geomapping?search[example_fields][0]=description&search[example_keywords][0]=&search[include][example_0]=1&search[include][ling_0]=1&search[include][property_0]=1&search[include][value_0]=1&search[javascript]=1&search[ling_keywords][0]=&search[lings][0][]=' + id + langsParams() + '&search[lings_property_set][1]=any&search[property_keywords][1]=&search[property_set][1]=any');
// });
// $(window).on('click', 'div.search-buttons a', function (e) {
//   e.preventDefault();
// });

    // $.get(ling.lingsURL) function(data) {

    // }).done( function() {
    //   });

})();
