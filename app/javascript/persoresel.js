$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  console.log('Personal reseller TBL Page as changed');
  mainClientLoaderInCaseOfChange();
})

function mainClientLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'peredash-gr'){
      runjsPersoreselGrid();
  }
  else if($('#mg-graph-identifier').text() == 'persom-gr'){
      runjsPartnerListGrid();
      //Button Barcode creator
      $( ".bc-crt-clt" ).click(function() {
        createBarCodeFor($(this).data('partner_name'), $(this).val(), $(this).data('order'));
      });

      $("#crt-cb-clt-ds").click(function() {
        $('#mgs-dialog').hide(100);
      });

      // Confirmation button is here
      $("#crt-cb-clt-cf").click(function() {
        confirmedBarCodeFor();
      });

      $("#close-feeback").click(function() {
        //console.log('$("#close-feeback").click');
        $('#mgs-dialog-feedback').hide(100);
      });
  }
  else if($('#mg-graph-identifier').text() == 'pereone-gr'){
      let readBCSeeOne = mgsEncode($('#id-seeone').html(), $('#sec-seeone').html());

      $('#bc-seeone').html(readBCSeeOne);

      $( "#disp-add-info" ).click(function() {
        $("#add-inf-blc").show(400);
        $("#mg-add-ext-ref").val($('#alr-ref-ext').html());
        $("#mg-add-descr").val($('#alr-descr').html());

        $("#mg-add-tname").val($('#alr-rec-name').html());
        $("#mg-add-tfname").val($('#alr-rec-fname').html());
        $("#mg-add-tphone").val($('#alr-rec-phone').html());

      });
      $( "#disp-cnl-inf" ).click(function() {
        $("#add-inf-blc").hide(400);
      });


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


/*******************************************************************************************************/
/*******************************************************************************************************/
/*******************************************************************************************************/
/*******************************************************************************************************/
function addbarCodeJson(partnerId){
  for(i=0; i<dataTagToJsonArray.length; i++){
    if(dataTagToJsonArray[i].id == partnerId){
      dataTagToJsonArray[i].totalbc = parseInt(dataTagToJsonArray[i].totalbc) + 1;
      //console.log('read value: ' + dataTagToJsonArray[i].totalbc);
      //console.log('updated value: ' + parseInt(dataTagToJsonArray[i].totalbc) + 1);
      $('#totalbc-'+partnerId).html(dataTagToJsonArray[i].totalbc);
      break;
    }
  }
}


function displaySuccessDialog(){
  $('#mgs-dialog-feedback').show(100);
  $('#mgs-dialog').hide(100);
}

function displayErrorDialog(){
  $('#close-feeback').removeClass('mgs-dialog-fdb-success');
  $('#close-feeback').addClass('mgs-dialog-fdb-error');
  $('#mgs-dialog-feedback').show(100);
  $('#mgs-dialog').hide(100);
}

//Inner variable declaration !
function createBarCodeFor(pName, id, o){
  //console.log('createBarCodeFor: you did click on me: ' + name + '#' + id);
  //console.log('Here is o: ' + o);
  // The value here is the partner id
  $('#nm-t-cf').html(pName + '#' + id + ((o == 'D') ? ' pour une <strong>réception</strong>' : ' pour un <strong>enlèvement</strong>'));
  // Parameters in dialog !

  $('#crt-cb-param').html(id);
  $('#crt-cb-order').html(o);
  $('#mgs-dialog').show(100);
}

function confirmedBarCodeFor(){
  //console.log('confirmedBarCodeFor you clicked for: ' + $('#crt-cb-param').html());
  let partnerId = parseInt($('#crt-cb-param').html());
  $.ajax('/createbarcodebyclient', {
      type: 'POST',  // http method
      data: { partner_id: partnerId,
              auth_token: $('#auth-token-s').val(),
              order: $('#crt-cb-order').html(),
      },  // data to submit
      success: function (data, status, xhr) {
          //console.log('answer: ' + xhr.responseText);
          if(xhr.responseText == 'ok'){
            $('#msg-feedback').html("Super ! L'opération s'est déroulée correctment");
            addbarCodeJson(partnerId);
          }
          else if (xhr.responseText ==  'poc'){
            $('#msg-feedback').html("Navré ! Veuillez vérifier vos droits de création avec ce partenaire. L'opération a retourné un erreur réseau FORG988-" + xhr.responseText);
          }else{
            $('#msg-feedback').html("Navré ! L'opération a retourné un erreur réseau FORG763-" + xhr.responseText);
          }
          displaySuccessDialog();
      },
      error: function (jqXhr, textStatus, errorMessage) {
          $('#msg-feedback').html("Navré ! Une erreur POE6728 est survenue");
          displayErrorDialog();
      }
  });
}



/* JS GRID CLIENT LIST */
function runjsPartnerListGrid(){
  if(dataTagToJsonArray.length > 0){
    $("#jsGridPartnerList").jsGrid({
        height: "auto",
        width: "100%",

        sorting: true,
        paging: true,

        data: dataTagToJsonArray,

        fields: [
            { name: "rp_name", title: "Partenaire", type: "text", filtering: true, align: "right", width: 50, headercss: "h-jsG-r" },
            { name: "rp_desc", title: "Description", type: "text", align: "right", width: 100, headercss: "h-jsG-r" },
            { name: "since", title: "Inscrit depuis", type: "text", align: "right", headercss: "h-jsG-r" },
            { name: "totalbc",
              title: '<i class="glyphicon glyphicon-list-alt"></i>',
              type: "number",
              width: 18,
              headercss: "h-jsG-r",
              itemTemplate: function(value, item) {
                return '<i id="totalbc-' + item.id + '">' + value + '</i>';
              }
            },
            {
              name: "id",
              title: '<i class="glyphicon glyphicon-barcode"></i>',
              type: "string",
              align: "left",
              width: 25,
              itemTemplate: function(value, item) {
                return '<button type="submit" id="cltd-' + value + '" class="btn btn-default btn-sm btn-block bc-crt-clt" data-order="D" data-partner_name="' + item.rp_name + '" value="' + value + '">' + '<i class="c-w glyphicon glyphicon-home"></i>' + '</button>';
              }
            },
            {
              name: "id",
              title: '<i class="glyphicon glyphicon-barcode"></i>',
              type: "string",
              align: "left",
              width: 25,
              itemTemplate: function(value, item) {
                return '<button type="submit" id="cltp-' + value + '" class="btn btn-primary btn-sm btn-block bc-crt-clt" data-order="P" data-partner_name="' + item.rp_name + " " + '" value="' + value + '">' + '<i class="c-b glyphicon glyphicon-arrow-up"></i>' + '</button>';
              }
            }
        ]
    });
  }
  else{
    $("#jsGridPartnerList").hide();
  }
}
