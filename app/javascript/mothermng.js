$(document).ready(function() {
  // console.log('We are in MGFollowAPP JS2');
  //mainLoaderInCaseOfChange();
});

$(document).on('turbolinks:load', function() {

    // Handle specific page
    // Dashboard
    if($('#mg-graph-identifier').text() == 'motdash-gr'){
      // Button creation mother main
      $( ".crt-moth" ).click(function() {
        reqConfMother();
      });
      // Button confirmation
      // Confirmation button is here
      $("#crt-cb-clt-cf").click(function() {
        // Do something
        createMotherBarcode();
      });

      handleMotherDashboard();

    }

})

function handleMotherDashboard(){
  console.log('>>> Handle Mother dashboad');
  initDataTagToJsonArrayMother();
  printBtnAvailability();
  $( "#print-dash" ).click(function() {
    // To call back to use these only when ended
    handlePrint();

  });
  $("#all-print-dash").click(function() {
    fillMaxPrint();
  });

  // Handle the feedback if by any reason we have created a new Element
  let msgToDisp = sessionStorage.getItem("msgStDisp");
  if(msgToDisp != null){
    $('#msg-feedback').html(msgToDisp);
    sessionStorage.removeItem("msgStDisp");
    displaySuccessDialog();
  }
}

// Dirty utils
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

function reqConfMother(){
  console.log( ": reqConfMother" );

  //dataTagToJsonWorkflowArray
  let optionStr = '';
  for(i=0; i<dataTagToJsonWorkflowArray.length; i++){
    optionStr =  optionStr + '<option value="' + dataTagToJsonWorkflowArray[i].rw_code + '">' + dataTagToJsonWorkflowArray[i].rw_description + '</option>';
  }
  $('#opt-wkf').html(optionStr);
  $('#multiple-workflow').show();


  $('#nm-t-cf').html(' créer une référence mother ');
  // Go for it modal confirmation
  $('#mgs-dialog').modal('show');
  $('html, body').animate({
              scrollTop: $("#mg-graph-identifier").offset().top
          }, 400);
}

function createMotherBarcode(){
  // We call an asynchronous ajax

  let selectedWorkflow = parseInt(document.getElementById('opt-wkf').selectedIndex);
  let selectedWorkflowId = dataTagToJsonWorkflowArray[selectedWorkflow].rw_id;
  $.ajax('/createmother', {
      type: 'POST',  // http method
      data: { partner_id: $('#cur-part-id').html(),
              wf_id: selectedWorkflowId,
              auth_token: $('#auth-token-s').val()
      },  // data to submit
      success: function (data, status, xhr) {
          console.log('answer: ' + xhr.responseText + ' - data: ' + data.toString());
          if(xhr.responseText == 'unk'){
            $('#msg-feedback').html("Navré ! L'opération a retourné une erreur réseau MOZE926-" + xhr.responseText);
          }
          else if(xhr.responseText == 'ko'){
            $('#msg-feedback').html("Navré ! L'opération a retourné une erreur inconnue MOZU926-" + xhr.responseText);
          }
          else{
            //$('#msg-feedback').html("Super ! Le code mother créé est le suivant : " + xhr.responseText);
            let msgToDisp = "Super ! La référence mother a été créé avec succés !";
            // As we reload the Page - we need to save the data in local storage
            sessionStorage.setItem("msgStDisp", msgToDisp);
            document.location.reload(true);
          }
          displaySuccessDialog();

      },
      error: function (jqXhr, textStatus, errorMessage) {
          $('#msg-feedback').html("Navré ! Une erreur MOE6980 est survenue");
          displayErrorDialog();
      }
  });
}

/************** FILTER *************/

function clearDataMother(){
  filteredDataTagToJsonArray = Array.from(dataTagToJsonArray);
  runjsMotherGrid();
};

