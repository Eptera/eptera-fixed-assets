import 'dart:io';
import 'package:flutter/material.dart';
import 'index.dart';

String? validate<T>(T? value) {
  if (value == null || value is String && (value.isEmpty || value.trim().isEmpty)) {
    return "Please don't leave this field empty".tr();
  }
  return null;
}

Future<bool?> showConfirmDialog(String title, String content, {String? actionText, String? imagePath, Color? buttonColor, Color? imageColor}) async {
  return await showDialog<bool>(
    context: currentContext,
    builder: (context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AlertDialog(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imagePath != null)
                  SvgPicture.asset(
                    imagePath,
                  ),
              ],
            ),
            titlePadding: EdgeInsets.only(left: 16, top: 20, right: 16),
            contentPadding: EdgeInsets.only(left: 16, top: 20, bottom: 24, right: 16),
            actionsPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            insetPadding: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 32),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: k18w600Black(color: Colors.grey[900]),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  content,
                  style: k14w400Black(color: kGrey600),
                ),
              ],
            ),
            actions: [
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      primary: buttonColor ?? kPrimaryColor,
                      side: BorderSide(color: buttonColor ?? kBorderColor),
                    ),
                    child: Text(
                      actionText != null ? tr(actionText) : "Okey".tr(),
                      style: k16w600Black(color: kWhite),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      "Cancel".tr(),
                      style: k16w600Black(color: kGrey700),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: kWhite,
                      side: BorderSide(color: kBorderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      );
    },
  );
}


Future<bool?> showDeleteConfirmDialog() async {
  return await showDialog<bool>(
    context: currentContext,
    builder: (context) {
      return AlertDialog(
        title: Text("Warning".tr()),
        content: Text("Are you sure you want to Delete this Item?".tr()),
        actions: [
          TextButton(
            child: Text("Ok".tr()),
            onPressed: () => Navigator.pop(context, true),
          ),
          TextButton(
            child: Text("Cancel".tr()),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      );
    },
  );
}

Future<bool> checkConnection() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
    return false;
  } on SocketException catch (_) {
    return false;
  }
}

