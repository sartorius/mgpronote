$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  //console.log('Personal reseller TBL Page as changed');
  mainClientLoaderInCaseOfChange();
})

function mainClientLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'peredash-gr'){
      initDataTagToJsonArrayDashboard();
      $( "#mgs-dash-print-csv" ).click(function() {
        generateDashCSV();
      });


      window.addEventListener("orientationchange", function(event) {
        runjsPersoreselGrid();
      });
  }
  else if($('#mg-graph-identifier').text() == 'persom-gr'){
      runjsPartnerListGrid();
      //Button Barcode creator
      $( ".bc-crt-clt" ).click(function() {
        createBarCodeFor($(this).data('partner_name'), $(this).val(), $(this).data('order'));
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

    // Display the barcode to print
    //DisplayOne
    // JsBarcode("#mbc-0", getBarcodeMGS);



      let readBCSeeOne = mgsEncode($('#id-seeone').html(), $('#sec-seeone').html());
      displayWorkflowClient();

      $('#bc-seeone').html(readBCSeeOne);

      new QRCode(document.getElementById("mbc-0"), { text: readBCSeeOne, width: 96, height: 96 });
      $( "#disp-add-info" ).click(function() {
        //$("#add-inf-blc").show(400);
        // To animate to scroll to the element
        /*
        $('html, body').animate({
                    scrollTop: $("#add-inf-blc").offset().top
                }, 400);
        */

        $('#mgs-dialog-add-info').modal('show');

        $("#mg-add-ext-ref").val($('#alr-ref-ext').html());
        $("#mg-add-descr").val($('#alr-descr').html());

        $("#mg-add-tname").val($('#alr-rec-name').html());
        $("#mg-add-tfname").val($('#alr-rec-fname').html());
        $("#mg-add-tphone").val($('#alr-rec-phone').html());


      });

      // In case of pickup
      if($('#mg-subgraph-identifier').text() == 'pereonepk-gr'){

        $('#mgs-dialog-pickup-info').modal('show');
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

function displayWorkflowClient(){


  // console.log('displayWorkflowClient: Start');
  let disStep = '';
  let disStepBC = '';
  let disStepBCGrp = 0;
  let neverDisplayBC = false;

  let chevron = ''
  const nspStart = '<div class="wrkf-blc wrkf-light">&nbsp;';
  let nspEnd = '&nbsp;</div>&nbsp;';
  const nspSelected = '<div class="wrkf-blc wrkf-selected">&nbsp;';

  if(window.screen.availWidth < 1100){
    // We need to display return button as this is used mostly to see the workflow
    $('#return-list-mobile').show(100);
    // We display on column on small screens
    $('#optim-big-scr').html('Cet écran a été optimisé pour téléphone mobile.');
    $('#el-wf-1').removeClass('center');
    $('#el-wf-1').addClass('pos-left');
    chevron = '<i class="fas fa-chevron-circle-right"></i>';
    nspEnd = nspEnd + '<br>';
  }

  for(i=0; i<dataTagToJsonStepWFArray.length; i++){
    if(i == 0){
      disStepBC = disStepBC + nspSelected + dataTagToJsonStepWFArray[i].step + nspEnd;
      disStepBCGrp = parseInt(dataTagToJsonStepWFArray[i].id);
    }
    else{
      if((disStepBCGrp <= parseInt(dataTagToJsonStepWFArray[i].id)) && (!neverDisplayBC)){
        disStep = disStep + chevron + disStepBC;
        neverDisplayBC = true;
        // at this step the current i is lost if we are still strinctly inferior
        // We do not want to display the same family
        if(disStepBCGrp < parseInt(dataTagToJsonStepWFArray[i].id)){
          // As greater we do not display selected
          disStep = disStep + chevron + nspStart + dataTagToJsonStepWFArray[i].grp_step + nspEnd;
        }
      }
      else if(dataTagToJsonStepWFArray[i].common == true){
        disStep = disStep + ((parseInt(dataTagToJsonStepWFArray[i].id) < disStepBCGrp) ? chevron + nspSelected : chevron + nspStart) + dataTagToJsonStepWFArray[i].grp_step + nspEnd;
      }
      else{
        //do nothing
      }
      // We add chevron, we do not want to start with value
      chevron = '<i class="fas fa-chevron-circle-right"></i>';
    }
  }
  if (!neverDisplayBC){
    disStep = disStep + chevron + disStepBC;
    //do nothing
  }
  $("#disp-step").html(disStep);
}


function goToBarcode(lid, lsec){
  //alert('You clicked on item: ' + el);
  $("#read-cb-id").val(lid);
  $("#read-cb-sec").val(lsec);

  $("#mg-checkbc-form").submit();
}

/** Filter utils **/
function clearDataPartner(){
  filteredDataTagToJsonArray = Array.from(dataTagToJsonArray);
  runjsPersoreselGrid();
};

function filterData(){
  if(($('#filter-all').val().length > 2) && ($('#filter-all').val().length < 35)){
    filteredDataTagToJsonArray = dataTagToJsonArray.filter(function (el) {
                                      return el.raw_data.includes($('#filter-all').val().toUpperCase())
                                  });
    runjsPersoreselGrid();
  }
  else if(($('#filter-all').val().length < 3)) {
    // We clear data
    clearDataPartner();
  }
  else{
    // DO nothing
  }
}

// This function is used to encode only
function initDataTagToJsonArrayDashboard(){
  for(i=0; i<dataTagToJsonArray.length; i++){
    dataTagToJsonArray[i].ref_tag = mgsEncode(dataTagToJsonArray[i].id, dataTagToJsonArray[i].secure);
    dataTagToJsonArray[i].raw_data = (dataTagToJsonArray[i].ref_tag + dataTagToJsonArray[i].part_name + dataTagToJsonArray[i].step + dataTagToJsonArray[i].bcdescription + dataTagToJsonArray[i].p_address_note).toUpperCase();
  }
  filteredDataTagToJsonArray = dataTagToJsonArray.slice(0);


  if(dataTagToJsonArray.length > 0){
    $('#filter-all').keyup(function() {
      filterData();
    });
    $('#re-init-dash').click(function() {
      $('#filter-all').val('');
      clearDataPartner();
    });

  }
  /* THE INIT HAS BEEN DONE IN ERB */
  // filteredDataTagToJsonArray = dataTagToJsonArray;
  runjsPersoreselGrid();
}

/* JS GRID */
/*                  JS GRID ONE                   */
/* This is MES SUIVIS - all my suivis */
function runjsPersoreselGrid(){

  if(window.screen.availWidth < 1100){
    $('#optim-big-scr').html('Cet écran a été optimisé pour téléphone mobile.');
    // Mobile
    responsivefields = [
        { name: "ref_tag",
          title: "#",
          type: "text",
          align: "left",
          width: 95,
          headercss: "h-jsG-l",
          itemTemplate: function(value, item) {
            return '<i class="monosp-ft-mob">' + value + '</i>';
          }
        },
        { name: "status",
          title: '<i class="far fa-edit"></i>',
          type: "text",
          align: "center",
          width: 25,
          headercss: "h-jsG-c",
          itemTemplate: function(value, item) {

              switch (value.toString()) {
                case '3':
                  //return item.type_pack;
                  return (item.type_pack == 'P') ? '<i class="mgs-red fas fa-pen-square"></i>' : '<i class="fas fa-arrow-circle-right"></i>';
                  break;
                case '10':
                  return '<i class="fas fa-hand-holding-heart"></i>';
                  break;
                default:
                  return '<i class="fas fa-arrow-circle-right"></i>';
              }
          }
        },
        { name: "part_name",
          title: 'Part.',
          type: "text",
          align: "center",
          width: 65,
          headercss: "h-jsG-c",
          itemTemplate: function(value, item) {
            return ((value == null) ? '-' : value.substring(0, STR_LENGTH_SM));
          }
        },
        {
          name: "paid_code",
          title: '<i class="fas fa-receipt"></i>',
          type: "number",
          width: 30,
          headercss: "h-jsG-c",
          itemTemplate: function(value, item) {
            return '<p class="center">' + ((item.hdl_price == 'N') ? '<i class="fas fa-window-close"></i>' : value) + '</p>';

          }
        },
        //Default width is auto
        { name: "bcdescription",
          title: '<i class="fas fa-info-circle"></i>',
          type: "text",
          headercss: "h-jsG-c",
          itemTemplate: function(value, item) {
            return ((value == null) ? '-' : value.substring(0, STR_LENGTH_SM));
          }
        }
    ];
  }
  else{
    // Big screens
    responsivefields = [
        { name: "ref_tag",
          title: "Référence",
          type: "text",
          align: "right",
          width: 43,
          headercss: "h-jsG-r",
          itemTemplate: function(value, item) {
            return '<i class="monosp-ft">' + value + '</i>';
          }
        },
        { name: "step",
          title: "Status",
          type: "text",
          width: 55,
          headercss: "h-jsG-l",
          itemTemplate: function(value, item) {
            return ((value == null) ? '-' : value.substring(0, STR_LENGTH_XXL));
          }
        },
        { name: "status",
          title: '<i class="far fa-edit"></i>',
          type: "text",
          align: "center",
          width: 10,
          headercss: "h-jsG-c",
          itemTemplate: function(value, item) {
            return ((value == '3') && (item.type_pack == 'P')) ? '<i class="mgs-red fas fa-pen-square"></i>' : '<i class="fas fa-window-close"></i>';
          }
        },
        { name: "type_pack",
          title: '<i class="fas fa-barcode"></i>',
          type: "text",
          align: "center",
          width: 10,
          headercss: "h-jsG-c",
          itemTemplate: function(value, item) {
            return (value == 'D') ? '<i class="c-w fas fa-box"></i>' : '<i class="c-b fas fa-truck"></i>';
          }
        },
        //Default width is auto
        { name: "part_name",
          title: "Nom partenaire",
          type: "text",
          width: 45,
          headercss: "h-jsG-l",
          itemTemplate: function(value, item) {
            return ((value == null) ? '-' : value.substring(0, STR_LENGTH_XL));
          }
        },
        { name: "bcdescription",
          title: "Description",
          type: "text",
          headercss: "h-jsG-l",
          itemTemplate: function(value, item) {
            return ((value == null) ? '-' : value.substring(0, STR_LENGTH_XXL));
          }
        },
        { name: "create_date", title: "Créé le", type: "text", width: 30, headercss: "h-jsG-l" },
        { name: "diff_days",
          title: '<i class="fas fa-stopwatch"></i>',
          type: "number",
          width: 3,
          headercss: "h-jsG-c",
          itemTemplate: function(value, item) {
            return '<p class="center">' + value + '</p>';
          }
        },
        {
          name: "paid_code",
          title: '<i class="fas fa-receipt"></i>',
          type: "number",
          width: 3,
          headercss: "h-jsG-c",
          itemTemplate: function(value, item) {
            return '<p class="center">' + ((item.hdl_price == 'N') ? '<i class="fas fa-window-close"></i>' : value) + '</p>';
            // return item.hdl_price;
          }
        }

    ];
  }


  $("#nb-el-dash").html(filteredDataTagToJsonArray.length);
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
        data: filteredDataTagToJsonArray,

        fields: responsivefields
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
  $('#mgs-dialog').modal('hide');
}

function displayErrorDialog(){
  $('#close-feeback').removeClass('mgs-dialog-fdb-success');
  $('#close-feeback').addClass('mgs-dialog-fdb-error');
  $('#mgs-dialog-feedback').show(100);
  $('#mgs-dialog').modal('hide');
}

//Inner variable declaration !
function createBarCodeFor(pName, id, o){
  //console.log('createBarCodeFor: you did click on me: ' + name + '#' + id);
  //console.log('Here is o: ' + o);
  let arrayWfListToValidate;
  for(i=0; i<dataTagToJsonArray.length; i++){
    if(id == dataTagToJsonArray[i].cpx_partner_id){
      arrayWfListToValidate = dataTagToJsonArray[i].workflow_list;
      break;
    }
  }

  let optionStr = '';
  for(i=0; i<arrayWfListToValidate.length; i++){
    optionStr =  optionStr + '<option value="' + arrayWfListToValidate[i].rw_code + '">' + arrayWfListToValidate[i].rw_description + '</option>';
  }
  $('#opt-wkf').html(optionStr);
  $('#multiple-workflow').show();

  // The value here is the partner id
  $('#nm-t-cf').html(' choisir notre partenaire ' + pName + ((o == 'D') ? ' pour un suivi <strong>livraison</strong>&nbsp;<i class="fas fa-box"></i>' : ' pour un suivi <strong>enlèvement</strong>&nbsp;<i class="fas fa-truck"></i>'));
  // Parameters in dialog !

  $('#crt-cb-param').html(id);
  $('#crt-cb-order').html(o);
  $('#mgs-dialog').modal('show');
}

function confirmedBarCodeFor(){
  //console.log('confirmedBarCodeFor you clicked for: ' + $('#crt-cb-param').html());
  let partnerId = parseInt($('#crt-cb-param').html());
  let arrayWfListToValidate;
  for(i=0; i<dataTagToJsonArray.length; i++){
    if(partnerId == dataTagToJsonArray[i].cpx_partner_id){
      arrayWfListToValidate = dataTagToJsonArray[i].workflow_list;
      break;
    }
  }
  let selectedWorkflow = parseInt(document.getElementById('opt-wkf').selectedIndex);
  let selectedWorkflowId = arrayWfListToValidate[selectedWorkflow].rw_id;

  $.ajax('/createbarcodebyclient', {
      type: 'POST',  // http method
      data: { partner_id: partnerId,
              wf_id: selectedWorkflowId,
              auth_token: $('#auth-token-s').val(),
              order: $('#crt-cb-order').html(),
      },  // data to submit
      success: function (data, status, xhr) {
          //console.log('answer: ' + xhr.responseText);
          if(xhr.responseText == 'ok'){
            $('#msg-feedback').html("Super ! L'opération s'est déroulée correctment");
            addbarCodeJson(partnerId);
          }
          else if (xhr.responseText ==  'max'){
            $('#msg-feedback').html("Navré ! Vous avez dépassé le maximum de création sur 7 jours. Veuillez contacter votre partenaire pour qu'il vous en crée. L'opération a retourné un refus FORG988-" + xhr.responseText);
          }
          else if (xhr.responseText ==  'poc'){
            $('#msg-feedback').html("Navré ! Veuillez vérifier vos droits de création avec ce partenaire. L'opération a retourné un refus FOSG328-" + xhr.responseText);
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



/* JS GRID PARTNER FOR CLIENT LIST */
/*                                       JS GRID 2                           */
function runjsPartnerListGrid(){
  if(dataTagToJsonArray.length > 0){

    if(window.screen.availWidth < 1100){
      // SMALL Screens
      $('#optim-big-scr').html('Cet écran a été optimisé pour téléphone mobile.');
      responsivefields = [
          { name: "rp_name", title: "Partenaire", type: "text", filtering: true, align: "right", width: 50, headercss: "h-jsG-r" },
          { name: "totalbc",
            title: '<i class="far fa-list-alt"></i>',
            type: "number",
            width: 18,
            headercss: "h-jsG-r",
            itemTemplate: function(value, item) {
              return '<i id="totalbc-' + item.id + '">' + value + '</i>';
            }
          },
          {
            name: "id",
            title: '<i class="fas fa-barcode"></i>',
            type: "string",
            align: "left",
            width: 30,
            itemTemplate: function(value, item) {
              return '<button type="submit" id="cltd-' + value + '" class="btn btn-default btn-sm btn-block bc-crt-clt" data-order="D" data-partner_name="' + item.rp_name + '" value="' + value + '">' + '<i class="c-w fas fa-box"></i>' + '</button>';
            }
          },
          {
            name: "id",
            title: '<i class="fas fa-barcode"></i>',
            type: "string",
            align: "left",
            width: 20,
            itemTemplate: function(value, item) {
              return '<button type="submit" id="cltp-' + value + '" class="btn btn-alternative btn-sm btn-block bc-crt-clt" data-order="P" data-partner_name="' + item.rp_name + " " + '" value="' + value + '">' + '<i class="c-b fas fa-truck"></i>' + '</button>';
            }
          }
      ]
    }
    else{
      // BIG Screens
      responsivefields = [
          { name: "rp_name", title: "Partenaire", type: "text", filtering: true, align: "right", width: 50, headercss: "h-jsG-r" },
          { name: "rp_desc", title: "Description", type: "text", align: "right", width: 100, headercss: "h-jsG-r" },
          { name: "since", title: "Inscrit depuis", type: "text", align: "right", headercss: "h-jsG-r" },
          { name: "totalbc",
            title: '<i class="far fa-list-alt"></i>',
            type: "number",
            width: 18,
            headercss: "h-jsG-r",
            itemTemplate: function(value, item) {
              return '<i id="totalbc-' + item.id + '">' + value + '</i>';
            }
          },
          {
            name: "id",
            title: '<i class="fas fa-barcode"></i>',
            type: "string",
            align: "left",
            width: 30,
            itemTemplate: function(value, item) {
              return '<button type="submit" id="cltd-' + value + '" class="btn btn-default btn-sm btn-block bc-crt-clt" data-order="D" data-partner_name="' + item.rp_name + '" value="' + value + '">' + '<i class="c-w fas fa-box"></i>' + '</button>';
            }
          },
          {
            name: "id",
            title: '<i class="fas fa-barcode"></i>',
            type: "string",
            align: "left",
            width: 20,
            itemTemplate: function(value, item) {
              return '<button type="submit" id="cltp-' + value + '" class="btn btn-alternative btn-sm btn-block bc-crt-clt" data-order="P" data-partner_name="' + item.rp_name + " " + '" value="' + value + '">' + '<i class="c-b fas fa-truck"></i>' + '</button>';
            }
          }
      ]
    }

    $("#jsGridPartnerList").jsGrid({
        height: "auto",
        width: "100%",

        sorting: true,
        paging: true,

        data: dataTagToJsonArray,
        fields: responsivefields
    });
  }
  else{
    $("#jsGridPartnerList").hide();
  }
}



/*******************************************************************************************************/
/*******************************           CSV      ****************************************************/
/*******************************************************************************************************/
/*******************************************************************************************************/
function generateDashCSV(){
	const csvContentType = "data:text/csv;charset=utf-8,";
  let csvContent = "";
  const SEP_ = ";"

  let dataString = "#" + SEP_ + "Reference" + SEP_ + "Status" + SEP_ + "Numero" + SEP_ + "Partenaire" + SEP_ + "Date de creation" + SEP_ + "Description" + SEP_ + "En attente depuis" + SEP_ + "\n";
	csvContent += dataString;
	for(var i=0; i<dataTagToJsonArray.length; i++){
		dataString = dataTagToJsonArray[i].id + SEP_ +
                  removeDiacritics(dataTagToJsonArray[i].ref_tag) + SEP_ +
                  removeDiacritics(dataTagToJsonArray[i].step) + SEP_ +
                  dataTagToJsonArray[i].part_phone + SEP_ +
                  dataTagToJsonArray[i].part_name + SEP_ +
                  dataTagToJsonArray[i].create_date + SEP_ +
                  dataTagToJsonArray[i].bcdescription + SEP_ +
                  dataTagToJsonArray[i].diff_days + SEP_ ;
    // easy close here
    csvContent += i < dataTagToJsonArray.length ? dataString+ "\n" : dataString;
	}

  //console.log('Click on csv');
	let encodedUri = encodeURI(csvContent);
  let csvData = new Blob([csvContent], { type: csvContentType });

	let link = document.createElement("a");
  let csvUrl = URL.createObjectURL(csvData);

  link.href =  csvUrl;
  link.style = "visibility:hidden";
  link.download = 'suiviListeMGSuiviClient.csv';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}
