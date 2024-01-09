import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Globals/index.dart';

class Scanner implements ScannerCallback {
  HoneywellScanner honeywellScanner = HoneywellScanner();


  Scanner() {

    honeywellScanner = HoneywellScanner(scannerCallback: this);
    updateScanProperties();
    honeywellScanner.startScanner();

  }
  updateScanProperties() {
    List<CodeFormat> codeFormats = [];
    codeFormats.addAll(CodeFormatUtils.ALL_1D_FORMATS);
    codeFormats.addAll(CodeFormatUtils.ALL_2D_FORMATS);
    honeywellScanner.setProperties(CodeFormatUtils.getAsPropertiesComplement(codeFormats));

  }

  @override
  Future<void> onDecoded(ScannedData? scannedBarcode) async {
    try {
      String? barcode = scannedBarcode?.code;

      lastBarcode$.add(barcode ?? "");
      print(barcode);
      print("Last Barcode Has Listener : ${lastBarcode$.hasListener}");
      print("Scanner Busy : ${scannerBusy.value}");
      if (!lastBarcode$.hasListener) {
        await showWarningDialog("Stock Info".tr(), "Name".tr() + " : ${fixAssets_byBarcode$.value[barcode]?.name ?? ""}");
      }
    } on Exception catch (e) {
      scannerBusy.add(false);
      await showErrorDialog(e.toString());
    }
  }

  @override
  void onError(Exception error) {
    print(error.toString());
  }

  Future<String> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.BARCODE);
      pool.play(await pool.load(await rootBundle.load("assets/sound/beep-07.mp3")));
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.'.tr();
    }
    // if (!mounted) return "";
    return barcodeScanRes;
  }

  disableScanner() {
    scannerBusy.add(!scannerBusy.value);
  }
}
