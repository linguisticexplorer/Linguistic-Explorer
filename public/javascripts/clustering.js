function buildNewickNodes(node, callback) {
    var newickNodes = [];
    newickNodes.push(node);
    if (node.branchset) {
        for (var i=0; i < node.branchset.length; i++) {
            buildNewickNodes(node.branchset[i]);
        }
    }
}

function phylogram(newick){
  d3.phylogram.build('#tree', newick, {
        width: 1100,
        height:1100
    });
  downloadCanvas();
}

function radial_tree(newick){
  d3.phylogram.buildRadial('#tree', newick, {
        width: 1100
    });
  downloadCanvas();
}

var png_image;

function downloadCanvas(){
  if(!png_image){
    var html_svg = jQuery('#tree').prop("outerHTML")
      .replace('<div class="gallery" id="tree"> ', '')
      .replace('</div>', '');
    var c = document.getElementById('canvas');
    c.width = 1000;
    c.height = 800;
    canvg(c, html_svg);
    jQuery('#tree').hide();
    var canvas = document.getElementById('canvas');
    png_image = canvas.toDataURL("image/png");
  }
  d3.select('#download').attr("href", png_image);
}