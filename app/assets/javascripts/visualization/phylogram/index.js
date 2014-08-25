(function(){
	// Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Visualization = this.Terraling.Visualization || {};

  var phylogram = this.Terraling.Visualization.Phylogram = {};

  phylogram.init = initPhylogram;

  function initPhylogram(id, data, options){
    id = '#' + id;

    // show a spinning wheel while loading
    showSpinningWheel(id);

    //TODO: Refactor this stuff
    if(Modernizr.svg){

      // parse the data
      data = Newick.parse(data);

      // process the data
      buildNewickNodes(data);

      var constructor = options.radial ? 'buildRadial' : 'build';

      d3.phylogram[constructor](id, data, {
          width:  options.width,
          height: options.width
      });

    } else {

      $(id).append(HoganTemplates['unsupported'].render());

    }

    $('#waiting').fadeOut();

  }

  function buildNewickNodes(node) {
    var newickNodes = [];
    newickNodes.push(node);
    if (node.branchset) {
      for (var i=0; i < node.branchset.length; i++) {
          buildNewickNodes(node.branchset[i]);
      }
    }
  }

  function showSpinningWheel(id){
    if($('#waiting').length){
      $('#waiting').fadeIn();
    } else {
      var img = HoganTemplates['waiting'].render();
      $(id).html(img);
    }
  }

})();