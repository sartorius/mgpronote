$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  //console.log('Stats TBL Page as changed');
  mainPartnLoaderInCaseOfChange();
})

function mainPartnLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'parmstat-gr'){
    runStatusStat();
  }
  else if($('#mg-graph-identifier').text() == 'wakeupcertif-gr'){
    console.log('You have been wakeupcertif');
    demo1();
    demo2();
    demo3();
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
  if (ctx != null) {
      // Exists.
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
  }


  let nsp1 = '<i class="wght-title-stat">'
  let nsp2 = '</i>&nbsp;<i class="wght-title-stp">kg</i><br>'
  let weightToDisplay = ''

  // Weight 6 Management
  for(i=0; i<dataTagAllWeightsToJsonArray.length; i++){
    weightToDisplay = weightToDisplay + '<i class="wght-title-stp">' + dataTagAllWeightsToJsonArray[i].step + '</i>' + ':&nbsp;&nbsp;' + nsp1 + dataTagAllWeightsToJsonArray[i].sum_weight + nsp2
  }

  if ($("#weight-blc-stat") != null ) {
    // Exists.
    $("#weight-blc-stat").html(weightToDisplay);
  }


};

function demo1(){
    let ctxDem = document.getElementById('myChart');
    let chart = new Chart(ctxDem, {
        // The type of chart we want to create
        type: 'line',

        // The data for our dataset
        data: {
            labels: ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90'],
            datasets: [{
                label: 'Notes de la promotion',
                backgroundColor: "#8e5ea2",
                borderColor: "#8e5ea2",
                data: [0, 0, 0, 0, 5, 15, 60, 10, 7, 3]
            }]
        },

        // Configuration options go here
        options: {}
    });
};

function demo2(){
  var ctx = document.getElementById('myChart2');
  var myChart = new Chart(ctx, {
      type: 'bar',
      data: {
          labels: ['Marketing', 'Anglais', 'Français', 'Fondamentaux', 'Vente', 'Comptabilité'],
          datasets: [{
              label: 'Moyenne',
              data: [17, 19, 13, 15, 12, 13],
              backgroundColor: [
                  'rgba(255, 99, 132, 0.2)',
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(255, 206, 86, 0.2)',
                  'rgba(75, 192, 192, 0.2)',
                  'rgba(153, 102, 255, 0.2)',
                  'rgba(255, 159, 64, 0.2)'
              ],
              borderColor: [
                  'rgba(255, 99, 132, 1)',
                  'rgba(54, 162, 235, 1)',
                  'rgba(255, 206, 86, 1)',
                  'rgba(75, 192, 192, 1)',
                  'rgba(153, 102, 255, 1)',
                  'rgba(255, 159, 64, 1)'
              ],
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

function demo3(){
  var ctx = document.getElementById('myChart3');

  new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ["Calcul", "Logique", "Anglais", "Culture"],
        datasets: [
          {
            label: "capacité",
            backgroundColor: ["#3e95cd", "#8e5ea2","#3cba9f", "#c45850"],
            data: [2478,5267,734,433]
          }
        ]
      },
      options: {
      }
  });
};
