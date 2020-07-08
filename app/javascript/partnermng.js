$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  //console.log('Partn TBL Page as changed');
  mainPartnLoaderInCaseOfChange();
})

function mainPartnLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'pardash-gr'){

    initDataTagToJsonArrayDashboard();
    printBtnAvailability();
    $( "#print-dash" ).click(function() {
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
      JsBarcode("#mbc-0", getBarcodeMGS);
      $("#btn-print-bc").click(function() {
          //generateCb12PDF();
          dataTagToJsonArray = new Array();
          let oneBarcode = {
            dest_email: dataTagToJsonOneBCArray[0].oemail,
            step: dataTagToJsonOneBCArray[0].step,
          };
          dataTagToJsonArray.push(oneBarcode);
          generateCb12PDF();
      });
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

	var cellSize = 37;
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
    doc.addImage(document.getElementById('mbc-' + i).src, //img src
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
    JsBarcode("#mbc-"+i, dataTagToJsonArray[i].ref_tag);
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

function handlePrint(){
  console.log('handlePrint: ');
  console.log(JSON.stringify(printArray));

  for(i=0; i<printArray.length; i++){
    $("#item-bc-"+i).html(printArray[i].bcref + '<br>' + printArray[i].cliref + '<br>' + $('#part-tech-name').html());
    JsBarcode("#mbc-"+i, printArray[i].bcref);
  }
  generatePrintedPDF();
  //Do not forget to clear Print button
  clearPrint();
}

function generatePrintedPDF(){
	$("body").addClass("loading");
  console.log('Click on generatePrintedPDF');

  var doc = new jsPDF();
	var rowReseter = 1;

  var currentDate = new Date();
  //console.log('current date: ' + currentDate.toLocaleString())


	var cel1_2 = '';
	var cel2 = '';
	var cel3 = '';

  var barcodeWidth = 60;
  var barcodeHeight = 25;

	var startY = 15;
	var sizeY = 20;
	var offsetX = 5;
	var offsetY = 30;

	var cellSize = 37;
	var offsetY2 = 40;
  var offsetTextY2 = 20;
	var offsetBackY = 5;

  //This should be the loop for one page
  //Should not oversize 12
  //rowReseter is the line counter
  //This handle row max is 2
  for(i=0; i<printArray.length; i++){
    let oddOffsetX =  100 * (i % 2);
    let cel1 = '';
    cel1 = cel1 + setCellSize('REF: ' + printArray[i].bcref);
    cel1 = cel1 + setCellSize(' - Client: ' + printArray[i].cliref);
    cel1 = cel1 + " - Appartient à: " + $('#part-tech-name').html();
    let celRef = doc.setFontSize(6).splitTextToSize(cel1 + ' - Imprimé le ' + currentDate.toLocaleString(), cellSize);;
    doc.text(offsetX + oddOffsetX + barcodeWidth + 2, 3 + (offsetY2 + 1)*rowReseter, celRef);


    // addImage(imageData, format, x, y, width, height, alias, compression, rotation)
    doc.addImage(document.getElementById('mbc-' + i).src, //img src
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

  doc.save('MGSuivi_Print');

  $("body").removeClass("loading");
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
  /* THE INIT HAS BEEN DONE IN ERB */
  // filteredDataTagToJsonArray = dataTagToJsonArray;
  runjsPartnerGrid();
}

function fillMaxPrint(){
  clearPrint();
  const MAX_PRINT = parseInt($('#max-print-const').html());


  for(iallP=0; iallP<MAX_PRINT+1; iallP++){
    //console.log('iallP value >>>>>>>>>>>>' + iallP);
    if(iallP<filteredDataTagToJsonArray.length){
      //console.log('fillMaxPrint: ' + filteredDataTagToJsonArray[iallP].id);
      //console.log('printArray.length: ' + printArray.length);
      printMngOrder(filteredDataTagToJsonArray[iallP].id, 'U', filteredDataTagToJsonArray[iallP].ref_tag, filteredDataTagToJsonArray[iallP].oclient_ref);
    }
    else{
      //console.log('ELSE fillMaxPrint: ' + filteredDataTagToJsonArray.length + ' vs ' + iallP);
    }
  }
}

function printMngOrder(id, order, bcref, cliref){
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
                cliref: cliref
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
             printMngOrder(args.item.id, args.item.print, args.item.ref_tag, args.item.oclient_ref);
          }
          else{
            //console.log('OUT btn-print-mng');
            goToPartBarcode(args.item.id, args.item.secure);
          }
        },

        data: filteredDataTagToJsonArray,

        fields: [
            { name: "id", title: "#", type: "number", width: 5, headercss: "h-jsG-r" },
            { name: "ref_tag",
              title: "Référence",
              type: "text",
              align: "right",
              width: 40,
              headercss: "h-jsG-r",
              itemTemplate: function(value, item) {
                return '<i class="monosp-ft">' + value + '</i>';

              }
            },
            { name: "type_pack",
              title: '<i class="glyphicon glyphicon-barcode"></i>',
              type: "text",
              align: "center",
              width: 10,
              headercss: "h-jsG-c",
              itemTemplate: function(value, item) {
                return (value == 'D') ? '<i class="c-w glyphicon glyphicon-stop"></i>' : '<i class="c-b glyphicon glyphicon-move"></i>';
              }
            },
            //Default width is auto
            { name: "step", title: "Status", type: "text", headercss: "h-jsG-l" },
            { name: "ext_ref",
              title: "Ext Ref",
              type: "text",
              align: "right",
              width: 35,
              headercss: "h-jsG-r",
              itemTemplate: function(value, item) {
                return '<i class="monosp-ft-xs">' + ((value == null) ? '-' : value.substring(0, STR_LENGTH_MD)) + '</i>';
              }
            },
            { name: "oclient_ref",
              title: 'Client',
              type: "text",
              width: 38,
              headercss: "h-jsG-l"
            },
            {
              name: "oname",
              title: "Nom",
              type: "text",
              width: 40,
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
              width: 40,
              headercss: "h-jsG-l",
              itemTemplate: function(value, item) {
                // print U is for Unpring
                // print P is for Print
                // onclick="printMngOrder(' + value + ', "' + item.print + '")"
                return ((value == null) ? '-' : value.substring(0, STR_LENGTH_MD));
              }
            },
            {
              name: "id",
              title: '<i class="glyphicon glyphicon-print"></i>',
              type: "string",
              align: "left",
              width: 25,
              itemTemplate: function(value, item) {
                // print U is for Unpring
                // print P is for Print
                // onclick="printMngOrder(' + value + ', "' + item.print + '")"
                return '<button id="print-bc-' + value + '" class="btn btn-default' + (item.print == 'U' ? '' : '-light') + ' btn-sm btn-block btn-print-mng" data-order="' + item.print + '" value="' + value + '">' + '<i class="glyphicon glyphicon-print"></i>' + '</button>';
              }
            },
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
    JsBarcode("#mbc-"+i, '0');
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

	let dataString = "#" + SEP_ + "Référence" + SEP_ + "Status" + SEP_ + "Nom" + SEP_ + "Prénom" + SEP_ + "Numéro" + SEP_ + "Date de création" + SEP_ + "Description" + SEP_ + "En attente depuis" + SEP_ + "\n";
	csvContent += dataString;
	for(var i=0; i<dataTagToJsonArray.length; i++){
		dataString = dataTagToJsonArray[i].id + SEP_ + removeDiacritics(dataTagToJsonArray[i].ref_tag) + SEP_ + removeDiacritics(dataTagToJsonArray[i].step) + SEP_ +  dataTagToJsonArray[i].oname + SEP_ +  dataTagToJsonArray[i].ofirstname + SEP_ + dataTagToJsonArray[i].ophone + SEP_ + dataTagToJsonArray[i].bcdescription + SEP_ + dataTagToJsonArray[i].create_date + SEP_ +   dataTagToJsonArray[i].diff_days + SEP_ ;
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