function filterDataMother(){
  if(($('#filter-all').val().length > 2) && ($('#filter-all').val().length < 35)){
    //console.log('We need to filter !' + $('#filter-all').val());
    filteredDataTagToJsonArray = dataTagToJsonArray.filter(function (el) {
                                      return el.raw_data.includes($('#filter-all').val().toUpperCase())
                                  });
    runjsMotherGrid();
  }
  else if(($('#filter-all').val().length < 3)) {
    // We clear data
    clearDataMother();
  }
  else{
    // DO nothing
  }
}

/***** INIT DATA *****/
// This function is used to encode only
function initDataTagToJsonArrayMother(){
  if(dataTagToJsonArray.length > 0){
    for(i=0; i<dataTagToJsonArray.length; i++){
      dataTagToJsonArray[i].mt_ref = mgsEncode(dataTagToJsonArray[i].id, dataTagToJsonArray[i].secure, 'M');
      dataTagToJsonArray[i].c_crt = mgsEncodeClientRef(dataTagToJsonArray[i].u_firstname, dataTagToJsonArray[i].creator_id, dataTagToJsonArray[i].u_client_ref)
      // We concatenate the data
      dataTagToJsonArray[i].raw_data = dataTagToJsonArray[i].raw_data + dataTagToJsonArray[i].mt_ref + dataTagToJsonArray[i].c_crt;
    }


    $('#filter-all').keyup(function() {
      filterDataMother();
    });

    $('#re-init-dash').click(function() {
      $('#filter-all').val('');
      clearDataMother();
    });

  }
  runjsMotherGrid();
}


function fillMaxPrint(){
  clearPrint();
  const MAX_PRINT = parseInt($('#max-print-const').html());

  let counterPrint = 0;
  for(iallP=0; iallP<MAX_PRINT+1+counterPrint; iallP++){
    //console.log('iallP value >>>>>>>>>>>>' + iallP);
    // We do not go more than limit and we do not print if already printed
    if(iallP<filteredDataTagToJsonArray.length){
      //console.log('fillMaxPrint: ' + filteredDataTagToJsonArray[iallP].id);
      //console.log('printArray.length: ' + printArray.length);
      if(filteredDataTagToJsonArray[iallP].ald_print == 'N'){
        printMngOrder(filteredDataTagToJsonArray[iallP].id, 'U', filteredDataTagToJsonArray[iallP].mt_ref, filteredDataTagToJsonArray[iallP].c_crt, filteredDataTagToJsonArray[iallP].rfw_code);
      }
      else{
        // It has been printed already we inc more one
        counterPrint = counterPrint + 1;
      }
    }
    else{
      //console.log('ELSE fillMaxPrint: ' + filteredDataTagToJsonArray.length + ' vs ' + iallP);
    }
  }
}

function printMngOrder(id, order, bcref, cliref, pwfcode){
  const MAX_PRINT = parseInt($('#max-print-const').html());
  //console.log('MAX_PRINT: ' + MAX_PRINT);
  let updateArrayList = false;
  //console.log('printMngOrder: ' + id + '/' + order + '/' + bcref + '/' + cliref + '/' + pwfcode);
  //console.log('id: ' + id);
  if(order == 'U'){
    //console.log('1');
    // we are unprint so we need to print !
    if(printArray.length > MAX_PRINT){
      //console.log('2');
      $('#print-max-msg').html(" - Max impression: " + (parseInt(MAX_PRINT) + 1).toString());
    }
    else{
      //console.log('3');
      let el = {
                id: parseInt(id),
                bcref: bcref,
                cliref: cliref,
                wfcode: pwfcode
              };
      printArray.push(el);
      updateArrayList = true;
    }
  }
  else{
    //console.log('4');
    // in that case it is P
    // we are Print so we need to unprint !
    //console.log('read id: ' + parseInt(id))
    let index = -1;

    for(i=0; i<printArray.length; i++){
      if(printArray[i].id == parseInt(id)){
        index = i;
        break;
      }
    }
    if (index !== -1){
      //console.log('5');
      printArray.splice(index, 1);
      updateArrayList = true;
      $('#print-max-msg').html('');
    }
    //console.log('found index: ' + index);
  }
  if(updateArrayList){
    //console.log('6');
    printBtnAvailability();
    updatePrintElemntArray(id);
  }
};

