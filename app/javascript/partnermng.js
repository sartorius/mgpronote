$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  //console.log('Partn TBL Page as changed');
  mainPartnLoaderInCaseOfChange();
})

function mainPartnLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'pardash-gr'){
    //alert('size H:' + window.screen.availHeight + ' W:' + window.screen.availWidth);

    initDataTagToJsonArrayDashboard();
    printBtnAvailability();

    window.addEventListener("orientationchange", function(event) {
      runjsPartnerGrid();
    });
    $( "#print-dash" ).click(function() {
      // To call back to use these only when ended
      handlePrint();

    });
    $( "#mgs-dash-print-csv" ).click(function() {
      generatePartDashCSV();
    });
    $("#all-print-dash").click(function() {
      fillMaxPrint();
    });
  }
  else if(($('#mg-graph-identifier').text() == 'parprint12-gr') ||
          ($('#mg-graph-identifier').text() == 'parprintnotrack-gr')){
    $("#btn-print-12").click(function() {
        generateCb12PDF();
    });
    display12Cb();
  }
  else if($('#mg-graph-identifier').text() == 'partonebc-gr'){
      let getBarcodeMGS = mgsEncode($('#id-seeone').html(), $('#sec-seeone').html());
      $('#bc-seeone').html(getBarcodeMGS);

      // Display the barcode to print
      //DisplayOne
      // JsBarcode("#mbc-0", getBarcodeMGS);
      new QRCode(document.getElementById("mbc-0"), { text: getBarcodeMGS, width: 96, height: 96 });
      $("#btn-print-bc").click(function() {
          // If the user click a secund time we want to not push again
          if(printArray.length == 0){
              let oneBarcode = {
                bcref: mgsEncode($('#id-seeone').html(), $('#sec-seeone').html()),
                cliref: $('#cli-ref').html(),
              };
              printArray.push(oneBarcode);
          }
          generatePrintedPDF();
      });

      displayWorkflowClient();
  }
  else{
    //do nothing
  }
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

