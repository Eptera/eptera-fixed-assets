import '../../Globals/index.dart';
import 'package:flutter/material.dart';

class Counting_LocationDetails extends StatefulWidget {
  @override
  _Counting_LocationDetailsState createState() => _Counting_LocationDetailsState();
}

class _Counting_LocationDetailsState extends State<Counting_LocationDetails> {
  final service = GetIt.I<Counting_LocationService>();

  late StreamSubscription barcodeListener;
  bool firstRun = true;

  @override
  void initState() {
    super.initState();
    service.currentList$.value = {};

    if (fixAssets_byLocation$.value[service.selectedLocation$.value?.id] != null) {
      fixAssets_byLocation$.value[service.selectedLocation$.value?.id]!.forEach((e) {
        if (e.barcodeID != null) {
          if (e.isScannedInApp == true) {
            service.currentList$.value[e.barcodeID!] = true;
          } else {
            service.currentList$.value[e.barcodeID!] = false;
          }
        }
      });
    }

    service.currentList$.add(service.currentList$.value);

    barcodeListener = lastBarcode$.listen((barcode) async {
      print('SECOND LISTENER WORKINGG');
      if (scannerBusy.value == false) {
        scannerBusy.add(true);
        if (firstRun) {
          firstRun = false;
          print("First Time.");
        } else {
          if (fixAssets_byBarcode$.value[barcode] != null) {
            var approved = true;
            if (fixAssets_byBarcode$.value[barcode]!.barkodeList?[barcode]?.locationId != service.selectedLocation$.value?.id) {
              approved = false;
              approved = await makeFastTransfer(
                barcode,
                fixAssetsLocations$.value[fixAssets_byBarcode$.value[barcode]?.barkodeList?[barcode]?.locationId],
                service.selectedLocation$.value,
                fixAssets_byBarcode$.value[barcode],
              );

              print(approved.toString());
              if (approved) {
                if (fixAssetsLocations$.value[fixAssets_byBarcode$.value[barcode]!.barkodeList?[barcode]?.locationId]?.id != null && service.selectedLocation$.value?.id != null) {
                  return;
                }
                await GetIt.I<TransferService>().fastTransfer(
                  fixAssets_byBarcode$.value[barcode]!,
                  fixAssetsLocations$.value[fixAssets_byBarcode$.value[barcode]!.barkodeList![barcode]!.locationId]!.id!,
                  service.selectedLocation$.value!.id!,
                );
                fixAssets_byLocation$.value[fixAssets_byBarcode$.value[barcode]!.barkodeList![barcode]!.locationId]!.removeWhere((e) => e.barcode == barcode);
                fixAssets_byLocation$.value[service.selectedLocation$.value!.id]!.add(fixAssets_byBarcode$.value[barcode]!);
                fixAssets$.value[fixAssets_byBarcode$.value[barcode]!.id]!.barkodeList![barcode]!.locationId = service.selectedLocation$.value!.id;
                fixAssets_byBarcode$.value[barcode]!.barkodeList![barcode]!.locationId = service.selectedLocation$.value!.id;
                approved = true;

                var oldList = service.currentList$.value;
                service.currentList$.value = {};

                fixAssets_byLocation$.value[service.selectedLocation$.value!.id]!.forEach((e) {
                  if (service.currentList$.value[e.barcodeID] == null && e.barcodeID != null) service.currentList$.value[e.barcodeID!] = oldList[e.barcodeID!] ?? false;
                });
              }
            }
            if (approved) {
              service.currentList$.add(service.currentList$.value);
              if (service.currentList$.value.containsKey(fixAssets_byBarcode$.value[barcode]?.barcodeID)) {
                service.currentList$.value[fixAssets_byBarcode$.value[barcode]!.barcodeID!] = true;

                service.currentList$.add(service.currentList$.value);
              } else {
                showErrorDialog("This Item doesn't exist in this location".tr());
              }
            }
          }
        }
        scannerBusy.add(false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    barcodeListener.cancel();
    fixAssets_byLocation$.value.removeWhere((key, value) => value.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          service.selectedLocation$.value?.name ?? "",
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Counting Note".tr(),
                ),
                onChanged: (value) {
                  service.note$.value = value;
                },
              ),
            ),
            StreamBuilder(
                stream: Rx.combineLatest3(service.currentList$.stream, fixAssets_byBarcodeID$.stream, fixAssets_byBarcode$.stream, (a, b, c) => null),
                builder: (context, snapshot) {
                  return ListView.separated(
                    padding: EdgeInsets.only(bottom: 90),
                    itemCount: service.currentList$.value.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => ListTile(
                      title: Text(fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]?.name ?? '-'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]?.barcode != null
                              ? "${"Barcode".tr()} : ${fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]!.barcode}"
                              : "${"Barcode ID".tr()} : ${fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]!.barcodeID}"),
                          (fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]?.readingDate != null &&
                                  (!service.currentList$.value.values.toList()[index]))
                              ? Text(
                                  "${"Last Scanned Date".tr()} : ${Moment.fromDate(fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]!.readingDate!).format("yyyy-MM-dd HH:mm")}")
                              : Text(
                                  "${"Last Scanned Date".tr()} : ",
                                  style: TextStyle(color: Colors.transparent),
                                )
                        ],
                      ),
                      trailing: InkWell(
                        onTap: () {
                          // setState(() {
                          service.currentList$.value[service.currentList$.value.keys.toList()[index]] = !service.currentList$.value.values.toList()[index];
                          service.currentList$.add(service.currentList$.value);
                          // });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: service.currentList$.value.values.toList()[index]
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.greenAccent,
                                  size: w / 10,
                                )
                              : fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]?.readingDate != null
                                  ? Container(
                                      width: w / 10,
                                      height: w / 10,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.green,
                                          ),
                                          color: Colors.green[50]),
                                    )
                                  : Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.redAccent,
                                      size: w / 10,
                                    ),
                        ),
                      ),
                      contentPadding: EdgeInsets.only(left: 10, right: 0),
                      minVerticalPadding: 0,
                      onTap: null,
                    ),
                    separatorBuilder: (context, index) => Divider(height: 1),
                  );
                }),
            SizedBox(
              height: h * 0.1,
            ),
          ],
        ),
      ),
      floatingActionButton: UnicornDialer(
        finalButtonIcon: Icon(Icons.clear),
        parentButton: Icon(Icons.menu),
        parentButtonBackground: Colors.blueGrey,
        hasBackground: true,
        backgroundColor: Colors.black12,
        orientation: 1,
        childPadding: 20,
        childButtons: [
          UnicornButton(
            null,
            null,
            null,
            hasLabel: true,
            labelText: "${"Save Counting".tr()}${isOffline$.value ? " Offline" : ""}",
            currentButton: FloatingActionButton(
              heroTag: "upload2",
              mini: true,
              child: Icon(Icons.upload_rounded),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    isOffline$.value
                        ? db
                            .sendLocationCountingDataOffline(
                            currentList: service.currentList$.value,
                            selectedLocation: service.selectedLocation$.value,
                            note: service.note$.value,
                          )
                            .then((v) {
                            Navigator.pop(context);
                          })
                        : db
                            .sendLocationCountingDataOnline(
                            currentList: service.currentList$.value,
                            selectedLocation: service.selectedLocation$.value,
                            note: service.note$.value,
                          )
                            .then((v) {
                            Navigator.pop(context);
                          });
                    return Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
