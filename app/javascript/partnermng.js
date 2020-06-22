$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  console.log('Partn TBL Page as changed');
  mainPartnLoaderInCaseOfChange();
})

function mainPartnLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'pardash-gr'){
    testjsGrid();
  }
  if($('#mg-graph-identifier').text() == 'parprint12-gr'){
    print12Display();
  }

  else{
    //do nothing
  }
}

/* Print 12 */

function print12Display(){
  var numberRow = 0;
  numberRow = $('#nb-lines').html();
  console.log("Read number of row: " + numberRow);
  for(i=0; i<numberRow; i++){
    JsBarcode("#barcode-"+i, $("#item-bc-"+i).html());
  }
}

/* JS GRID */
function testjsGrid(){
  $("#jsGrid").jsGrid({
      height: "auto",
      width: "100%",

      sorting: true,
      paging: true,

      data: dataTagToJsonArray,

      fields: [
          { name: "id", title: "#", type: "number", width: 25, headercss: "h-jsG-r" },
          { name: "ref_tag", title: "Référence", type: "text", align: "right", width: 50, headercss: "h-jsG-r" },
          //Default width is auto
          { name: "step", title: "Status", type: "text", width: 50, headercss: "h-jsG-l" },
          { name: "dest_email", title: "Destinataire", type: "text", headercss: "h-jsG-l" }
      ]
  });
}
