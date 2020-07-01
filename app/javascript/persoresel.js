$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  console.log('Personal reseller TBL Page as changed');
  mainClientLoaderInCaseOfChange();
})

function mainClientLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'peredash-gr'){
      runjsPersoreselGrid();
  }
  if($('#mg-graph-identifier').text() == 'pereone-gr'){
      $('#bc-seeone').html(mgsEncode($('#id-seeone').html(), $('#sec-seeone').html()));
  }
  else{
    //do nothing
  }
}

function goToBarcode(lid, lsec){
  //alert('You clicked on item: ' + el);
  $("#read-cb-id").val(lid);
  $("#read-cb-sec").val(lsec);

  $("#mg-checkbc-form").submit();
}

/* JS GRID */
function runjsPersoreselGrid(){
  for(i=0; i<dataTagToJsonArray.length; i++){
    dataTagToJsonArray[i].ref_tag = mgsEncode(dataTagToJsonArray[i].id, dataTagToJsonArray[i].secure);
  }

  if(dataTagToJsonArray.length > 0){
    $("#jsGrid").jsGrid({
        height: "auto",
        width: "100%",

        sorting: true,
        paging: true,
        // args are item - itemIndex - event
        rowClick: function(args){
          goToBarcode(args.item.id, args.item.secure)
        },
        data: dataTagToJsonArray,

        fields: [
            { name: "id", title: "#", type: "number", width: 5, headercss: "h-jsG-r" },
            { name: "ref_tag",
              title: "Référence",
              type: "text",
              align: "right",
              width: 25,
              headercss: "h-jsG-r",
              itemTemplate: function(value, item) {
                return '<i class="monosp-ft">' + value + '</i>';
              }
            },
            { name: "step", title: "Status", type: "text", width: 25, headercss: "h-jsG-l" },
            { name: "part_phone", title: "Téléphone", type: "text", width: 20, headercss: "h-jsG-r" },
            //Default width is auto
            { name: "part_name", title: "Nom partenaire", type: "text", headercss: "h-jsG-l" }

        ]
    });
  }
  else{
    $("#jsGrid").hide();
  }
}
