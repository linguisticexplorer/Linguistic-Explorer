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
}

function radial_tree(newick){
    d3.phylogram.buildRadial('#tree', newick, {
        width: 1100
    });
}

//function create_download_link(){
//
//    var download_link = '<a href="#" id="download_plot">Download image</a>';
//    from_svg_to_png()
////    jQuery("#download").html(download_link);
//}

//function from_svg_to_png() {
//    Downloadify.create("tree", {
//        data: encode_as_img(),
//        onComplete: function(){
//            alert('Your File Has Been Saved!');
//        },
//        onCancel: function(){
//            alert('You have cancelled the saving of this file.');
//        },
//        onError: function(){
//            alert('You must put something in the File Contents or there will be nothing to save!');
//        },
//        filename: "data.svg",
//        swf: 'http://localhost:3000/media/downloadify.swf',
//        downloadImage: 'http://localhost:3000/images/download_tree.png',
//        width: 80, height: 80});
//}
//
//// Base64 provided by http://www.webtoolkit.info/
//function encode_as_img(){
//    // Add some critical information
//    jQuery("svg").attr({ version: '1.1' , xmlns:"http://www.w3.org/2000/svg"});
//
//    var svg = jQuery("#tree").html();
//    console.log("SVG: "+svg);
//    return Base64.encode(svg);
//}