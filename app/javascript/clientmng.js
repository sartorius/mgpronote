$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  //console.log('Client TBL Page as changed');
  mainClientLoaderInCaseOfChange();
})

function mainClientLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'cltmng-gr'){

      // Initalize
      initDataTagToJsonArrayDashboard();

      window.addEventListener("orientationchange", function(event) {
        runjsClientGrid();
      });

      // Confirmation button is here
      $("#crt-cb-clt-cf").click(function() {
        if($("#dial-order").html() == 'C'){
          //confirmedBarCodeFor($(this).data('name'), $(this).val(), $(this).data('order'), $(this).data('email'));
          confirmedBarCodeFor();
        }
        else{
          //confirmedMngClientToCreateBC($(this).data('name'), $(this).val(), $(this).data('order'), $(this).data('email'));
          confirmedMngClientToCreateBC();
        }
      });

      $("#close-feeback").click(function() {
        //console.log('$("#close-feeback").click');
        $('#mgs-dialog-feedback').hide(100);
      });

      $( "#mgs-print-csv" ).click(function() {
        generateCSV();
      });
  }
  else{
    //do nothing
  }
}

function revokeClientPOCMng(name, id, o, email){
  // console.log('revokeClientPOCMng: you did click on me: ' + name + '#' + id + ' order: ' + o + ' email: ' + email);
  //console.log('Here is o: ' + o);
  // POC mode
  $("#dial-order").html('P');
  $('#nm-t-cf').html(' changer les drois de ' + name + '#' + id + ((o == 'FALSE') ? ' pour une <strong>interdiction de créer des suivis/codes barres</strong>' : ' pour une <strong>autorisation de créer des suivis/codes barres</strong>'));
  // Parameters in dialog !
  $('#crt-cb-param').html(id);
  $('#crt-cb-order').html(o);
  $('#crt-cb-email').html(email);
  $('#mgs-dialog').modal('show');
  $('html, body').animate({
              scrollTop: $("#mg-graph-identifier").offset().top
          }, 400);

}

