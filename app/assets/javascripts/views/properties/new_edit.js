(function(){

	// Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Properties = this.Terraling.Properties || {};

  var properties = this.Terraling.Properties;

  properties['new'] = properties.edit = {
    init: initTinyMCE
  };

  function initTinyMCE(){
    $.getScript('//tinymce.cachefly.net/4.0/tinymce.min.js').done( function () {
      tinymce.init({
        selector:'#desc',
        plugins: 'table'
      });
    });
  }

})();