jQuery.noConflict();
jQuery(function() {
    var lings = [
        [-1, -1, 1, -1, -1, -1, 0, 0],
        [-1, -1, 1, -1, -1, -1, -1, -1],
        [1, 0, 0, 0, -1, 0, -1, -1],
        [1, -1, -1, -1, -1, -1, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, -1]
    ];

    var tree = clusterfck.hcluster(lings, "manhattan");
    console.log("Similarity Tree => \n" + JSON.stringify(tree));

    var data_example_dendrogram = {
        "name": "flare",
        "children": [
            {
                "name": "analytics",
                "children": [
                    {
                        "name": "cluster",
                        "children": [
                            {"name": "AgglomerativeCluster", "size": 3938},
                            {"name": "CommunityStructure", "size": 3812},
                            {"name": "HierarchicalCluster", "size": 6714},
                            {"name": "MergeEdge", "size": 743}
                        ]
                    },
                    {
                        "name": "graph",
                        "children": [
                            {"name": "BetweennessCentrality", "size": 3534},
                            {"name": "LinkDistance", "size": 5731},
                            {"name": "MaxFlowMinCut", "size": 7840},
                            {"name": "ShortestPaths", "size": 5914},
                            {"name": "SpanningTree", "size": 3416}
                        ]
                    },
                    {
                        "name": "optimization",
                        "children": [
                            {"name": "AspectRatioBanker", "size": 7074}
                        ]
                    }
                ]
            },
            {
                "name": "animate",
                "children": [
                    {"name": "Easing", "size": 17010},
                    {"name": "FunctionSequence", "size": 5842},
                    {
                        "name": "interpolate",
                        "children": [
                            {"name": "ArrayInterpolator", "size": 1983},
                            {"name": "ColorInterpolator", "size": 2047},
                            {"name": "DateInterpolator", "size": 1375},
                            {"name": "Interpolator", "size": 8746},
                            {"name": "MatrixInterpolator", "size": 2202},
                            {"name": "NumberInterpolator", "size": 1382},
                            {"name": "ObjectInterpolator", "size": 1629},
                            {"name": "PointInterpolator", "size": 1675},
                            {"name": "RectangleInterpolator", "size": 2042}
                        ]
                    },
                    {"name": "ISchedulable", "size": 1041},
                    {"name": "Parallel", "size": 5176},
                    {"name": "Pause", "size": 449},
                    {"name": "Scheduler", "size": 5593},
                    {"name": "Sequence", "size": 5534},
                    {"name": "Transition", "size": 9201},
                    {"name": "Transitioner", "size": 19975},
                    {"name": "TransitionEvent", "size": 1116},
                    {"name": "Tween", "size": 6006}
                ]
            },
            {
                "name": "data",
                "children": [
                    {
                        "name": "converters",
                        "children": [
                            {"name": "Converters", "size": 721},
                            {"name": "DelimitedTextConverter", "size": 4294},
                            {"name": "GraphMLConverter", "size": 9800},
                            {"name": "IDataConverter", "size": 1314},
                            {"name": "JSONConverter", "size": 2220}
                        ]
                    },
                    {"name": "DataField", "size": 1759},
                    {"name": "DataSchema", "size": 2165},
                    {"name": "DataSet", "size": 586},
                    {"name": "DataSource", "size": 3331},
                    {"name": "DataTable", "size": 772},
                    {"name": "DataUtil", "size": 3322}
                ]
            },
            {
                "name": "display",
                "children": [
                    {"name": "DirtySprite", "size": 8833},
                    {"name": "LineSprite", "size": 1732},
                    {"name": "RectSprite", "size": 3623},
                    {"name": "TextSprite", "size": 10066}
                ]
            },
            {
                "name": "flex",
                "children": [
                    {"name": "FlareVis", "size": 4116}
                ]
            },
            {
                "name": "physics",
                "children": [
                    {"name": "DragForce", "size": 1082},
                    {"name": "GravityForce", "size": 1336},
                    {"name": "IForce", "size": 319},
                    {"name": "NBodyForce", "size": 10498},
                    {"name": "Particle", "size": 2822},
                    {"name": "Simulation", "size": 9983},
                    {"name": "Spring", "size": 2213},
                    {"name": "SpringForce", "size": 1681}
                ]
            },
            {
                "name": "query",
                "children": [
                    {"name": "AggregateExpression", "size": 1616},
                    {"name": "And", "size": 1027},
                    {"name": "Arithmetic", "size": 3891},
                    {"name": "Average", "size": 891},
                    {"name": "BinaryExpression", "size": 2893},
                    {"name": "Comparison", "size": 5103},
                    {"name": "CompositeExpression", "size": 3677},
                    {"name": "Count", "size": 781},
                    {"name": "DateUtil", "size": 4141},
                    {"name": "Distinct", "size": 933},
                    {"name": "Expression", "size": 5130},
                    {"name": "ExpressionIterator", "size": 3617},
                    {"name": "Fn", "size": 3240},
                    {"name": "If", "size": 2732},
                    {"name": "IsA", "size": 2039},
                    {"name": "Literal", "size": 1214},
                    {"name": "Match", "size": 3748},
                    {"name": "Maximum", "size": 843},
                    {
                        "name": "methods",
                        "children": [
                            {"name": "add", "size": 593},
                            {"name": "and", "size": 330},
                            {"name": "average", "size": 287},
                            {"name": "count", "size": 277},
                            {"name": "distinct", "size": 292},
                            {"name": "div", "size": 595},
                            {"name": "eq", "size": 594},
                            {"name": "fn", "size": 460},
                            {"name": "gt", "size": 603},
                            {"name": "gte", "size": 625},
                            {"name": "iff", "size": 748},
                            {"name": "isa", "size": 461},
                            {"name": "lt", "size": 597},
                            {"name": "lte", "size": 619},
                            {"name": "max", "size": 283},
                            {"name": "min", "size": 283},
                            {"name": "mod", "size": 591},
                            {"name": "mul", "size": 603},
                            {"name": "neq", "size": 599},
                            {"name": "not", "size": 386},
                            {"name": "or", "size": 323},
                            {"name": "orderby", "size": 307},
                            {"name": "range", "size": 772},
                            {"name": "select", "size": 296},
                            {"name": "stddev", "size": 363},
                            {"name": "sub", "size": 600},
                            {"name": "sum", "size": 280},
                            {"name": "update", "size": 307},
                            {"name": "variance", "size": 335},
                            {"name": "where", "size": 299},
                            {"name": "xor", "size": 354},
                            {"name": "_", "size": 264}
                        ]
                    },
                    {"name": "Minimum", "size": 843},
                    {"name": "Not", "size": 1554},
                    {"name": "Or", "size": 970},
                    {"name": "Query", "size": 13896},
                    {"name": "Range", "size": 1594},
                    {"name": "StringUtil", "size": 4130},
                    {"name": "Sum", "size": 791},
                    {"name": "Variable", "size": 1124},
                    {"name": "Variance", "size": 1876},
                    {"name": "Xor", "size": 1101}
                ]
            },
            {
                "name": "scale",
                "children": [
                    {"name": "IScaleMap", "size": 2105},
                    {"name": "LinearScale", "size": 1316},
                    {"name": "LogScale", "size": 3151},
                    {"name": "OrdinalScale", "size": 3770},
                    {"name": "QuantileScale", "size": 2435},
                    {"name": "QuantitativeScale", "size": 4839},
                    {"name": "RootScale", "size": 1756},
                    {"name": "Scale", "size": 4268},
                    {"name": "ScaleType", "size": 1821},
                    {"name": "TimeScale", "size": 5833}
                ]
            },
            {
                "name": "util",
                "children": [
                    {"name": "Arrays", "size": 8258},
                    {"name": "Colors", "size": 10001},
                    {"name": "Dates", "size": 8217},
                    {"name": "Displays", "size": 12555},
                    {"name": "Filter", "size": 2324},
                    {"name": "Geometry", "size": 10993},
                    {
                        "name": "heap",
                        "children": [
                            {"name": "FibonacciHeap", "size": 9354},
                            {"name": "HeapNode", "size": 1233}
                        ]
                    },
                    {"name": "IEvaluable", "size": 335},
                    {"name": "IPredicate", "size": 383},
                    {"name": "IValueProxy", "size": 874},
                    {
                        "name": "math",
                        "children": [
                            {"name": "DenseMatrix", "size": 3165},
                            {"name": "IMatrix", "size": 2815},
                            {"name": "SparseMatrix", "size": 3366}
                        ]
                    },
                    {"name": "Maths", "size": 17705},
                    {"name": "Orientation", "size": 1486},
                    {
                        "name": "palette",
                        "children": [
                            {"name": "ColorPalette", "size": 6367},
                            {"name": "Palette", "size": 1229},
                            {"name": "ShapePalette", "size": 2059},
                            {"name": "SizePalette", "size": 2291}
                        ]
                    },
                    {"name": "Property", "size": 5559},
                    {"name": "Shapes", "size": 19118},
                    {"name": "Sort", "size": 6887},
                    {"name": "Stats", "size": 6557},
                    {"name": "Strings", "size": 22026}
                ]
            },
            {
                "name": "vis",
                "children": [
                    {
                        "name": "axis",
                        "children": [
                            {"name": "Axes", "size": 1302},
                            {"name": "Axis", "size": 24593},
                            {"name": "AxisGridLine", "size": 652},
                            {"name": "AxisLabel", "size": 636},
                            {"name": "CartesianAxes", "size": 6703}
                        ]
                    },
                    {
                        "name": "controls",
                        "children": [
                            {"name": "AnchorControl", "size": 2138},
                            {"name": "ClickControl", "size": 3824},
                            {"name": "Control", "size": 1353},
                            {"name": "ControlList", "size": 4665},
                            {"name": "DragControl", "size": 2649},
                            {"name": "ExpandControl", "size": 2832},
                            {"name": "HoverControl", "size": 4896},
                            {"name": "IControl", "size": 763},
                            {"name": "PanZoomControl", "size": 5222},
                            {"name": "SelectionControl", "size": 7862},
                            {"name": "TooltipControl", "size": 8435}
                        ]
                    },
                    {
                        "name": "data",
                        "children": [
                            {"name": "Data", "size": 20544},
                            {"name": "DataList", "size": 19788},
                            {"name": "DataSprite", "size": 10349},
                            {"name": "EdgeSprite", "size": 3301},
                            {"name": "NodeSprite", "size": 19382},
                            {
                                "name": "render",
                                "children": [
                                    {"name": "ArrowType", "size": 698},
                                    {"name": "EdgeRenderer", "size": 5569},
                                    {"name": "IRenderer", "size": 353},
                                    {"name": "ShapeRenderer", "size": 2247}
                                ]
                            },
                            {"name": "ScaleBinding", "size": 11275},
                            {"name": "Tree", "size": 7147},
                            {"name": "TreeBuilder", "size": 9930}
                        ]
                    },
                    {
                        "name": "events",
                        "children": [
                            {"name": "DataEvent", "size": 2313},
                            {"name": "SelectionEvent", "size": 1880},
                            {"name": "TooltipEvent", "size": 1701},
                            {"name": "VisualizationEvent", "size": 1117}
                        ]
                    },
                    {
                        "name": "legend",
                        "children": [
                            {"name": "Legend", "size": 20859},
                            {"name": "LegendItem", "size": 4614},
                            {"name": "LegendRange", "size": 10530}
                        ]
                    },
                    {
                        "name": "operator",
                        "children": [
                            {
                                "name": "distortion",
                                "children": [
                                    {"name": "BifocalDistortion", "size": 4461},
                                    {"name": "Distortion", "size": 6314},
                                    {"name": "FisheyeDistortion", "size": 3444}
                                ]
                            },
                            {
                                "name": "encoder",
                                "children": [
                                    {"name": "ColorEncoder", "size": 3179},
                                    {"name": "Encoder", "size": 4060},
                                    {"name": "PropertyEncoder", "size": 4138},
                                    {"name": "ShapeEncoder", "size": 1690},
                                    {"name": "SizeEncoder", "size": 1830}
                                ]
                            },
                            {
                                "name": "filter",
                                "children": [
                                    {"name": "FisheyeTreeFilter", "size": 5219},
                                    {"name": "GraphDistanceFilter", "size": 3165},
                                    {"name": "VisibilityFilter", "size": 3509}
                                ]
                            },
                            {"name": "IOperator", "size": 1286},
                            {
                                "name": "label",
                                "children": [
                                    {"name": "Labeler", "size": 9956},
                                    {"name": "RadialLabeler", "size": 3899},
                                    {"name": "StackedAreaLabeler", "size": 3202}
                                ]
                            },
                            {
                                "name": "layout",
                                "children": [
                                    {"name": "AxisLayout", "size": 6725},
                                    {"name": "BundledEdgeRouter", "size": 3727},
                                    {"name": "CircleLayout", "size": 9317},
                                    {"name": "CirclePackingLayout", "size": 12003},
                                    {"name": "DendrogramLayout", "size": 4853},
                                    {"name": "ForceDirectedLayout", "size": 8411},
                                    {"name": "IcicleTreeLayout", "size": 4864},
                                    {"name": "IndentedTreeLayout", "size": 3174},
                                    {"name": "Layout", "size": 7881},
                                    {"name": "NodeLinkTreeLayout", "size": 12870},
                                    {"name": "PieLayout", "size": 2728},
                                    {"name": "RadialTreeLayout", "size": 12348},
                                    {"name": "RandomLayout", "size": 870},
                                    {"name": "StackedAreaLayout", "size": 9121},
                                    {"name": "TreeMapLayout", "size": 9191}
                                ]
                            },
                            {"name": "Operator", "size": 2490},
                            {"name": "OperatorList", "size": 5248},
                            {"name": "OperatorSequence", "size": 4190},
                            {"name": "OperatorSwitch", "size": 2581},
                            {"name": "SortOperator", "size": 2023}
                        ]
                    },
                    {"name": "Visualization", "size": 16540}
                ]
            }
        ]
    };

    var lings_newick_format = "((American Sign Language:0.5, Ancient Greek:0.5):4,(Aymara:0.5, (Bajau:0.5, Bambara:0.5):4):3):2;";

    var newick_stuff = "(((Crotalus_oreganus_oreganus_cytochrome_b:0.00800,Crotalus_horridus_cytochrome_b:0.05866):0.04732,(Thamnophis_elegans_terrestris_cytochrome_b:0.00366,Thamnophis_atratus_cytochrome_b:0.00172):0.06255):0.00555,(Pituophis_catenifer_vertebralis_cytochrome_b:0.00552,Lampropeltis_getula_cytochrome_b:0.02035):0.05762,((Diadophis_punctatus_cytochrome_b:0.06486,Contia_tenuis_cytochrome_b:0.05342):0.01037,Hypsiglena_torquata_cytochrome_b:0.05346):0.00779);"

    var newick = Newick.parse(lings_newick_format)
    var newickNodes = []
    function buildNewickNodes(node, callback) {
        newickNodes.push(node)
        if (node.branchset) {
            for (var i=0; i < node.branchset.length; i++) {
                buildNewickNodes(node.branchset[i])
            }
        }
    }
    buildNewickNodes(newick)

    console.log("Newick Format Tree => \n" + JSON.stringify(newick));
   d3.phylogram.build('#chart', newick, {
        width: 900,
        height: 1200,
        skipLengthLabels: true
    });

    d3.select("#download_plot")
    .on("click", writeDownloadLink);

function writeDownloadLink(){
    var html = d3.select("svg")
        .attr("title", "test2")
        .attr("version", 1.1)
        .attr("xmlns", "http://www.w3.org/2000/svg")
        .node().parentNode.innerHTML;

    d3.select("body").append("div")
        .attr("id", "download")
        .style("top", event.clientY+20+"px")
        .style("left", event.clientX+"px")
        .html("Right-click on this preview and choose Save as<br />Left-Click to dismiss<br />")
        .append("img")
        .attr("src", "data:image/svg+xml;base64,"+ btoa(html));

    d3.select("#download")
        .on("click", function(){
            if(event.button == 0){
                d3.select(this).transition()
                    .style("opacity", 0)
                    .remove();
            }
        })
        .transition()
        .duration(500)
        .style("opacity", 1);
};

});

function getBase64Image(img) {
    // Create an empty canvas element
    var canvas = document.createElement("canvas");
    canvas.width = img.width;
    canvas.height = img.height;

    // Copy the image contents to the canvas
    var ctx = canvas.getContext("2d");
    ctx.drawImage(img, 0, 0);

    // Get the data-URL formatted image
    // Firefox supports PNG and JPEG. You could check img.src to
    // guess the original format, but be aware the using "image/jpg"
    // will re-encode the image.
    var dataURL = canvas.toDataURL("image/png");

    return dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
}