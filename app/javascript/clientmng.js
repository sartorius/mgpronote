$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  console.log('Client TBL Page as changed');
  mainClientLoaderInCaseOfChange();
})

function mainClientLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'cltmng-gr'){
    runjsClientGrid();
  }
  else{
    //do nothing
  }
}

/* JS GRID */
function runjsClientGrid(){
  if(dataTagToJsonArray.length > 0){
    $("#jsGrid").jsGrid({
        height: "auto",
        width: "100%",

        sorting: true,
        paging: true,

        data: dataTagToJsonArray,

        fields: [
            { name: "id", title: "#", type: "number", width: 25, headercss: "h-jsG-r" },
            { name: "name", title: "Nom", type: "text", align: "right", width: 50, headercss: "h-jsG-r" },
            { name: "firstname", title: "Prénom", type: "text", align: "right", width: 50, headercss: "h-jsG-r" },
            { name: "email", title: "Email", type: "text", align: "right", width: 75, headercss: "h-jsG-r" },
            //Default width is auto
            { name: "since", title: "Client depuis le", type: "text", align: "right", headercss: "h-jsG-r" }
        ]
    });
  }
  else{
    $("#jsGrid").hide();
  }
}
