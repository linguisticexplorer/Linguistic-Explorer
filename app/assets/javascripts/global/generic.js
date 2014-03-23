$(function() {

  $('ul.nav li.dropdown').hover(function() {
    $(this).find('.dropdown-menu').stop(true, true).fadeIn();
  }, function() {
    $(this).find('.dropdown-menu').stop(true, true).fadeOut();
  });

});