function printBtnAvailability(){
  $('#count-print').html((printArray.length == 0 ? '' : printArray.length));
  if(printArray.length > 0){
    $("#print-dash").prop('disabled', false);
  }
  else{
    $("#print-dash").prop('disabled', true);
  }
}



/* JS GRID */
function runjsMotherGrid(){

    responsivefields = [
        { name: "mt_ref",
          title: "Référence",
          type: "text",
          align: "right",
          width: 50,
          headercss: "h-jsG-r",
          itemTemplate: function(value, item) {
            return '<i class="monosp-ft">' + value + '</i>';

          }
        },
        { name: "rfw_code",
          title: '<i class="fas fa-clipboard-list"></i>',
          type: "text",
          align: "center",
          width: 10,
          headercss: "h-jsG-c",
          itemTemplate: function(value, item) {
            return value;
          }
        },
        { name: "c_crt",
          title: 'Créé par',
          type: "text",
          align: "left",
          headercss: "h-jsG-l",
          itemTemplate: function(value, item) {
            return value;
          }
        },
        {
          name: "id",
          title: '<i class="fas fa-th-list"></i>',
          type: "string",
          align: "left",
          width: 10,
          itemTemplate: function(value, item) {
            // print U is for Unpring
            // print P is for Print
            // onclick="printMngOrder(' + value + ', "' + item.print + '")"
            return '<button id="print-bc-' + value + '" class="btn btn-default' + (item.print == 'U' ? '' : '-light') + ' btn-sm btn-block btn-print-mng" data-order="' + item.print + '" value="' + value + '">' + '<i class="fas fa-layer-group"></i>' + '</button>';
          }
        },
        { name: "create_date",
          title: 'Créé le',
          type: "text",
          width: 25,
          align: "left",
          headercss: "h-jsG-l",
          itemTemplate: function(value, item) {
            return value;
          }
        },
        {
          name: "id",
          title: '<i class="fas fa-print"></i>',
          type: "string",
          align: "left",
          width: 10,
          itemTemplate: function(value, item) {
            // print U is for Unpring
            // print P is for Print
            // onclick="printMngOrder(' + value + ', "' + item.print + '")"
            return '<button id="print-bc-' + value + '" class="btn btn-default' + (item.print == 'U' ? '' : '-light') + ' btn-sm btn-block btn-print-mng" data-order="' + item.print + '" value="' + value + '">' + '<i class="fas fa-print"></i>' + '</button>';
          }
        }
    ];

  if(dataTagToJsonArray.length > 0){
    //Set the number of data
    $("#nb-el-dash").html(filteredDataTagToJsonArray.length);
    $("#jsGrid").jsGrid({
        height: "auto",
        width: "100%",

        sorting: true,
        paging: true,
        // args are item - itemIndex - event
        rowClick: function(args){
          //console.log(args.event);
          //alert('test ' + JSON.stringify(args.event));
          // I cannot do anything on the row click for now
          //goToPartBarcode(args.item.id, args.item.secure)
          var $target = $(args.event.target);
          //console.log(JSON.stringify($target));
          //console.log(JSON.stringify(args.event));
          //console.log(args.item.id);
          if($target.closest(".btn-print-mng").length) {
             // handle cell click
             //console.log('IN btn-print-mng');
             printMngOrder(args.item.id, args.item.print, args.item.mt_ref, args.item.c_crt, args.item.rfw_code);
          }
          else{
            //console.log('OUT btn-print-mng');
            //goToPartBarcode(args.item.id, args.item.secure);
          }
        },

        data: filteredDataTagToJsonArray,

        fields: responsivefields
    });
    // After the grid
    refreshListener();
  }
  else{
    $("#jsGrid").hide();
  }
}



