// var bindTypeahead = function(id) {
//   var dict, items = [];
//   $.get(location.href.replace(/[\?#]+[^\?]*$/, "") + "groups/" + id + "/dict", function(data) {
//     dict = data;
//     $.each(dict, function(key, val) {
//       items.push(key);
//     });
//   }).done( function() {
//     $('#auto_' + id).typeahead({
//       source: items,
//       updater:function (item){
//         window.location.href = '/groups/' + id + '/lings/' + dict[item];
//       }
//     });
//     $('#auto_' + id).attr("placeholder", "Type the name of a language...").removeAttr('disabled');
//   });

// };

$(function () {
  // Carousel
  $('.carousel').carousel({
    interval: 4000
  });

  // Typeahead
  // $("lings_autocomplete").typeahead();

  // bindTypeahead($('#search-tabs ul li.active a').data('bind',true).data('id'));
});
