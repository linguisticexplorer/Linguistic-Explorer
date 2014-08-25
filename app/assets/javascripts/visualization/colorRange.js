(function(){
	// Init the module here
  this.Terraling = this.Terraling || {};

  var colorRange = this.Terraling.ColorRange = {};

  colorRange.init = createRange;

  var valuesScores = {};
  var columns = [];

  function createRange(type, rows){
    mapColumns(type, rows);
    mapValues(type, rows);
    return valuesScores;
  }

  function mapColoumns(type, rows){
    var mappers = {
      'compare': mapLingColumns
    };
    var mapper = mappers[type] || mappers.sureness;

    mapper(rows);
  }

  function mapLingColumns(rows){
    if(rows.length){
      for( var i=0; i<rows[0].lings.length; i++){
        columns.push(rows[0].lings[i].ling.name);
      }
    }
  }

  function mapValues(type, rows){
    var i;

    var valuesDict = {};
    var vCount = 0;

    var mappers = {
      'compare': mapCompare
    };

    var mapper = mappers[type] || mappers.sureness;

    // find all the values
    for( i=0; i<rows.length; i++){
      var row = rows[i];
      vCount = mapper(row, valuesDict, vCount);
    }

    // because we have to map al the values in a fixed range of 2
    // let's calculate how much is the gap between 2 consecutive values
    // in the range
    var vShift = 2 / vCount;

    var fixedValues = {
      'Yes': 1,
      ' ': 0,
      'No': -1
    };

    var reversedMap = {
      '1': 'Yes',
      '0': ' ',
      '-1':  'No'
    };
    // here we have all the values mapped:
    // now map them in a range
    for( i in valuesDict ){
      if( valuesDict.hasOwnProperty(i) ){

        // if it's a fixed value, skip it
        if(!isFinite(fixedValues[i])){
          var newValue = 1 - vShift;
          while(reversedMap[newValue] && newValue > -1){
            newValue -= vShift;
          }
          reversedMap[newValue] = i;
        }
      }
    }

    // now reverse again the map
    for( i in reversedMap ){
      if( reversedMap.hasOwnProperty(i)){

        valueScores[reversedMap[i]] = i;
      }
    }
  }

  function isCommonProperty(row){
    return row.child.length !== row.lings.length;
  }

  function createCommonRow(index, entry, lings, property){
    var row = [];

    for( var j=0; j<lings.length; j++){
      var value = entry[0].lings_property.value;
      row.push({
        score: + valueScores[value],
        value: value,
        prop: property.name,
        x: j,
        y: index
      });
    }

    return row;
  }

  function createDiffRow(index, entry, lings, property){

    var lingDict = {};
    var row = [];
    var j, position;

    for( var i=0; i<lings.length; i++){
      lingDict[columns[i].ling.id] = i;
    }

    // put in the array all the values we have
    for( j = 0; j<entry.length; j++){
      if(entry[j]){
        position = lingDict[entry[j].lings_property.ling_id];
        row[position] = {
          score: + valueScores[entry[j].lings_property.value] ,
          value: entry[j].lings_property.value,
          prop: property.name,
          x: position,
          y: index
        };
      }
    }
    
    // now fill the gaps
    for( j = 0; j<entry.length; j++){
      if(!row[j]){
        row[j] = {
          score: 0 ,
          value: ' ',
          prop: property.name,
          x: j,
          y: index
        };
      }
    }

    return row;
  }

  function mapCompare(row, dict, counter){
    if(isCommonProperty(row)){
      if(!dict[row.parent[0].lings_property.value]){
        dict[row.parent[0].lings_property.value] = 1;
        counter++;
      }
    } else {
      for(var j=0; j<row.child.length; j++){
        var value = row.child[j] ? row.child[j].lings_property.value : ' ';
        if(!dict[value]){
          dict[value] = 1;
          counter++;
        }
      }
    }
    return counter;
  }

})();