function refreshListener(){
  //After the grid creation we do the listener Here
  $( "#re-init-print-dash" ).click(function() {
    clearPrint();
  });
}

function clearPrint(){
  //console.log('input clearPrint');
  for(i=0; i<dataTagToJsonArray.length; i++){
    dataTagToJsonArray[i].print = 'U';
  }
  /* clean barcode list */
  for(i=0; i<printArray.length; i++){
    $("#item-bc-"+i).html('');
    //JsBarcode("#mbc-"+i, '0');
    new QRCode(document.getElementById("mbc-"+i), { text: '0', width: 96, height: 96 });
  }

  runjsMotherGrid();
  printArray = new Array();
  printBtnAvailability();
}

function clearPrintElemntArray(id){
  // Then update row data
  for(i=0; i<dataTagToJsonArray.length; i++){
    if(dataTagToJsonArray[i].id == id){
      dataTagToJsonArray[i].print = 'U';
      break;
    }
  }
}

function updatePrintElemntArray(id){
  // Then update row data
  for(i=0; i<dataTagToJsonArray.length; i++){
    if(dataTagToJsonArray[i].id == id){
      // console.log('O Found element: ' + i);

      if(dataTagToJsonArray[i].print == 'U'){
        //console.log('O Found element U: ' + dataTagToJsonArray[i].print);
        dataTagToJsonArray[i].print = 'P';
      }
      else{
        // console.log('O Found element P: ' + dataTagToJsonArray[i].print);
        dataTagToJsonArray[i].print = 'U';
      }
      break;
    }
  }

  runjsMotherGrid();
}

/***** PRINT *****/
function handlePrint(){
  //console.log('handlePrint: ');
  //console.log(JSON.stringify(printArray));

  for(i=0; i<printArray.length; i++){
    $("#item-bc-"+i).html(printArray[i].bcref + '<br>' + printArray[i].cliref + '<br>' + $('#part-tech-name').html());
    //JsBarcode("#mbc-"+i, printArray[i].bcref);
    new QRCode(document.getElementById("mbc-"+i), { text: printArray[i].bcref, width: 96, height: 96 });
    //console.log('I am imging: ' + i);
    //We need to notify that these have been printed for the session
    for(k=0; k<dataTagToJsonArray.length; k++){
      if(dataTagToJsonArray[k].id == printArray[i].id){
        dataTagToJsonArray[k].ald_print = 'Y';
        break;
      }
    }

  }

  let needToPrinted = true;
  // We have to check the element are ready
  var checkExist = setInterval(function() {
     if(needToPrinted){
       if (checkIfAllQRCodeHasBeenGenerate()) {
          //console.log("All generated !");
          needToPrinted = false;
          generatePrintedPDF();
          clearPrint();
       }
     }
  }, 100); // check every 100ms
}

function checkIfAllQRCodeHasBeenGenerate(){
  let allGenerated = true;
  for(i=0; i<printArray.length; i++){
    if(typeof document.getElementById('mbc-'+i).getElementsByTagName('img')[0] === "undefined"){
      allGenerated = false;
      break;
    }
  }
  return allGenerated;
}


//These data to make sure data are fit
function setCellSize(value){
	return value.substring(0, 170);
}
function setCellSizeMedium(value){
	return value.substring(0, 100);
}
function setSmallCellSize(value){
	return value.substring(0, 50);
}

function pad(num, size) {
    var s = num+"";
    while (s.length < size) s = "0" + s;
    return s;
}

