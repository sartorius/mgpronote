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
