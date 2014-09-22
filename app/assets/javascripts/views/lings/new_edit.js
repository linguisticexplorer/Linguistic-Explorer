(function(){

    // Init the Lings module here
    this.Terraling = this.Terraling || {};
    this.Terraling.Lings = this.Terraling.Lings || {};

    var lings = this.Terraling.Lings;

    lings.edit = lings['new'] = {
        init: setupEditPage
    };

    function setupEditPage(){
      loadMap();
    }

    function loadMap(){
      T.Visualization.Map.init('ling-map', {
        name: null,
        type: 'ling'
      });

      $('.overlay').show();
    }

})();