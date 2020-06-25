$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  console.log('Stats TBL Page as changed');
  mainPartnLoaderInCaseOfChange();
})

function mainPartnLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'parmstat-gr'){
    runStatusStat();
  }
  else{
    //do nothing
  }
}


/* JSChart */
function runStatusStat(){
  //Corlor
  var backgroundColorRef = [
      '#E2CEFF',
      '#FFCECE',
      '#C7FFC7',
      '#FFF9C7',
      '#F1F1F1',
      '#F8CEFF',
      '#D6EDEE',
      '#FEE9C9',
      '#E2CEFF',
      '#FFCECE',
      '#C7FFC7',
      '#FFF9C7',
      '#F1F1F1',
      '#F8CEFF',
      '#D6EDEE',
      '#FEE9C9'
  ];
  var borderColorRef = [
      '#5700D5',
      '#A80000',
      '#079F00',
      '#D2BC00',
      '#505050',
      '#9300AD',
      '#009196',
      '#C87900',
      '#5700D5',
      '#A80000',
      '#079F00',
      '#D2BC00',
      '#505050',
      '#9300AD',
      '#009196',
      '#C87900'
  ];

  var listOfLabel = new Array();
  var listOfData = new Array();
  for(i=0; i<dataTagToJsonArray.length; i++){
    listOfLabel.push(dataTagToJsonArray[i].step);
    listOfData.push(dataTagToJsonArray[i].cnt_stat);
  }


  var ctx = document.getElementById('statStatCv');
  var myChart = new Chart(ctx, {
      type: 'bar',
      data: {
          labels: listOfLabel,
          datasets: [{
              label: 'Status des codes barres actuellement',
              data: listOfData,
              backgroundColor: backgroundColorRef,
              borderColor: borderColorRef,
              borderWidth: 1
          }]
      },
      options: {
          scales: {
              yAxes: [{
                  ticks: {
                      beginAtZero: true
                  }
              }]
          }
      }
  });
};