Future<T> showLoadingDialog<T>(Future<T> func) async {
  return await showDialog(
    barrierDismissible: false,
    context: currentContext,
    builder: (context) {
      func.then((v) {
        Navigator.pop(context, v);
      });

      return Container(
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    },
  );
}

Future showWarningDialog(String title, String content) async {
  await showDialog(
      context: currentContext,
      builder: (context) {
        return Container(
          child: AlertDialog(
            title: Text(title),
            contentPadding: const EdgeInsets.all(16.0),
            content: SingleChildScrollView(child: Text(content)),
            actions: <Widget>[
              TextButton(
                  child: Text("OK").tr(),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        );
      });
}

Future showErrorDialog(String? error) async {
  await showDialog(
      context: currentContext,
      builder: (context) {
        return Container(
          child: AlertDialog(
            title: Text("Error".tr()),
            contentPadding: const EdgeInsets.all(16.0),
            content: Text(error ?? ""),
            actions: <Widget>[
              TextButton(
                  child: Text("OK").tr(),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        );
      });
}

Future<String?> showGetBarcodeDialog() {
  return showDialog(
    context: currentContext,
    builder: (context) {
      TextEditingController barcode = TextEditingController();
      return AlertDialog(
        title: Text("Enter Barcode").tr(),
        content: TextField(
          controller: barcode,
          autofocus: true,
          keyboardType: TextInputType.multiline,
        ),
        actions: [
          TextButton(
            child: Text("No".tr(), style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, ""),
          ),
          TextButton(
            child: Text("Yes".tr(), style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.pop(context, barcode.text),
          ),
        ],
      );
    },
  );
}

Future<bool> makeFastTransfer(String barcode, FixAssetLocation? fromLocation, FixAssetLocation? toLocation, FixAsset? fixedAsset) async {
  return await showDialog(
    context: currentContext,
    builder: (context) {
      return AlertDialog(
        title: Text("Fast Transfer".tr()),
        content: Wrap(
          children: [
            Row(children: [Expanded(flex: 3, child: Text("DateTime".tr() + " : ")), Expanded(flex: 5, child: Text("${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}"))]),
            Divider(height: 5, indent: 5, endIndent: 5),
            Row(children: [Expanded(flex: 3, child: Text("Name".tr() + " : ")), Expanded(flex: 5, child: Text("${fixedAsset?.name}"))]),
            Divider(height: 5, indent: 5, endIndent: 5),
            Row(children: [Expanded(flex: 3, child: Text("From Loaction".tr() + " : ")), Expanded(flex: 5, child: Text("${fromLocation?.name ?? "-"}"))]),
            Divider(height: 5, indent: 5, endIndent: 5),
            Row(children: [Expanded(flex: 3, child: Text("To Loaction".tr() + " : ")), Expanded(flex: 5, child: Text("${toLocation?.name ?? "-"}"))]),
            Divider(height: 5, indent: 5, endIndent: 5),
            Row(children: [Expanded(flex: 3, child: Text("Quantity".tr() + " : ")), Expanded(flex: 5, child: Text("1"))]),
          ],
        ),
        actions: [
          TextButton(child: Text("Cancel".tr(), style: TextStyle(color: Colors.redAccent)), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: Text("Approve Transfer".tr(), style: TextStyle(color: Colors.greenAccent)), onPressed: () => Navigator.pop(context, true)),
        ],
      );
    },
  );
}

List<FixAssetLocation> searchFixedAssetsLocation(String pattern) {
  // ignore: missing_return
  var value = fixAssetsLocations$.value.values.toList().where((item) {
    if (item.name != null) {
      return item.name!.toLowerCase().contains(pattern.toLowerCase());
    } else {
      return false;
    }
  });
  return value.isEmpty ? [] : value.toList();
}

Future<FixAssetLocation?> showSearchWidget_FixedAssetsLocationName() async {
  return await showModalBottomSheet(
      isDismissible: false,
      context: currentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext searchFixAssetLocationContext) {
        var search = TextEditingController(text: "");
        BehaviorSubject<List<FixAssetLocation?>> newList$ = BehaviorSubject.seeded(fixAssetsLocations$.value.values.toList());
        return DraggableScrollableSheet(
            expand: false,
            maxChildSize: 0.9,
            minChildSize: 0.9,
            initialChildSize: 0.9,
            builder: (context, controller) {
              return Stack(children: [
                Container(
                  decoration: const BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(35),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      runSpacing: 16,
                      children: [
                        Text(
                          "Locations".tr(),
                          style: k18w600Black(color: kGrey900),
                        ),
                        CTextFormField(
                          hintText: "Search".tr(),
                          controller: search,
                          onChange: (value) {
                            newList$.add(searchFixedAssetsLocation(value,));
                          },
                          textInputAction: TextInputAction.done,
                          hasIcon: true,
                          iconPath: "assets/images/search_logo.svg",
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: SingleChildScrollView(
                            child: StreamBuilder<List<FixAssetLocation?>?>(
                                stream: newList$.stream,
                                builder: (context, snapshot) {
                                  if (newList$.value.isEmpty) {
                                    return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          "No location matching your search".tr(),
                                          style: k14w400Black(color: kGrey600),
                                          textAlign: TextAlign.center,
                                        ));
                                  }
                                  return Column(
                                    children: [
                                      for (var i = 0; i < newList$.value.length; i++)
                                        InkWell(
                                            onTap: () {
                                              Navigator.pop(context, newList$.value[i]);
                                            },
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 40,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        newList$.value[i]?.name ?? '',
                                                        style: k14w500Black(color: kGrey700),
                                                        softWrap: true,
                                                      ),
                                                      SvgPicture.asset("assets/images/add_list.svg")
                                                    ],
                                                  ),
                                                ),
                                                Divider(
                                                  color: kBorderColor2,
                                                ),
                                              ],
                                            )),
                                      const SizedBox(
                                        height: 72,
                                      )
                                    ],
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom > 0 ?  MediaQuery.of(context).padding.bottom : 32,
                    ),
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            color: kWhite,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      //selectedStock$.add(null);
                                      //selectedStock$.add(selectedStock$.value);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(primary: kWhite, side: BorderSide(color: kBorderColor)),
                                    child: Text(
                                      "Cancel".tr(),
                                      style: k16w600Black(color: kGrey700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                ),
              ]);
            });
      }).then((value) {
    print(value);

    return value;
  });
}

List<FixAsset> searchFixedAsset(String pattern) {
  var value = fixAssets$.value.values.toList().where((item) =>
      (item.name ?? " ").toLowerCase().contains(pattern.toLowerCase()) ||
      (item.barkodeList != null && item.barkodeList!.isNotEmpty
          ? item.barkodeList!.keys.any((element) => element != null ? element.toLowerCase().contains(pattern.toLowerCase()) : false)
          : false));
  return value.isEmpty ? [] : value.toList();
}

//(item.barcode ?? " ").toLowerCase().contains(pattern.toLowerCase())
Future<FixAsset?> showSearchWidget_FixedAssetName() async {
  return await showModalBottomSheet(
      isDismissible: false,
      context: currentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext searchFixedAssetContext) {
        var search = TextEditingController(text: "");
        BehaviorSubject<List<FixAsset?>> newList$ = BehaviorSubject.seeded(fixAssets$.value.values.toList());
        return DraggableScrollableSheet(
            expand: false,
            maxChildSize: 0.9,
            minChildSize: 0.9,
            initialChildSize: 0.9,
            builder: (context, controller) {
              return Stack(children: [
                Container(
                  decoration: const BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(35),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      runSpacing: 16,
                      children: [
                        Text(
                          "Fixed Assets".tr(),
                          style: k18w600Black(color: kGrey900),
                        ),
                        CTextFormField(
                          hintText: "Search".tr(),
                          controller: search,
                          onChange: (value) {
                            newList$.add(searchFixedAsset(value,));
                          },
                          textInputAction: TextInputAction.done,
                          hasIcon: true,
                          iconPath: "assets/images/search_logo.svg",
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: SingleChildScrollView(
                            child: StreamBuilder<List<FixAsset?>?>(
                                stream: newList$.stream,
                                builder: (context, snapshot) {
                                  if (newList$.value.isEmpty) {
                                    return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          "No fixed asset matching your search".tr(),
                                          style: k14w400Black(color: kGrey600),
                                          textAlign: TextAlign.center,
                                        ));
                                  }
                                  return Column(
                                    children: [
                                      for (var i = 0; i < newList$.value.length; i++)
                                        InkWell(
                                            onTap: () {
                                              Navigator.pop(context, newList$.value[i]);
                                            },
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 40,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        newList$.value[i]?.name ?? '',
                                                        style: k14w500Black(color: kGrey700),
                                                        softWrap: true,
                                                      ),
                                                      SvgPicture.asset("assets/images/add_list.svg")
                                                    ],
                                                  ),
                                                ),
                                                Divider(
                                                  color: kBorderColor2,
                                                ),
                                              ],
                                            )),
                                      const SizedBox(
                                        height: 72,
                                      )
                                    ],
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom > 0 ?  MediaQuery.of(context).padding.bottom : 32,
                    ),
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            color: kWhite,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      //selectedStock$.add(null);
                                      //selectedStock$.add(selectedStock$.value);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(primary: kWhite, side: BorderSide(color: kBorderColor)),
                                    child: Text(
                                      "Cancel".tr(),
                                      style: k16w600Black(color: kGrey700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                ),
              ]);
            });
      }).then((value) {
    print(value);

    return value;
  });
}

Future<BarcodeItem?> showSearchWidget_FixedAssetBarcodes(List<BarcodeItem> newList) async {
  return await showDialog<BarcodeItem>(
    barrierDismissible: false,
    context: currentContext,
    builder: (context) {
      return AlertDialog(
        title: Text(fixAssets_byBarcode$.value[newList.first.barcode]?.name ?? "-"),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: ListView.separated(
            itemCount: newList.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(newList[index].serialNo ?? " - "),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Location".tr() +
                      " : " +
                      (fixAssetsLocations$.value[newList[index].locationId]?.name != null ? fixAssetsLocations$.value[newList[index].locationId]!.name! : "-")),
                  Text("Barcode" + " : " + (newList[index].barcode ?? " - ")),
                ],
              ),
              onTap: () async => Navigator.pop(context, newList[index]),
            ),
            separatorBuilder: (context, index) => Divider(),
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Close".tr(),
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  ).then((value) => value);
}

List<ResponsibleStaff> searchResponsibleStaff(String pattern) {
  var value = fixAssetsResponsibleStaff$.value.values.toList().where((item) => (item.name ?? "").toLowerCase().contains(pattern.toLowerCase()));
  return value.isEmpty ? [] : value.toList();
}

Future<ResponsibleStaff?> showSearchWidget_ResponsibleStaffName() async {

  return await showModalBottomSheet(
      isDismissible: false,
      context: currentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext searchResponsibleStaffContext) {
        var search = TextEditingController(text: "");
        BehaviorSubject<List<ResponsibleStaff?>> newList$ = BehaviorSubject.seeded(fixAssetsResponsibleStaff$.value.values.toList());
        return DraggableScrollableSheet(
            expand: false,
            maxChildSize: 0.9,
            minChildSize: 0.9,
            initialChildSize: 0.9,
            builder: (context, controller) {
              return Stack(children: [
                Container(
                  decoration: const BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(35),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      runSpacing: 16,
                      children: [
                        Text(
                          "Responsible Staffs".tr(),
                          style: k18w600Black(color: kGrey900),
                        ),
                        CTextFormField(
                          hintText: "Search".tr(),
                          controller: search,
                          onChange: (value) {
                            newList$.add(searchResponsibleStaff(value,));
                          },
                          textInputAction: TextInputAction.done,
                          hasIcon: true,
                          iconPath: "assets/images/search_logo.svg",
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: SingleChildScrollView(
                            child: StreamBuilder<List<ResponsibleStaff?>?>(
                                stream: newList$.stream,
                                builder: (context, snapshot) {
                                  if (newList$.value.isEmpty) {
                                    return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          "No staff matching your search".tr(),
                                          style: k14w400Black(color: kGrey600),
                                          textAlign: TextAlign.center,
                                        ));
                                  }
                                  return Column(
                                    children: [
                                      for (var i = 0; i < newList$.value.length; i++)
                                        InkWell(
                                            onTap: () {
                                              Navigator.pop(context, newList$.value[i]);
                                            },
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 40,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        newList$.value[i]?.name ?? '',
                                                        style: k14w500Black(color: kGrey700),
                                                        softWrap: true,
                                                      ),
                                                      SvgPicture.asset("assets/images/add_list.svg")
                                                    ],
                                                  ),
                                                ),
                                                Divider(
                                                  color: kBorderColor2,
                                                ),
                                              ],
                                            )),
                                      const SizedBox(
                                        height: 72,
                                      )
                                    ],
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom > 0 ?  MediaQuery.of(context).padding.bottom : 32,
                    ),
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            color: kWhite,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      //selectedStock$.add(null);
                                      //selectedStock$.add(selectedStock$.value);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(primary: kWhite, side: BorderSide(color: kBorderColor)),
                                    child: Text(
                                      "Cancel".tr(),
                                      style: k16w600Black(color: kGrey700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                ),
              ]);
            });
      }).then((value) {
    print(value);

    return value;
  });
}

Future<FixAssetCount?> showWidget_CountingMasterbyName(BuildContext context, String title, List<FixAssetCount> list) async {
  return await showDialog<FixAssetCount>(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AlertDialog(
            title: Text(title,style: k18w600Black(color: kGrey900),),
            titlePadding: const EdgeInsets.only(left: 16, top: 20, right: 16),
            contentPadding: const EdgeInsets.only(left: 16, top: 20, bottom: 24, right: 16),
            actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            insetPadding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 32),
            content: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: kGrey50,
                        border: Border.all(color: kBorderColor2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x0C101828),
                            blurRadius: 1.64,
                            offset: Offset(0, 0.82),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                        title: Text(branches$.value[list[index].branchid]?.name == null ? '' : branches$.value[list[index].branchid]!.name!),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 32,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFECDC9))),
                                    child: Text(
                                      list[index].periodstart == null ? " " : DateFormat("yyyy/MM/dd").format(list[index].periodstart!),
                                      style: k14w500Black(
                                        color: const Color(0xFFB32218),
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF17B26A),
                                  size: 16,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFAAEFC6))),
                                    child: Text(
                                      list[index].periodend == null ? " " : DateFormat("yyyy/MM/dd").format(list[index].periodend!),
                                      style: k14w500Black(
                                        color: const Color(0xFF067647),
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        onTap: () async {
                          Navigator.pop(context, list[index]);
                        },
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(color: kBorderColor2,);
                  },
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(primary: kWhite, side: const BorderSide(color: kBorderColor)),
                child: Text(
                  "Cancel".tr(),
                  style: k16w600Black(color: kGrey700),
                ),
              ),
            ],
          ),
        ],
      );
    },
  ).then((value) {
    print(value);
    return value;
  });
}
