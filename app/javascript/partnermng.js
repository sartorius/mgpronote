$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  //console.log('Partn TBL Page as changed');
  mainPartnLoaderInCaseOfChange();
})

function mainPartnLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'pardash-gr'){
    runjsPartnerGrid();
    $( "#mgs-dash-print-csv" ).click(function() {
      generatePartDashCSV();
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
      $('#bc-ref-del').html(getBarcodeMGS);
      $('#del-add-ex').html(getBarcodeMGS);

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

/* JS GRID */
function runjsPartnerGrid(){
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
          goToPartBarcode(args.item.id, args.item.secure)
        },

        data: dataTagToJsonArray,

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
                return (value == 'D') ? '<i class="c-w glyphicon glyphicon-home"></i>' : '<i class="c-b glyphicon glyphicon-arrow-up"></i>';
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
                return '<i class="monosp-ft-xs">' + ((value == null) ? '-' : value) + '</i>';
              }
            },
            { name: "oname", title: "Nom", type: "text", width: 70, headercss: "h-jsG-l" },
            { name: "ofirstname", title: "Prénom", type: "text", width: 25, headercss: "h-jsG-l" },
            { name: "ophone", title: '<i class="glyphicon glyphicon-phone-alt"></i>', type: "text", width: 35, headercss: "h-jsG-c" },
            { name: "create_date", title: "Créé le", type: "text", width: 30, headercss: "h-jsG-l" },
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



/***********************************************************************************************************/

function generatePartDashCSV(){
	let csvContent = "data:text/csv;charset=utf-8,";

	let dataString = "#;Référence;Status;Nom;Prénom;Numéro;Date de création;En attente depuis;\n";
	csvContent += dataString;
	for(var i=0; i<dataTagToJsonArray.length; i++){
		dataString = dataTagToJsonArray[i].id + ';' + removeDiacritics(dataTagToJsonArray[i].ref_tag) + ';' + removeDiacritics(dataTagToJsonArray[i].step) + ';' +  dataTagToJsonArray[i].oname + ';' +  dataTagToJsonArray[i].ofirstname + ';' + dataTagToJsonArray[i].ophone + ';' + dataTagToJsonArray[i].create_date + ';' +   dataTagToJsonArray[i].diff_days + ';' ;
    // easy close here
    csvContent += i < dataTagToJsonArray.length ? dataString+ "\n" : dataString;
	}
	//var encodedUri = encodeURI(csvContent);
	//window.open(encodedUri);

	var encodedUri = encodeURI(csvContent);
	var link = document.createElement("a");
	link.setAttribute("href", encodedUri);
	link.setAttribute("download", 'CodesbarresListe.csv');
	document.body.appendChild(link); // Required for FF

	link.click(); // This will download the data file named "my_data.csv".
}
