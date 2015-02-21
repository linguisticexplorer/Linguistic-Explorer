(function(){
	// Init the module here
  this.Terraling = this.Terraling || {};

  this.Terraling.Visualization = this.Terraling.Visualization || {};

  var heatmap = this.Terraling.Visualization.HeatMap = {};

  heatmap.init = createVisualization;

  function createVisualization(id, data, options){
    // preprocess the data to get the color range
    var colors = T.Visualization.ColorRange(data.type, data);

    // now preprocess the data
    
    // sort the data by name
    // localeCompare is a native String function to compare two strings
    data.sort(function (a, b){
      return (a.name || '').localCompare( b.name || '');
    });

    // next: create the heatmap
    createHeatmap(id, data, colors, options);
  }

  function createHeatmap(id, data, colors, options){

    var svg = d3
    // create a svg element to start to draw the heatmap
      .select(id).selectAll("svg")
    // put the data in it
      .data(data).enter()
    // append the svg element
      .append('svg').attr('class', 'heatmap')
    // set the size
      .attr('width', options.width)
      .attr('height', options.height)
    // append the starting point of the svg elements
      .append('g');

    // object to map id => position
    var dataDict = {};
    for( var i=0; i<data.length; i++){
      dataDict[data[i].id] = i;
    }

    function getX(datum){
      return dataDict[datum.id] % options.itemsPerRow;
    }

    function getY(datum){
      return Math.floor(dataDict[datum.id] / options.itemsPerRow);
    }

    function getName(datum){
      return datum.name;
    }
    
    // this is a cell "template"
    var cell = svg
    // select all the cells
      .selectAll('.sureness_cell')
    // push the data in
      .data(data).enter()
    // start to create the cell
      .append('rect').attr('class', 'sureness_cell')
    // set the size
      .attr('width' , options.cellSize)
      .attr('height', options.cellSize)
    // place the cell in the right place
      .attr('x', getX).attr('y', getY)
    // setup some text... just in case
      .append('title').text(getName);


    // bind actions to the cell
    // on hover show a tooltip with Value
  }

  var data,
      lings = [],
      props = [],
      valueScores = {};

  function mapLingColumns(rows){
    if(rows.length){
      for( var i=0; i<rows[0].lings.length; i++){
        lings.push(rows[0].lings[i].ling.name);
      }
    }
  }
  
  // do nothing for the moment
  function mapPropRows(row){

  }

  function getURLParameter(name) {
    return decodeURI(
        (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
    );
  }

  function replaceURLParameter(name, value){
    var URL = location.search;
    if(getURLParameter(name) !== 'null'){
      URL = URL.replace(/page=(.+)/, 'page='+value);
    } else {
      URL += '&page='+value;
    }
    return URL;
  }

  function processJSON(rows){
    rows = rows.result;

    mapLingColumns(rows);
    mapPropRows(rows);
    
    mapValues(rows);

    data = [];
    for( var i=0; i<rows.length; i++){
      var entry = rows[i];
      if(isCommonProperty(entry)){
        data[i] = createCommonRow(i, entry.parent, entry.lings, entry.prop);
      } else {
        data[i] = createDiffRow(i, entry.child, entry.lings, entry.prop);
      }
    }

    createHeatmap();
  }

  function createHeatmap(){
    $('#visualize-body').empty().css('height', (5 * data.length + 105)+"px");

    var fixed_width = 580;
    //height of each row in the heatmap
    var h = 25;
    //width of each column in the heatmap
    var w = fixed_width / data[0].length;

    //attach a SVG element to the modal's body
    var svg = d3.select("#visualize-body")
       .append("svg")
       .attr("width", (w * data[0].length) + 100)
       .attr("height", (h * data.length + 100))
       .style('position','absolute')
       .style('top',0)
       .style('left',0);

    //define a color scale using the min and max expression values
    var colorScale = d3.scale.linear()
      .domain([-1, 0, +1])
      .range(["red", "white", "green"]);

    //generate heatmap rows
    var heatmapRow = svg.selectAll(".heatmap")
       .data(data)
       .enter().append("g");

    //generate heatmap columns
    var heatmapRects = heatmapRow
       .selectAll(".rect")
       .data(function(d) {
          return d;
       }).enter().append("svg:rect")
       .attr('width',  w)
       .attr('height', h)
       .attr('x', function(d) {
          return (d.x * w) + 100;
       })
       .attr('y', function(d) {
          return (d.y * h) + 50;
       })
       .attr('rx', 7)
       .attr('ry', 2)
       .attr('stroke', '#E6E6E6')
       .attr('stroke-width', 2)
       .style('fill', function(d) {
          return colorScale(d.score);
       });

    //label columns
    var columnLabel = svg.selectAll(".colLabel")
      .data(lings)
      .enter().append('svg:text')
      .attr('x', function(d,i) {
        return ((i + 0.5) * w) + 100;
      })
      .attr('y', 30)
      .attr('class','label')
      .style('text-anchor','middle')
      // .attr('transform', 'translate(-' + 100 + ',' + 50 + ') rotate(-90)')
      .text(function(d) {
        return d;
      });

    var rowLabel = svg.selectAll('.rowLabel')
      .data(Array(data.length)).
      enter().append('svg:text')
      .attr('x', 15)
      .attr('y', function(d, i){
        return (i * h) + 50;
      })
      .attr('class', 'label')
      // .style('text-anchor','middle')
      .text(function(d, i){
        if(i%25 === 1){
          return 'PAGE '+(Math.floor(i/25) + 1);
        }
      });

    //expression value label
    var lock = true;
    var legend = d3.select("#visualize-body")
       .append('div')
       .attr('class', 'well')
       .style('height',23)
       .style('max-width','250px')
       .style('word-wrap','break-word')
       .style('position','absolute')
       .style('background','#E6E6E6')
       // .style('opacity',0.9)
       .style('padding','10px')
       .style('display','none');

    function unlockLegend(){
      lock = !lock;
    }

    function showLegend(d, i){
      // d3.select(this)
      //   .selectAll("rect")
      //   .attr('stroke-width',2)
      //   .attr('stroke','black');

      var xy = d3.mouse(d3.select(this)[0][0]);

      var cellNumber = Math.floor((xy[0] - 100) / w);

      var page = (Math.floor(i/25) + 1);
      var pageURL = replaceURLParameter('page', page);
      
      var output = '<table class="table table-condensed">';
      
      output += '<thead><tr><th>'+d[0].prop+'</th><th>&nbsp;</th></tr></thead>';
      output += '<tbody>';

      for (var j = 0; j < d.length; j ++ ) {
        var value = d[j].value === ' ' ? '"---"' : d[j].value;
        
        output += '<tr '+ (cellNumber === j ? 'class="warning">' : '>');
        output += '<th>'+lings[j] + '</th><th>' + value+'</th></tr>';

      }
      output += '</tbody></table>'
      output += '<br/><a href='+pageURL+' class="pull-right">' + 'Go to page ' + page + '</a>';
      

      legend
         .style('top', (xy[1] + 15)+'px')
         .style('left', (xy[0] + 5)+'px')
         .style('display','block')
         .html(output);
    }

    function hideLegend(d, i){
      // d3.select(this)
      //   .selectAll("rect")
      //   .attr('stroke-width',2)
      //   .attr('stroke','#E6E6E6');

      if(!lock){
        legend.style('display','none');
      }
    }

    //heatmap mouse events
    heatmapRow
      .on('click'    , unlockLegend)
      .on('mouseover', showLegend)
      .on('mouseout' , hideLegend);
  }

})();