function displayWorkflowClient(){
  // console.log('displayWorkflowClient: Start');
  let disStep = '';
  let disStepBC = '';
  let disStepBCGrp = 0;
  let neverDisplayBC = false;

  let chevron = ''
  const nspStart = '<div class="wrkf-blc wrkf-light">&nbsp;';
  const nspEnd = '&nbsp;</div>&nbsp;';
  const nspSelected = '<div class="wrkf-blc wrkf-selected">&nbsp;';

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
      // common means usual. For example Enlevement is not common
      else if(dataTagToJsonStepWFArray[i].common == true){
        disStep = disStep + ((parseInt(dataTagToJsonStepWFArray[i].id) < disStepBCGrp) ? chevron + nspSelected : chevron + nspStart) + dataTagToJsonStepWFArray[i].grp_step + nspEnd;
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


/* Print 12 */
// This function is inspired by Camelbull generateAppPDF() function
function generateCb12PDF(){
	$("body").addClass("loading");
  console.log('Click on generateCb12PDF');

  var doc = new jsPDF();
	var rowReseter = 1;

  var currentDate = new Date();
  //console.log('current date: ' + currentDate.toLocaleString())

  var cel1 = '';
	var cel1_2 = '';
	var cel2 = '';
	var cel3 = '';

  var barcodeWidth = 60;
  var barcodeHeight = 25;

	var startY = 15;
	var sizeY = 20;
	var offsetX = 5;
	var offsetY = 30;

	var cellSize = 45;
	var offsetY2 = 40;
  var offsetTextY2 = 20;
	var offsetBackY = 5;

  //This should be the loop for one page
  //Should not oversize 12
  //rowReseter is the line counter
  //This handle row max is 2
  for(i=0; i<dataTagToJsonArray.length; i++){
    var oddOffsetX =  100 * (i % 2);

    //The destinataire is not filled for now
    if(dataTagToJsonArray[i].dest_email == null){
      cel1 = setCellSize('Destinataire: non renseigné');
    }
    else{
      cel1 = setCellSize('Destinataire: ' + dataTagToJsonArray[i].dest_email);
    }
    if(dataTagToJsonArray[i].step == null){
      cel1 = cel1 + setCellSize(' - Étape: Err 4890');
    }
    else{
      cel1 = cel1 + setCellSize(' - Étape: ' + dataTagToJsonArray[i].step);
    }
    cel1 = cel1 + " - Ce paquet ne vous appartient pas? Contactez contact@partenaire.com";
    var celRef = doc.setFontSize(6).splitTextToSize(cel1 + ' - Imprimé le ' + currentDate.toLocaleString(), cellSize);;
    doc.text(offsetX + oddOffsetX + barcodeWidth + 2, 3 + (offsetY2 + 1)*rowReseter, celRef);


    // addImage(imageData, format, x, y, width, height, alias, compression, rotation)
    doc.addImage(document.getElementById('mbc-' + i).getElementsByTagName('img')[0].src, //img src
                  'PNG', //format
                  offsetX + oddOffsetX, //x oddOffsetX is to define if position 1 or 2
                  offsetY2*rowReseter, //y
                  barcodeWidth, //Width
                  barcodeHeight); //Height

    // Incremetor are here
    if(((i + 1) % 2) == 0){
      rowReseter++
    }
  }

  doc.save('MGSuivi_P12');

  $("body").removeClass("loading");
}

function display12Cb(){
  for(i=0; i<dataTagToJsonArray.length; i++){
    // Use this to pad padStart(2, '0')
    dataTagToJsonArray[i].ref_tag = mgsEncode(dataTagToJsonArray[i].id, dataTagToJsonArray[i].secure);
    $("#item-bc-"+i).html(dataTagToJsonArray[i].ref_tag);
    //JsBarcode("#mbc-"+i, dataTagToJsonArray[i].ref_tag);
    new QRCode(document.getElementById("mbc-"+i), { text: dataTagToJsonArray[i].ref_tag, width: 96, height: 96 });
    //JsBarcode("#mbc-"+i, 'M9999999999PAK15');
    // var i = 99999999999; i.toString(34); >> 1uovgaaj
  }
}

function goToPartBarcode(lid, lsec){
  //alert('You clicked on item: ' + el);
  $("#read-cb-id").val(lid);
  $("#read-cb-sec").val(lsec);

  $("#mg-checkbc-form").submit();
}

function sleep(milliseconds) {
  const date = Date.now();
  let currentDate = null;
  do {
    currentDate = Date.now();
  } while (currentDate - date < milliseconds);
}


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
    cel1 = cel1 + setCellSize('Type: ' + (printArray[i].typedorp == 'D' ? 'LIVRAISON_' : 'ENLEVEMENT'));
    cel1 = cel1 + setCellSize(' - Desc: ' + printArray[i].wfdesc);
    cel1 = cel1 + " - Appartient à: " + $('#part-tech-name').html();
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

  doc.save('MGSuivi_Print');

  //$("body").removeClass("loading");
  //$("#screen-load").hide();
}


/************** FILTER *************/

function clearDataPartner(){
  filteredDataTagToJsonArray = Array.from(dataTagToJsonArray);
  runjsPartnerGrid();
};

function filterData(){
  if(($('#filter-all').val().length > 2) && ($('#filter-all').val().length < 35)){
    //console.log('We need to filter !' + $('#filter-all').val());
    filteredDataTagToJsonArray = dataTagToJsonArray.filter(function (el) {
                                      return el.raw_data.includes($('#filter-all').val().toUpperCase())
                                  });
    runjsPartnerGrid();
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
    for(i=0; i<dataTagToJsonArray.length; i++){
      dataTagToJsonArray[i].ref_tag = mgsEncode(dataTagToJsonArray[i].id, dataTagToJsonArray[i].secure);
      dataTagToJsonArray[i].oclient_ref = mgsEncodeClientRef(dataTagToJsonArray[i].ofirstname, dataTagToJsonArray[i].oid, dataTagToJsonArray[i].oclient_ref)
      // We concatenate the data
      dataTagToJsonArray[i].raw_data = dataTagToJsonArray[i].raw_data + dataTagToJsonArray[i].ref_tag + dataTagToJsonArray[i].oclient_ref;
    }

    //DEBUG
    /**** We do a load test here ! ****/
    /**** We do a load test here ! ****/
    /**** We do a load test here ! ****/
    /* AFTER Test we can go up to 2700 records / I have heard that 5K may be the max / Even the Excel work */
    /*

    var loadTestJSONArray = new Array();
    let j = 0;
    for(k=0; k<100; k++){

      for(i=0; i<dataTagToJsonArray.length; i++){
        //dataTagToJsonArray[i].id = j;
        loadTestJSONArray.push(dataTagToJsonArray[i]);
        j++;
      }
    }
    console.log('We have this data: ' + j);
    dataTagToJsonArray = loadTestJSONArray;
    filteredDataTagToJsonArray = dataTagToJsonArray;
    */

    /**** We do a load test here ! ****/
    /**** We do a load test here ! ****/
    /**** We do a load test here ! ****/

    $('#filter-all').keyup(function() {
      filterData();
    });

    $('#re-init-dash').click(function() {
      $('#filter-all').val('');
      clearDataPartner();
    });

  }
  runjsPartnerGrid();
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
        printMngOrder(filteredDataTagToJsonArray[iallP].id, 'U', filteredDataTagToJsonArray[iallP].ref_tag, filteredDataTagToJsonArray[iallP].oclient_ref, filteredDataTagToJsonArray[iallP].type_pack, filteredDataTagToJsonArray[iallP].rfw_code, filteredDataTagToJsonArray[iallP].rfw_desc);
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

function printMngOrder(id, order, bcref, cliref, ptypedorp, pwfcode, pwfdesc){
  const MAX_PRINT = parseInt($('#max-print-const').html());
  //console.log('MAX_PRINT: ' + MAX_PRINT);
  let updateArrayList = false;
  //console.log('printMngOrder: ');
  //console.log('id: ' + id);
  if(order == 'U'){
    //console.log('1');
    // we are unprint so we need to print !
    if(printArray.length > MAX_PRINT){
      //console.log('2');
      $('#print-max-msg').html("- Max impression: " + (parseInt(MAX_PRINT) + 1).toString());
    }
    else{
      //console.log('3');
      let el = {
                id: parseInt(id),
                bcref: bcref,
                cliref: cliref,
                typedorp: ptypedorp,
                wfcode: pwfcode,
                wfdesc: pwfdesc
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
function runjsPartnerGrid(){
  let fields;
  let listToUpd = new Array();
  listToUpd.push('print-dash');
  listToUpd.push('all-print-dash');
  listToUpd.push('re-init-print-dash');
  listToUpd.push('re-init-dash');

  if(window.screen.availWidth < 1100){
    // Manage button
    fromMDSizetoSM(listToUpd);

    //if small we remove some columns
    responsivefields = [
        { name: "ref_tag",
          title: "Référence",
          type: "text",
          align: "right",
          width: 50,
          headercss: "h-jsG-r",
          itemTemplate: function(value, item) {
            return '<i class="monosp-ft">' + value + '</i>';

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
        { name: "step_short",
          title: "Status",
          type: "text",
          width: 33,
          headercss: "h-jsG-l"
        },
        { name: "oclient_ref",
          title: 'Client',
          type: "text",
          width: 38,
          headercss: "h-jsG-l",
          itemTemplate: function(value, item) {
            return ((item.ald_print == 'Y') ? value + '&nbsp;<i class="printed fas fa-print"></i>' : value);
          }
        },
        {
          name: "bcdescription",
          title: "Description",
          type: "text",
          headercss: "h-jsG-l",
          itemTemplate: function(value, item) {
            return ((value == null) ? '-' : value.substring(0, STR_LENGTH_MD));
          }
        },
        {
          name: "id",
          title: '<i class="fas fa-print"></i>',
          type: "string",
          align: "left",
          width: 25,
          itemTemplate: function(value, item) {
            return '<button id="print-bc-' + value + '" class="btn btn-default' + (item.print == 'U' ? '' : '-light') + ' btn-sm btn-block btn-print-mng" data-order="' + item.print + '" value="' + value + '">' + '<i class="fas fa-print"></i>' + '</button>';
          }
        },
        { name: "diff_days",
          title: '<i class="fas fa-stopwatch"></i>',
          type: "number",
          width: 3,
          headercss: "h-jsG-c",
          itemTemplate: function(value, item) {
            return '<p class="center">' + value + '</p>';
          }
        }
    ];
  }
  else{

    fromSMSizetoMD(listToUpd);
    // We are in big screens !
    responsivefields = [
        { name: "ref_tag",
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
        { name: "type_pack",
          title: '<i class="fas fa-qrcode"></i>',
          type: "text",
          align: "center",
          width: 10,
          headercss: "h-jsG-c",
          itemTemplate: function(value, item) {
            return (value == 'D') ? '<i class="c-w fas fa-box"></i>' : '<i class="c-b fas fa-truck"></i>';
          }
        },
        //Default width is auto
        { name: "step_short",
          title: "Status",
          type: "text",
          width: 33,
          headercss: "h-jsG-l"
        },
        { name: "oclient_ref",
          title: 'Client',
          type: "text",
          width: 38,
          headercss: "h-jsG-l",
          itemTemplate: function(value, item) {
            return ((item.ald_print == 'Y') ? value + '&nbsp;<i class="printed fas fa-print"></i>' : value);
          }
        },
        {
          name: "oname",
          title: "Nom",
          type: "text",
          width: 60,
          headercss: "h-jsG-l",
          itemTemplate: function(value, item) {
            return value.substring(0, STR_LENGTH_LG);
          }
        },
        {
          name: "ofirstname",
          title: "Prénom",
          type: "text",
          width: 25,
          headercss: "h-jsG-l",
          itemTemplate: function(value, item) {
            // print U is for Unpring
            // print P is for Print
            // onclick="printMngOrder(' + value + ', "' + item.print + '")"
            return value.substring(0, STR_LENGTH_SM);
          }
        },
        {
          name: "bcdescription",
          title: "Description",
          type: "text",
          headercss: "h-jsG-l",
          itemTemplate: function(value, item) {
            // print U is for Unpring
            // print P is for Print
            // onclick="printMngOrder(' + value + ', "' + item.print + '")"
            return ((value == null) ? '-' : value.substring(0, STR_LENGTH_MD));
          }
        },
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
          name: "id",
          title: '<i class="fas fa-print"></i>',
          type: "string",
          align: "left",
          width: 25,
          itemTemplate: function(value, item) {
            // print U is for Unpring
            // print P is for Print
            // onclick="printMngOrder(' + value + ', "' + item.print + '")"
            return '<button id="print-bc-' + value + '" class="btn btn-default' + (item.print == 'U' ? '' : '-light') + ' btn-sm btn-block btn-print-mng" data-order="' + item.print + '" value="' + value + '">' + '<i class="fas fa-print"></i>' + '</button>';
          }
        }
    ];
  }
  // Options ------------------------------------
  // Handle here all the options
  if($('#hdl_price-su').html() == 'Y'){
    let columnPaid = {
      name: "paid_code",
      title: '<i class="fas fa-receipt"></i>',
      type: "number",
      width: 3,
      headercss: "h-jsG-c",
      itemTemplate: function(value, item) {
        return '<p class="center">' + value + '</p>';
      }
    };
    responsivefields.push(columnPaid);
  };

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
             printMngOrder(args.item.id, args.item.print, args.item.ref_tag, args.item.oclient_ref, args.item.type_pack, args.item.rfw_code, args.item.rfw_desc);
          }
          else{
            //console.log('OUT btn-print-mng');
            goToPartBarcode(args.item.id, args.item.secure);
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
  /*
  console.log('size jsonArray: ' + dataTagToJsonArray.length);
  console.log('size of filter De la Cannelle: ' +
            dataTagToJsonArray.filter(function (el) {
                return el.raw_data.includes('De la Cannelle')
            }).length)
            */
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

  runjsPartnerGrid();
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

  runjsPartnerGrid();
}


/***********************************************************************************************************/

function generatePartDashCSV(){
	const csvContentType = "data:text/csv;charset=utf-8,";
  let csvContent = "";
  const SEP_ = ";"

	let dataString = "#" + SEP_ + "Référence" + SEP_ + "Status" + SEP_ + "Nom" + SEP_ + "Prénom" + SEP_ + "Numéro" + SEP_ + "Description" + SEP_ + "Date de création" + SEP_ + "En attente depuis" + SEP_ + "\n";
	csvContent += dataString;
	for(var i=0; i<dataTagToJsonArray.length; i++){
		dataString = dataTagToJsonArray[i].id + SEP_ + removeDiacritics(dataTagToJsonArray[i].ref_tag) + SEP_ + removeDiacritics(dataTagToJsonArray[i].step) + SEP_ +  dataTagToJsonArray[i].oname + SEP_ +  dataTagToJsonArray[i].ofirstname + SEP_ + dataTagToJsonArray[i].ophone + SEP_ + (dataTagToJsonArray[i].bcdescription == null ? '-' : dataTagToJsonArray[i].bcdescription) + SEP_ + dataTagToJsonArray[i].create_date + SEP_ +   dataTagToJsonArray[i].diff_days + SEP_ ;
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
  link.download = 'suiviListeMGSuiviPartenaire.csv';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}
