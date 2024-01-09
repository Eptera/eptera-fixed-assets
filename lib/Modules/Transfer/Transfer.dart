import '../../Globals/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Transfer extends StatefulWidget {
  @override
  _TransferState createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  final service = GetIt.I<TransferService>();

  TextEditingController qty = TextEditingController(text: "1");

  late StreamSubscription barcodeListener;
  bool firstRun = true;

  @override
  void initState() {
    super.initState();

    barcodeListener = lastBarcode$.listen((barcode) async {
      if (scannerBusy.value == false && service.transferType$.value != 15) {
        scannerBusy.add(true);
        if (firstRun) {
          firstRun = false;
          print("First Time.");
        } else {
          service.fixedAssetItem$.add(fixAssets_byBarcode$.value[barcode]);
          service.from$.add(fixAssetsLocations$.value[fixAssets_byBarcode$.value[barcode]?.barkodeList?[barcode]?.locationId]);
        }
        scannerBusy.add(false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    barcodeListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    EdgeInsets padding = MediaQuery.of(context).padding;

    return Scaffold(
      appBar: AppBar(
        title: Text("Transfer".tr()),
        actions: [
          if (cameraModeIsActive$.value == true)
            IconButton(
              icon: const Icon(Icons.camera_alt_rounded),
              onPressed: () async {
                var barcode = await scanner.scanBarcodeNormal();
                lastBarcode$.add(barcode);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 100 + padding.bottom),
          child: StreamBuilder(
              stream:
                  Rx.combineLatest6(service.dateTime$, service.transferType$, service.from$, service.to$, service.fixedAssetItem$, service.selectedStaff$, (a, b, c, d, e, f) {}),
              builder: (context, snapshot) {
                return Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          var result = await showSearchWidget_FixedAssetName();
                          if (result != null && result.barkodeList != null) {
                            if (!(result.renewable == true)) {
                              if (result.barkodeList!.values.toList().isNotEmpty) {
                                var barcodeItem = await showSearchWidget_FixedAssetBarcodes(result.barkodeList!.values.toList());
                                if (barcodeItem != null) {
                                  result.barcode = barcodeItem.barcode;
                                  service.fixedAssetItem$.add(result);

                                  service.from$.value = fixAssetsLocations$.value[barcodeItem.locationId];
                                  service.from$.add(service.from$.value);
                                }
                              }
                            } else {
                              service.fixedAssetItem$.add(result);
                              service.from$.value = fixAssetsLocations$.value[result.locId];
                              service.from$.add(service.from$.value);
                            }
                          }
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [BoxShadow(color: Colors.black12, offset: Offset.zero, blurRadius: 3, spreadRadius: 2)]),
                          padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: Text(
                                    "Fixed Asset".tr(),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 5,
                                child: Center(
                                    child: Text(
                                  service.fixedAssetItem$.value?.name ?? "-",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black87, fontSize: 16),
                                )),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded)
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [BoxShadow(color: Colors.black12, offset: Offset.zero, blurRadius: 3, spreadRadius: 2)]),
                        child: CupertinoSlidingSegmentedControl(
                          groupValue: service.transferType$.value,
                          children: {
                            12: Padding(padding: EdgeInsets.all(15), child: Text("Transfer".tr())),
                            15: Padding(padding: EdgeInsets.all(15), child: Text("Loss".tr())),
                            13: Padding(padding: EdgeInsets.all(15), child: Text("Scrap".tr())),
                          },
                          onValueChanged: (value) {
                            service.transferType$.value = (value ?? 12);
                            qty.text = "1";
                            service.to$.add(null);
                            //TODO: Alarko için kapatıldı. Daha sonrasında görüşülüp karar verilecek.
                            // if (service.transferType$.value == 15) {
                            //   service.fixedAssetItem$.add(null);
                            //   service.from$.add(null);
                            // }
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          DatePicker.showDateTimePicker(
                            context,
                            showTitleActions: true,
                            currentTime: DateTime.now(),
                            minTime: DateTime.now(),
                            maxTime: DateTime.now().add(Duration(days: 550)),
                            onConfirm: (date) {
                              service.dateTime$.add(date);
                            },
                          );
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [BoxShadow(color: Colors.black12, offset: Offset.zero, blurRadius: 3, spreadRadius: 2)]),
                          padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Center(
                                  child: Text(
                                    "Date Time".tr(),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                flex: 5,
                                child: Center(
                                    child: Text(
                DateFormat("dd-MM-yyyy HH:mm").format(service.dateTime$.value),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black87, fontSize: 16),
                                )),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded)
                            ],
                          ),
                        ),
                      ),
                      if (service.transferType$.value == 12) SizedBox(height: 10),
                      if (service.transferType$.value == 12)
                        InkWell(
                          onTap: () async {
                            var result = await showSearchWidget_ResponsibleStaffName();
                            if (result != null) {
                              service.selectedStaff$.add(result);
                            }
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [BoxShadow(color: Colors.black12, offset: Offset.zero, blurRadius: 3, spreadRadius: 2)]),
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Center(
                                    child: Text(
                                      "Responsible Staff".tr(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  flex: 5,
                                  child: Center(
                                      child: Text(
                                    service.selectedStaff$.value?.name ?? "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black87, fontSize: 16),
                                  )),
                                ),
                                Icon(Icons.keyboard_arrow_down_rounded)
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () async {
                          var result = await showSearchWidget_FixedAssetsLocationName();
                          if (result != null) {
                            service.from$.add(result);
                          }
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [BoxShadow(color: Colors.black12, offset: Offset.zero, blurRadius: 3, spreadRadius: 2)]),
                          padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Center(
                                  child: Text(
                                    "From".tr(),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                flex: 5,
                                child: Center(
                                    child: Text(
                                  service.from$.value != null ? service.from$.value!.name! : "-",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black87, fontSize: 16),
                                )),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded)
                            ],
                          ),
                        ),
                      ),
                      if (service.transferType$.value == 12) SizedBox(height: 10),
                      if (service.transferType$.value == 12)
                        InkWell(
                          onTap: () async {
                            var result = await showSearchWidget_FixedAssetsLocationName();
                            if (result != null) {
                              service.to$.add(result);
                            }
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [BoxShadow(color: Colors.black12, offset: Offset.zero, blurRadius: 3, spreadRadius: 2)]),
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Center(
                                    child: Text(
                                      "To".tr(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  flex: 5,
                                  child: Center(
                                      child: Text(
                                    service.to$.value != null ? service.to$.value!.name! : "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black87, fontSize: 16),
                                  )),
                                ),
                                Icon(Icons.keyboard_arrow_down_rounded)
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [BoxShadow(color: Colors.black12, offset: Offset.zero, blurRadius: 3, spreadRadius: 2)]),
                          padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Center(
                                  child: Text(
                                    "Quantity".tr(),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                flex: 5,
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  controller: qty,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: !validator()
                            ? null
                            : () async {
                                if (double.parse(qty.text) > 0.0) {
                                  service.qty$.add(double.parse(qty.text == "" ? "0.0" : qty.text));
                                  await showLoadingDialog(service.addTransfer()).then((value) {
                                    if (value.success == true) {
                                      service.to$.value = (null);
                                      service.from$.value = (null);
                                      service.fixedAssetItem$.add(null);
                                      showWarningDialog(tr(value.message!), "Transaction Inserted Successfully".tr());
                                    }else{
                                       showWarningDialog("Error".tr(),tr(value.message!));
                                    }
                                  });
                                }
                              },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: validator() ? Colors.greenAccent : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [BoxShadow(color: Colors.black12, offset: Offset.zero, blurRadius: 3, spreadRadius: 2)],
                          ),
                          child: Center(
                            child: Text(
                              "Submit".tr(),
                              style: TextStyle(
                                fontSize: w / 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  bool validator() {
    return service.fixedAssetItem$.value != null &&
        service.from$.value != null &&
        (service.transferType$.value == 12 ? service.to$.value != null : true) &&
        (!(service.fixedAssetItem$.value?.renewable == true) ? (service.transferType$.value == 12 ? service.selectedStaff$.value != null : true) : true);
  }
}
