$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  console.log('Partn TBL Page as changed');
  mainPartnLoaderInCaseOfChange();
})

function mainPartnLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'pardash-gr'){
  }
  else{
    //do nothing
  }
}
