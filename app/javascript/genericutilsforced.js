// minify here : https://javascript-minifier.com
const STR_LENGTH_XS = 3;
const STR_LENGTH_SM = 5;
const STR_LENGTH_MD = 10;
const STR_LENGTH_LG = 20;
const STR_LENGTH_XL = 25;
const STR_LENGTH_XXL = 30;
const STR_LENGTH_XXXL = 40;

//Decode barcode
function validateMGSCode(codeTest){
  const re = /^M[A-Z0-9]{8}$/;
  return re.test(codeTest);
};
function decodeMGSCodePartSecure(barcodeTest){
  //console.log(barcodeTest.substring(1));
  //Decode en base 36
  let res = parseInt(barcodeTest.substring(1), 36);
  //230243 > substring(2) 0243
  return parseInt(res.toString().substring(res.toString().length - 4));
};
function decodeMGSCodePartId(barcodeTest){
  //console.log(barcodeTest.substring(1));
  //Decode en base 36
  let res = parseInt(barcodeTest.substring(1), 36);
  //230243 > substring(0,2) 23
  return parseInt(res.toString().substring(0, res.toString().length - 4));
}
//pad(10, 4);      // 0010
function mgspad(n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}

// Be carefull this method exists on Ruby side on pure unhappy duplicate code
function mgsEncode(lid, sec){
  //Go to base 26
  //hexString = yourNumber.toString(16); << 10 to hex
  //yourNumber = parseInt(hexString, 16); << hex to 10
  // The format here is 1 / 345 will be 10345
  let lidPlusSec = parseInt(lid.toString() + mgspad(sec, 4).toString());
  return 'M' + mgspad(lidPlusSec.toString(36), 8).toUpperCase();
}


//Need to promote to generic utils forced?
function mgsEncodeClientRef(fname, lid, ref){
  let lidPlusSec = parseInt(lid.toString() + mgspad(ref, 3).toString()).toString(35);
  let fnameCode = (fname.length == 1) ? fname.substring(0, 1)+'X' : fname.substring(0, 2);
  return (fnameCode + '-' + lidPlusSec).replace(/o/g,"Z").replace(/O/g,"Z").toUpperCase();
}

/*
# We use base 35 and replace O by Z to avoid zero
def encode_client_ref(fname, id, ref)
  if fname.length == 1 then
    return  (fname[0..0] + 'X-' + (id.to_s + ref.to_s.rjust(3, "0")).to_i.to_s(35)).upcase.upcase.gsub(/O/, 'Z')
  end
  return  (fname[0..1] + '-' + (id.to_s + ref.to_s.rjust(3, "0")).to_i.to_s(35)).upcase.gsub(/O/, 'Z')
end
*/


function fromMDSizetoSM(listOfId){
  for(i=0; i<listOfId.length; i++){
    let element = document.getElementById(listOfId[i]);
    element.classList.remove('btn-md');
    element.classList.add('btn-sm');
    //$('#'+listOfId[i]).removeClass('btn-md');
    //$('#'+listOfId[i]).addClass('btn-sm');
  }
}

function fromSMSizetoMD(listOfId){
  for(i=0; i<listOfId.length; i++){
    let element = document.getElementById(listOfId[i]);
    element.classList.remove('btn-sm');
    element.classList.add('btn-md');
    //$('#'+listOfId[i]).removeClass('btn-sm');
    //$('#'+listOfId[i]).addClass('btn-md');
  }
}
