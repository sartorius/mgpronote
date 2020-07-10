$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  //console.log('Stats TBL Page as changed');
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


  // Stat of status population
  let listOfLabelStat = new Array();
  let listOfDataStat = new Array();
  for(i=0; i<dataTagToJsonArray.length; i++){
    listOfLabelStat.push(dataTagToJsonArray[i].step.substring(0, STR_LENGTH_LG));
    listOfDataStat.push(dataTagToJsonArray[i].cnt_stat);
  }


  var ctx = document.getElementById('statStatCv');
  var myChart = new Chart(ctx, {
      type: 'bar',
      data: {
          labels: listOfLabelStat,
          datasets: [{
              label: 'Status des codes barres actuellement',
              data: listOfDataStat,
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

  // Stats bigger clients
  let listOfLabelClient = new Array();
  let listOfDataClient = new Array();

  for(i=0; i<dataTagClientToJsonArray.length; i++){
    listOfLabelClient.push(dataTagClientToJsonArray[i].name + ' ' + dataTagClientToJsonArray[i].firstname);
    listOfDataClient.push(dataTagClientToJsonArray[i].totalbc);
  }

  var ctxClient = document.getElementById('statClientCv');
  new Chart(ctxClient, {
      type: 'doughnut',
      data: {
        labels: listOfLabelClient,
        datasets: [
          {
            label: "Client",
            backgroundColor: backgroundColorRef,
            data: listOfDataClient
          }
        ]
      },
      options: {
      }
  });

  // Stat of all weight
  let listOfLabelAllWeights = new Array();
  let listOfDataAllWeights = new Array();
  for(i=0; i<dataTagAllWeightsToJsonArray.length; i++){
    listOfLabelAllWeights.push(dataTagAllWeightsToJsonArray[i].step);
    listOfDataAllWeights.push(dataTagAllWeightsToJsonArray[i].sum_weight);
  }


  var ctx = document.getElementById('statAllWeights');
  var myChart = new Chart(ctx, {
      type: 'bar',
      data: {
          labels: listOfLabelAllWeights,
          datasets: [{
              label: 'Poids par status',
              data: listOfDataAllWeights,
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

  let nsp1 = '<i class="wght-title-stat">'
  let nsp2 = '</i>&nbsp;<i class="wght-title-stp">kg</i><br>'
  let weightToDisplay = ''

  // Weight 6 Management
  for(i=0; i<dataTagAllWeightsToJsonArray.length; i++){
    weightToDisplay = weightToDisplay + '<i class="wght-title-stp">' + dataTagAllWeightsToJsonArray[i].step + '</i>' + ':&nbsp;&nbsp;' + nsp1 + dataTagAllWeightsToJsonArray[i].sum_weight + nsp2
  }
  $("#weight-blc-stat").html(weightToDisplay);


};
