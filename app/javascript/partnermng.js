$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  console.log('Partn TBL Page as changed');
  mainPartnLoaderInCaseOfChange();
})

function mainPartnLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'pardash-gr'){
    testjsGrid();
  }
  else{
    //do nothing
  }
}



function testjsGrid(){
  $("#jsGrid").jsGrid({
      height: "auto",
      width: "100%",

      sorting: true,
      paging: true,

      data: dataTagToJsonArray,

      fields: [
          { name: "id", title: "#", type: "text", width: 50 },
          { name: "ref_tag", title: "Référence", type: "number", width: 50 },
          { name: "step", title: "Status", type: "text", width: 200 }
      ]
  });
}
