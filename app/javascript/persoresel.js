$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  console.log('Personal reseller TBL Page as changed');
  mainClientLoaderInCaseOfChange();
})

function mainClientLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'peredash-gr'){
      runjsPersoreselGrid();
  }
  else if($('#mg-graph-identifier').text() == 'pereone-gr'){
      let readBCSeeOne = mgsEncode($('#id-seeone').html(), $('#sec-seeone').html());

      $('#bc-seeone').html(readBCSeeOne);



      // In case of pickup
      if($('#mg-subgraph-identifier').text() == 'pereonepk-gr'){
        //console.log('Read listenPickUpFormCreate');
        //initialize
        $("#save-addr-sub").prop('disabled', true);
        $("#save-addr-sub").hide();
        listenPickUpFormCreate();
      }
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
            { name: "status",
              title: '<i class="glyphicon glyphicon-edit"></i>',
              type: "text",
              align: "center",
              width: 10,
              headercss: "h-jsG-c",
              itemTemplate: function(value, item) {
                return (value == '0') ? '<i class="mgs-red glyphicon glyphicon-pencil"></i>' : '<i class="glyphicon glyphicon-remove"></i>';
              }
            },
            { name: "type_pack",
              title: '<i class="glyphicon glyphicon-barcode"></i>',
              type: "text",
              align: "center",
              width: 10,
              headercss: "h-jsG-c",
              itemTemplate: function(value, item) {
                return (value == 'D') ? '<i class="c-w glyphicon glyphicon-home"></i>' : '<i class="c-b glyphicon glyphicon-arrow-up"></i>';
              }
            },
            { name: "part_phone", title: "Téléphone", type: "text", width: 20, headercss: "h-jsG-l" },
            //Default width is auto
            { name: "part_name", title: "Nom partenaire", type: "text", headercss: "h-jsG-l" },
            { name: "create_date", title: "Créé le", type: "text", width: 25, headercss: "h-jsG-l" },
            { name: "diff_days",
              title: '<i class="glyphicon glyphicon-time"></i>',
              type: "number",
              width: 3,
              headercss: "h-jsG-c",
              itemTemplate: function(value, item) {
                return '<p class="center">' + value + '</p>';
              }
            }

        ]
    });
  }
  else{
    $("#jsGrid").hide();
  }
}

// Check


function listenPickUpFormCreate(){
  $( ".crt-fill-form" ).keyup(function() {
    verityFieldPickup();
  });
  $( "#save-addr-sub" ).click(function() {
    $('#crt-name').val(capitalizeFirstLetter($('#crt-name').val()));
    $('#crt-fname').val(capitalizeFirstLetter($('#crt-fname').val()));
  });
}

function verityFieldPickup(){
  // Test Phone number
  const re = /^[+-]?\d+$/;
  let allFieldOK = true;

  // Check
  if($('#mg-add-pk-name').val().length < 3){
    allFieldOK = false;
    $('#ck-mg-add-pk-name').show(800);
  }
  else{
    $('#ck-mg-add-pk-name').hide(800);
  }
  if($('#mg-add-pk-add').val().length < 10){
    allFieldOK = false;
    $('#ck-mg-add-pk-add').show(800);
  }
  else{
    $('#ck-mg-add-pk-add').hide(800);
  }
  if (!(re.test($('#mg-add-pk-phone').val()))){
    allFieldOK = false;
    $('#ck-mg-add-pk-phone').show(800);
  }
  else{
    $('#ck-mg-add-pk-phone').hide(800);
  }



  if(allFieldOK){
      $("#save-addr-sub").prop('disabled', false);
      $("#save-addr-sub").show(500);
  }
  else{
      $("#save-addr-sub").prop('disabled', true);
      $("#save-addr-sub").hide(500);
  }
}