//Inner variable declaration !
function createBarCodeFor(name, id, o, email){
  // console.log('createBarCodeFor: you did click on me: ' + name + '#' + id + ' order: ' + o + ' email: ' + email);
  // Creation mode
  $("#dial-order").html('C');
  $('#nm-t-cf').html(' créer un code barre pour ' + name + '#' + id + ((o == 'D') ? ' pour une <strong>livraison</strong>' : ' pour un <strong>enlèvement</strong>'));
  // Parameters in dialog !
  $('#crt-cb-param').html(id);
  $('#crt-cb-order').html(o);
  $('#crt-cb-email').html(email);

  // This element need to be modal
  $('#mgs-dialog').modal('show');
  $('html, body').animate({
              scrollTop: $("#mg-graph-identifier").offset().top
          }, 400);
  //console.log('createBarCodeFor');
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



function addbarCodeJson(clientId){
  for(i=0; i<dataTagToJsonArray.length; i++){
    if(dataTagToJsonArray[i].id == clientId){
      dataTagToJsonArray[i].totalbc = parseInt(dataTagToJsonArray[i].totalbc) + 1;
      //console.log('read value: ' + dataTagToJsonArray[i].totalbc);
      //console.log('updated value: ' + parseInt(dataTagToJsonArray[i].totalbc) + 1);
      $('#totalbc-'+clientId).html(dataTagToJsonArray[i].totalbc);
      break;
    }
  }
}

function updRevokMng(clientId){
  for(i=0; i<dataTagToJsonArray.length; i++){
    if(dataTagToJsonArray[i].id == clientId){
      dataTagToJsonArray[i].poc = (dataTagToJsonArray[i].poc ? false : true);
      //console.log('read value: ' + dataTagToJsonArray[i].totalbc);
      //console.log('updated value: ' + parseInt(dataTagToJsonArray[i].totalbc) + 1);
      break;
    }
  }
  runjsClientGrid();
}

function confirmedBarCodeFor(){
  //console.log('confirmedBarCodeFor you clicked for: ' + $('#crt-cb-param').html());
  let clientId = $('#crt-cb-param').html();
  let clientEmail = $('#crt-cb-email').html();
  $.ajax('/createbarcodeforclient', {
      type: 'POST',  // http method
      data: { client_id: clientId,
              client_email: clientEmail,
              partner_id: $('#cur-part-id').html(),
              auth_token: $('#auth-token-s').val(),
              order: $('#crt-cb-order').html(),
      },  // data to submit
      success: function (data, status, xhr) {
          //console.log('answer: ' + xhr.responseText);
          if(xhr.responseText == 'ok'){
            $('#msg-feedback').html("Super ! L'opération s'est déroulée correctment");
            addbarCodeJson(clientId);
          }
          else if(xhr.responseText == 'unk'){
            $('#msg-feedback').html("Navré ! L'opération a retourné une erreur réseau FOZE903-" + xhr.responseText);
            addbarCodeJson(clientId);
          }
          else{
            $('#msg-feedback').html("Navré ! L'opération a retourné une erreur réseau FORG283-" + xhr.responseText);
          }
          displaySuccessDialog();
      },
      error: function (jqXhr, textStatus, errorMessage) {
          $('#msg-feedback').html("Navré ! Une erreur POE6728 est survenue");
          displayErrorDialog();
      }
  });
}

//Authorize the client to create his/her own barcode
function confirmedMngClientToCreateBC(){
  //console.log('confirmedMngClientToCreateBC: you did click on me');
  //console.log('confirmedBarCodeFor you clicked for: ' + $('#crt-cb-param').html());
  let clientId = $('#crt-cb-param').html();
  let clientEmail = $('#crt-cb-email').html();
  $.ajax('/revokmngbarcodeforclient', {
      type: 'POST',  // http method
      data: { client_id: clientId,
              client_email: clientEmail,
              partner_id: $('#cur-part-id').html(),
              auth_token: $('#auth-token-s').val(),
              order: $('#crt-cb-order').html(),
      },  // data to submit
      success: function (data, status, xhr) {
          //console.log('answer: ' + xhr.responseText);
          if(xhr.responseText == 'ok'){
            $('#msg-feedback').html("Super ! Le changement de droit de " + clientEmail + " <br> s'est déroulée correctment");
            updRevokMng(clientId);
          }
          else{
            $('#msg-feedback').html("Navré ! L'opération a retourné une erreur réseau RED209-" + xhr.responseText);
          }
          displaySuccessDialog();
      },
      error: function (jqXhr, textStatus, errorMessage) {
          $('#msg-feedback').html("Navré ! Une erreur 9UZ728 est survenue");
          displayErrorDialog();
      }
  });
}


/** Filter utils **/
function clearDataPartner(){
  filteredDataTagToJsonArray = Array.from(dataTagToJsonArray);
  runjsClientGrid();
};

function filterData(){
  if(($('#filter-all').val().length > 2) && ($('#filter-all').val().length < 35)){
    filteredDataTagToJsonArray = dataTagToJsonArray.filter(function (el) {
                                      return el.raw_data.includes($('#filter-all').val().toUpperCase())
                                  });
    runjsClientGrid();
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
  runjsClientGrid();
}


/* JS GRID */
function runjsClientGrid(){
  let fields;
  /*
  let listToUpd = new Array();
  listToUpd.push('print-dash');
  listToUpd.push('all-print-dash');
  listToUpd.push('re-init-print-dash');
  listToUpd.push('re-init-dash');
  */

  if(window.screen.availWidth < 1100){
    // Small screens
    //fromMDSizetoSM(listToUpd);
    responsivefields = [
        { name: "enc_client_ref",
          title: 'Reférence',
          type: "text",
          width: 38,
          headercss: "h-jsG-l"
        },
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
          title: '<i class="fas fa-qrcode"></i>',
          type: "string",
          align: "left",
          width: 35,
          itemTemplate: function(value, item) {
            return '<button type="submit" id="cltd-' + value + '" class="btn btn-default btn-sm btn-block d-bc-crt-clt" data-order="D" data-email="' + item.email + '" data-name="' + item.name + " " + item.firstname + '" value="' + value + '">' + '<i class="c-w fas fa-box"></i>' + '</button>';
          }
        },
        {
          name: "id",
          title: '<i class="fas fa-qrcode"></i>',
          type: "string",
          align: "left",
          width: 20,
          itemTemplate: function(value, item) {
            return '<button type="submit" id="cltp-' + value + '" class="btn btn-alternative btn-sm btn-block p-bc-crt-clt" data-order="P" data-email="' + item.email + '" data-name="' + item.name + " " + item.firstname + '" value="' + value + '">' + '<i class="c-b fas fa-truck"></i>' + '</button>';
          }
        },
        {
          name: "id",
          title: '<i class="far fa-copy"></i>',
          type: "string",
          align: "left",
          width: 25,
          itemTemplate: function(value, item) {
            return '<button id="revok-' + value + '" class="btn btn-default' + (item.poc ? '-light' : '') + ' btn-sm btn-block btn-rvk-mng" data-order="' + (item.poc ? 'FALSE' : 'TRUE') + '" data-email="' + item.email + '" data-name="' + item.name + " " + item.firstname + '" value="' + value + '">' + (item.poc ? '<i class="far fa-times-circle"></i>' : '<i class="far fa-copy"></i>') + '</button>';
          }
        }
    ]
  }
  else{
    // Big screens
    //fromSMSizetoMD(listToUpd);
    responsivefields = [
        { name: "id", title: "#", type: "number", width: 18 , headercss: "h-jsG-r" },
        { name: "enc_client_ref",
          title: 'Reférence',
          type: "text",
          width: 38,
          headercss: "h-jsG-l"
        },
        { name: "name",
          title: "Nom",
          type: "text",
          filtering: true,
          align: "right",
          width: 50,
          headercss: "h-jsG-r",
          itemTemplate: function(value, item) {
            return ((value == null) ? '-' : value.substring(0, STR_LENGTH_LG));
          }
        },
        { name: "firstname",
          title: "Prénom",
          type: "text",
          align: "right",
          width: 50,
          headercss: "h-jsG-r",
          itemTemplate: function(value, item) {
            return ((value == null) ? '-' : value.substring(0, STR_LENGTH_LG));
          }
        },
        { name: "email",
          title: "Email",
          type: "text",
          align: "right",
          headercss: "h-jsG-r",
          itemTemplate: function(value, item) {
            return ((value == null) ? '-' : value.substring(0, STR_LENGTH_XL));
          }
        },
        { name: "totalbc",
          title: '<i class="far fa-list-alt"></i>',
          type: "number",
          width: 18,
          headercss: "h-jsG-r",
          itemTemplate: function(value, item) {
            return '<i id="totalbc-' + item.id + '">' + value + '</i>';
          }
        },
        { name: "poc",
          title: '<i class="far fa-copy"></i>',
          type: "string",
          align: "center",
          width: 10,
          itemTemplate: function(value, item) {
            return value ? '<i class="fas fa-check-square"></i>' : '<i class="far fa-times-circle"></i>';
          }
        },
        //Default width is auto
        { name: "since", title: "Client.e depuis", type: "text", width: 50, align: "right", headercss: "h-jsG-r" },
        {
          name: "id",
          title: '<i class="fas fa-qrcode"></i>',
          type: "string",
          align: "left",
          width: 35,
          itemTemplate: function(value, item) {
            return '<button type="submit" id="cltd-' + value + '" class="btn btn-default btn-sm btn-block d-bc-crt-clt" data-order="D" data-email="' + item.email + '" data-name="' + item.name + " " + item.firstname + '" value="' + value + '">' + '<i class="c-w fas fa-box"></i>' + '</button>';
          }
        },
        {
          name: "id",
          title: '<i class="fas fa-qrcode"></i>',
          type: "string",
          align: "left",
          width: 20,
          itemTemplate: function(value, item) {
            return '<button type="submit" id="cltp-' + value + '" class="btn btn-alternative btn-sm btn-block p-bc-crt-clt" data-order="P" data-email="' + item.email + '" data-name="' + item.name + " " + item.firstname + '" value="' + value + '">' + '<i class="c-b fas fa-truck"></i>' + '</button>';
          }
        },
        {
          name: "id",
          title: '<i class="far fa-copy"></i>',
          type: "string",
          align: "left",
          width: 25,
          itemTemplate: function(value, item) {
            return '<button id="revok-' + value + '" class="btn btn-default' + (item.poc ? '-light' : '') + ' btn-sm btn-block btn-rvk-mng" data-order="' + (item.poc ? 'FALSE' : 'TRUE') + '" data-email="' + item.email + '" data-name="' + item.name + " " + item.firstname + '" value="' + value + '">' + (item.poc ? '<i class="far fa-times-circle"></i>' : '<i class="far fa-copy"></i>') + '</button>';
          }
        }
    ]
  }


  $("#nb-el-dash").html(filteredDataTagToJsonArray.length);
  if(dataTagToJsonArray.length > 0){
    $("#jsGrid").jsGrid({
        height: "auto",
        width: "100%",
        sorting: true,
        paging: true,
        rowClick: function(args){
          var $target = $(args.event.target);
          if($target.closest(".d-bc-crt-clt").length) {
             //Do something
             createBarCodeFor((args.item.name + ' ' + args.item.firstname),
                                args.item.id,
                                'D',
                                args.item.email);
          }
          else if($target.closest(".p-bc-crt-clt").length) {
             //Do something
             createBarCodeFor((args.item.name + ' ' + args.item.firstname),
                                args.item.id,
                                'P',
                                args.item.email);
          }
          else if($target.closest(".btn-rvk-mng").length) {
             //Do something
             //console.log('button revok');
             revokeClientPOCMng((args.item.name + ' ' + args.item.firstname),
                                  args.item.id,
                                  (args.item.poc ? 'FALSE' : 'TRUE'),
                                  args.item.email);
          }
          else{
            //Do nothing we did not recognize the order

            if(window.screen.availWidth < 1100){
              // Not available on mobile/small screen
            }
            else{
              $('#client-id-post').val(args.item.id);
              //Run submit
              //console.log('button not recognized');
              $('#mg-checkbc-form').submit();
            }
          }
        },

        data: filteredDataTagToJsonArray,

        fields: responsivefields
    });
  }
  else{
    $("#jsGrid").hide();
  }
}





/***********************************************************************************************************/


/***************************************************************************************/

function generateCSV(){
	const csvContentType = "data:text/csv;charset=utf-8,";
  let csvContent = "";
  const SEP_ = ";"

  let dataString = "#" + SEP_ + "Référence" + SEP_ + "Nom" + SEP_ + "Prénom" + SEP_ + "Email" + SEP_ + "Total de codes barres" + SEP_ + "Client depuis" + SEP_ + "\n";
	csvContent += dataString;
	for(var i=0; i<dataTagToJsonArray.length; i++){
		dataString = dataTagToJsonArray[i].id + SEP_ + dataTagToJsonArray[i].enc_client_ref + SEP_ + removeDiacritics(dataTagToJsonArray[i].name) + SEP_ + removeDiacritics(dataTagToJsonArray[i].firstname) + SEP_ +  dataTagToJsonArray[i].email.toLowerCase() + SEP_ +  dataTagToJsonArray[i].totalbc + SEP_ +  dataTagToJsonArray[i].since.toLowerCase() + SEP_ ;
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
  link.download = 'clientListeMGSuiviPartenaire.csv';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}
