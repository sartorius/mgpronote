$(document).ready(function() {
  // console.log('We are in MGFollowAPP JS2');
  //mainLoaderInCaseOfChange();
});

$(document).on('turbolinks:load', function() {

    // Handle specific page
    if($('#mg-graph-identifier').text() == 'motdash-gr'){
      handleMotherDashboard();
    }

})

function handleMotherDashboard(){
  console.log('>>> Handle Mother dashboad');

  
}
