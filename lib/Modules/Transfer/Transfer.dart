import 'package:flutter/services.dart';
import '../../Globals/index.dart';
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

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kWhite,
    ));

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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: SvgPicture.asset("assets/images/appbarLogo.svg"),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: kGrey700,
            )),
        actions: [
          if (cameraModeIsActive$.value == true)
            IconButton(
              icon: SvgPicture.asset("assets/images/camera.svg"),
              onPressed: () async {
                var barcode = await scanner.scanBarcodeNormal();
                lastBarcode$.add(barcode);
              },
            ),
        ],
      ),
      body: StreamBuilder(
          stream: Rx.combineLatest6(service.dateTime$, service.transferType$, service.from$, service.to$, service.fixedAssetItem$, service.selectedStaff$, (a, b, c, d, e, f) {}),
          builder: (context, snapshot) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.only(
                        top: 20,
                        left: 16,
                        right: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Transfer".tr(),
                            style: k24w600Black(color: kGrey900),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Fixed Asset".tr(),
                                  style: k14w500Black(
                                    color: kGrey700,
                                  )),
                              SizedBox(
                                height: 6,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  var result = await showSearchWidget_FixedAssetName();
                                  if (result != null && result.barkodeList != null) {
                                    if (!(result.renewable == true)) {
                                      if (result.barkodeList!.values.toList().isNotEmpty) {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => FixedAssetBarcodes(result.barkodeList!.values.toList()))).then((value) {
                                          currentContext = context;
                                          if (value != null) {
                                            result.barcode = value.barcode;
                                            service.fixedAssetItem$.add(result);

                                            service.from$.value = fixAssetsLocations$.value[value.locationId];
                                            service.from$.add(service.from$.value);
                                          }
                                        });
                                      }
                                    } else {
                                      service.fixedAssetItem$.add(result);
                                      service.from$.value = fixAssetsLocations$.value[result.locId];
                                      service.from$.add(service.from$.value);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(minimumSize: Size(w - 64, 44), primary: kWhite, side: BorderSide(color: kBorderColor)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      service.fixedAssetItem$.value?.name ?? "-",
                                      style: k14w500Black(color: kGrey700),
                                    ),
                                    SvgPicture.asset("assets/images/arrow_down.svg")
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Wrap(
                              runSpacing: 16,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorderColor2)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            service.transferType$.add(12);
                                            qty.text = "1";
                                            service.to$.add(null);
                                          },
                                          child: (service.transferType$.value == 12)
                                              ? Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: kShadowColor,
                                                        blurRadius: 2,
                                                        offset: Offset(0, 1),
                                                        spreadRadius: 0,
                                                      ),
                                                      BoxShadow(
                                                        color: Color(0x19101828),
                                                        blurRadius: 3,
                                                        offset: Offset(0, 1),
                                                        spreadRadius: 0,
                                                      )
                                                    ],
                                                  ),
                                                  child: Text(
                                                    "Transfer".tr(),
                                                    style: TextStyle(fontSize: w / 36, fontWeight: FontWeight.w600, color: kGrey700),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                              : Text(
                                                  "Transfer".tr(),
                                                  style: TextStyle(fontSize: w / 36, fontWeight: FontWeight.w600, color: kGrey500),
                                                  textAlign: TextAlign.center,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            service.transferType$.add(15);
                                            qty.text = "1";
                                            service.to$.add(null);
                                          },
                                          child: (service.transferType$.value == 15)
                                              ? Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: kShadowColor,
                                                        blurRadius: 2,
                                                        offset: Offset(0, 1),
                                                        spreadRadius: 0,
                                                      ),
                                                      BoxShadow(
                                                        color: Color(0x19101828),
                                                        blurRadius: 3,
                                                        offset: Offset(0, 1),
                                                        spreadRadius: 0,
                                                      )
                                                    ],
                                                  ),
                                                  child: Text(
                                                    "Loss".tr(),
                                                    style: TextStyle(fontSize: w / 36, fontWeight: FontWeight.w600, color: kGrey700),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                              : Text(
                                                  "Loss".tr(),
                                                  style: TextStyle(fontSize: w / 36, fontWeight: FontWeight.w600, color: kGrey500),
                                                  textAlign: TextAlign.center,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            service.transferType$.add(13);
                                            qty.text = "1";
                                            service.to$.add(null);
                                          },
                                          child: (service.transferType$.value == 13)
                                              ? Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: kShadowColor,
                                                        blurRadius: 2,
                                                        offset: Offset(0, 1),
                                                        spreadRadius: 0,
                                                      ),
                                                      BoxShadow(
                                                        color: Color(0x19101828),
                                                        blurRadius: 3,
                                                        offset: Offset(0, 1),
                                                        spreadRadius: 0,
                                                      )
                                                    ],
                                                  ),
                                                  child: Text(
                                                    "Scrap".tr(),
                                                    style: TextStyle(fontSize: w / 36, fontWeight: FontWeight.w600, color: kGrey700),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                              : Text(
                                                  "Scrap".tr(),
                                                  style: TextStyle(fontSize: w / 36, fontWeight: FontWeight.w600, color: kGrey500),
                                                  textAlign: TextAlign.center,
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Transfer Time".tr(),
                                        style: k14w500Black(
                                          color: kGrey700,
                                        )),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    StreamBuilder(
                                        stream: service.dateTime$.stream,
                                        builder: (context, snapshot) {
                                          return InkWell(
                                            child: Container(
                                              padding: EdgeInsets.only(left: 16, top: 10, right: 16, bottom: 10),
                                              decoration: BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                  color: Color(0x0C101828),
                                                  blurRadius: 2,
                                                  offset: Offset(0, 1),
                                                  spreadRadius: 0,
                                                )
                                              ], color: kWhite, borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorderColor)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset("assets/images/calendar.svg"),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Text(
                                                    "${DateFormat("MMM dd, yyyy - HH:mm", Localizations.localeOf(context).toString()).format(service.dateTime$.value)}",
                                                    style: k14w600Black(color: kGrey700),
                                                  )
                                                ],
                                              ),
                                            ),
                                            onTap: () async {
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
                                          );
                                        }),
                                  ],
                                ),
                                if (service.transferType$.value == 12)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Responsible Staff".tr(),
                                          style: k14w500Black(
                                            color: kGrey700,
                                          )),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          var result = await showSearchWidget_ResponsibleStaffName();
                                          if (result != null) {
                                            service.selectedStaff$.add(result);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(minimumSize: Size(w - 64, 44), primary: kWhite, side: BorderSide(color: kBorderColor)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              service.selectedStaff$.value?.name ?? "-",
                                              style: k14w500Black(color: kGrey700),
                                            ),
                                            SvgPicture.asset("assets/images/arrow_down.svg")
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                // InkWell(
                                //   onTap: () async {
                                //     var result = await showSearchWidget_ResponsibleStaffName();
                                //     if (result != null) {
                                //       service.selectedStaff$.add(result);
                                //     }
                                //   },
                                //   child: Container(
                                //     height: 50,
                                //     decoration: BoxDecoration(
                                //         color: Colors.white, borderRadius: BorderRadius.circular(5), boxShadow: [BoxShadow(color: Colors.black12, offset: Offset.zero, blurRadius: 3, spreadRadius: 2)]),
                                //     padding: EdgeInsets.all(5),
                                //     child: Row(
                                //       children: [
                                //         Expanded(
                                //           flex: 4,
                                //           child: Center(
                                //             child: Text(
                                //               "Responsible Staff".tr(),
                                //               style: TextStyle(fontSize: 16),
                                //             ),
                                //           ),
                                //         ),
                                //         SizedBox(width: 20),
                                //         Expanded(
                                //           flex: 5,
                                //           child: Center(
                                //               child: Text(
                                //                 service.selectedStaff$.value?.name ?? "-",
                                //                 textAlign: TextAlign.center,
                                //                 style: TextStyle(color: Colors.black87, fontSize: 16),
                                //               )),
                                //         ),
                                //         Icon(Icons.keyboard_arrow_down_rounded)
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                if (service.transferType$.value == 12)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("From".tr(),
                                          style: k14w500Black(
                                            color: kGrey700,
                                          )),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          var result = await showSearchWidget_FixedAssetsLocationName();
                                          if (result != null) {
                                            service.from$.add(result);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(minimumSize: Size(w - 64, 44), primary: kWhite, side: BorderSide(color: kBorderColor)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              service.from$.value != null ? service.from$.value!.name! : "-",
                                              style: k14w500Black(color: kGrey700),
                                            ),
                                            SvgPicture.asset("assets/images/arrow_down.svg")
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                if (service.transferType$.value == 12)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("To".tr(),
                                          style: k14w500Black(
                                            color: kGrey700,
                                          )),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          var result = await showSearchWidget_FixedAssetsLocationName();
                                          if (result != null) {
                                            service.to$.add(result);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(minimumSize: Size(w - 64, 44), primary: kWhite, side: BorderSide(color: kBorderColor)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              service.to$.value != null ? service.to$.value!.name! : "-",
                                              style: k14w500Black(color: kGrey700),
                                            ),
                                            SvgPicture.asset("assets/images/arrow_down.svg")
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Quantity".tr(),
                                        style: k14w500Black(
                                          color: kGrey700,
                                        )),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: kWhite),
                                      child: CTextFormField(
                                        textInputAction: TextInputAction.done,
                                        controller: qty,
                                        hasIcon: false,
                                        onChange: (value) {},
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: h * 0.2,
                          )
                        ],
                      )),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: kWhite,
                            border: Border(
                              top: BorderSide(color: kBorderColor2),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 32,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  height: 16,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: ElevatedButton(
                                      onPressed: !validator()
                                          ? null
                                          : () async {
                                              if (double.parse(qty.text) > 0.0) {
                                                service.qty$.add(double.parse(qty.text == "" ? "0.0" : qty.text));
                                                await showLoadingDialog(service.addTransfer()).then((value) {
                                                  if (value.success == true) {
                                                    service.to$.value = (null);
                                                    service.from$.value = (null);
                                                    service.fixedAssetItem$.add(null);
                                                    service.selectedStaff$.add(null);
                                                    kShowBanner(BannerType.SUCCESS, "Success".tr(), "Transaction inserted successfully".tr(), context);
                                                  } else {
                                                    kShowBanner(BannerType.ERROR, "Error".tr(), (value.message ?? "An error occurred while inserting the transaction".tr()), context);
                                                  }
                                                });
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                          primary: validator() ? kPrimaryColor : kBorderColor2,
                                          side: BorderSide(
                                            color: validator() ? kPrimaryColor : kBorderColor2,
                                          )),
                                      child: Text(
                                        "Submit".tr(),
                                        style: k16w600Black(color: validator() ? kWhite : kBorderColor),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }

  bool validator() {
    return service.fixedAssetItem$.value != null &&
        service.from$.value != null &&
        (service.transferType$.value == 12 ? service.to$.value != null : true) &&
        (!(service.fixedAssetItem$.value?.renewable == true) ? (service.transferType$.value == 12 ? service.selectedStaff$.value != null : true) : true);
  }
}