// Main PRINT PDF is here !
function generatePrintedPDF(){
	//$("body").addClass("loading");
  //$("#screen-load").show();
  //console.log('Click on generatePrintedPDF');

  var doc = new jsPDF();


  // We check the position here
  var wantedPos = 0;
  if(document.getElementById("positionOffset") == null){
    // Do nothing
  }
  else {
    wantedPos = parseInt(document.getElementById("positionOffset").selectedIndex);
    //console.log('wantedPos 1: ' + wantedPos);
    let maxPrintDisplay = $('#max-print-const').html();
    //console.log('wantedPos 2: ' + wantedPos);
    //console.log('maxPrintDisplay 2: ' + maxPrintDisplay);
    if((parseInt(wantedPos) + printArray.length) > parseInt(maxPrintDisplay)){
      //then we need to lower wanted Pos
      //console.log('wantedPos 3: ' + wantedPos);
      wantedPos = parseInt(maxPrintDisplay) - printArray.length + 1;
    }
  }
  var rowReseter = 1 + parseInt(wantedPos/2);
  //console.log('rowReseter: '+ rowReseter + ' wantedPos: ' + wantedPos);

  var currentDate = new Date();
  //console.log('current date: ' + currentDate.toLocaleString())


	var cel1_2 = '';
	var cel2 = '';
	var cel3 = '';

  var barcodeWidth = 20;
  var barcodeHeight = 20;

	var startY = 15;
	var sizeY = 20;
	var offsetX = 20;
	var offsetY = 30;

	var cellSize = 45;
	var offsetY2margin = 5;

  let first_line_back = 15;
  let const_offsetY2 = 40;

	var offsetY2 = 0;
	var offsetY2Details = 7;
  var offsetY2CltDetails = 4;
  var offsetTextY2 = 20;
	var offsetBackY = 5;




  //This should be the loop for one page
  //Should not oversize 12
  //rowReseter is the line counter
  //This handle row max is 2
  for(i=0; i<printArray.length; i++){

    // offsetY2 is the row position. We start row setter as 1
    if(rowReseter == 1){
      offsetY2 = const_offsetY2 - first_line_back;
    }
    else{
      offsetY2 = const_offsetY2;
    }

    let oddOffsetX =  100 * ((parseInt(wantedPos)+i) % 2);
    //console.log('i: ' + i);
    //console.log('oddOffsetX: ' + oddOffsetX);
    //console.log('rowReseter: '+ rowReseter);
    let celTitle = '';
    celTitle = celTitle + setCellSize(shorter(printArray[i].bcref));
    celTitle = celTitle + setCellSize(' -----> ' + printArray[i].wfcode);
    let celTitleRef = doc.setFontSize(12).splitTextToSize(celTitle, cellSize);
    doc.text(offsetX + oddOffsetX + barcodeWidth + 2, (offsetY2)*rowReseter + offsetY2margin, celTitleRef);

    let celClient = '';
    celClient = celClient + setCellSize(printArray[i].cliref + ' - ' + printArray[i].bcref);
    let celClientRef = doc.setFontSize(9).splitTextToSize(celClient, cellSize);
    doc.text(offsetX + oddOffsetX + barcodeWidth + 2, (offsetY2)*rowReseter + offsetY2CltDetails + offsetY2margin, celClientRef);

    let cel1 = '';
    cel1 = cel1 + "Appartient à: " + $('#part-tech-name').html();
    //.setFont('Lucida Console')
    let celRef = doc.setFontSize(6).splitTextToSize(cel1 + ' - Imprimé le ' + currentDate.toLocaleString(), cellSize);
    doc.text(offsetX + oddOffsetX + barcodeWidth + 2, (offsetY2)*rowReseter + offsetY2Details + offsetY2margin, celRef);

    //console.log('Element print read: mbc-' + i );
    // addImage(imageData, format, x, y, width, height, alias, compression, rotation)
    //console.log('here is i value: ' + i);
    doc.addImage(document.getElementById('mbc-' + i).getElementsByTagName('img')[0].src, //img src
                  'PNG', //format
                  offsetX + oddOffsetX, //x oddOffsetX is to define if position 1 or 2
                  offsetY2*rowReseter, //y
                  barcodeWidth, //Width
                  barcodeHeight, null, 'FAST'); //Height // Fast is to get less big files

    // Incremetor are here
    if((((parseInt(wantedPos)+i) + 1) % 2) == 0){
      rowReseter++
    }
  }

  doc.save('MGSuivi_Mother_Print');

}
