import 'package:fixed_assets_v3/Modules/OfflineSummery/OfflineSummery.dart';
import 'package:fixed_assets_v3/main.dart';
import 'package:hive/hive.dart';

import '../../Globals/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  void initState() {
    super.initState();

    // if (isOffline.value) sqlLite.setDataFromOffline();
  }

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Elektra " + "Fixed Assets".tr() + " : ${loginResponse.tenancy?.hotelid.toString()}"),
        elevation: 0,
        actions: [
          SizedBox(
            width: 50,
            child: InkWell(
              child: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (hereContext) {
                    return AlertDialog(
                      title: Text("Settings").tr(),
                      content: Wrap(
                        children: [
                          Text("UserCode".tr() + " : " + (loginResponse.usercode ?? "")),
                          Container(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  child: Container(
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        "Turkish".tr(),
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: hereContext.locale.languageCode == "tr" ? Colors.blue : Colors.grey,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onTap: () {
                                    hereContext.locale = Locale('tr');
                                    Navigator.pop(hereContext);
                                  },
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: InkWell(
                                  child: Container(
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        "English".tr(),
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: hereContext.locale.languageCode == "en" ? Colors.blue : Colors.grey,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onTap: () {
                                    hereContext.locale = Locale('en');
                                    Navigator.pop(hereContext);
                                  },
                                ),
                              ),
                            ],
                          ),
                          Container(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  child: Container(
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        "Scanner".tr(),
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: cameraModeIsActive$.value != true ? Colors.blue : Colors.grey,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onTap: () {
                                    cameraModeIsActive$.value = false;
                                    cameraModeIsActive$.add(cameraModeIsActive$.value);

                                    (hereContext as Element).markNeedsBuild();
                                  },
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: InkWell(
                                  child: Container(
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        "Camera".tr(),
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: cameraModeIsActive$.value == true ? Colors.blue : Colors.grey,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onTap: () {
                                    cameraModeIsActive$.value = true;
                                    cameraModeIsActive$.add(cameraModeIsActive$.value);

                                    (hereContext as Element).markNeedsBuild();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Container(height: 20),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.black38, width: 1, style: BorderStyle.solid)),
                            child: Center(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "Offline".tr(),
                                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: StreamBuilder<bool>(
                                          stream: isOffline$.stream,
                                          builder: (context, snapshot) {
                                            return Switch(
                                              value: isOffline$.value,
                                              onChanged: (newValue) async {
                                                if (newValue) {
                                                  var record = await showWidget_CountingMasterbyName(context, "Counting Records".tr(), fixAssetsCount$.value.values.toList());

                                                  if (record == null) {
                                                    return;
                                                  }
                                                  await Hive.box('userOperations').put('offline', newValue);

                                                  isOffline$.add(newValue);
                                                  await Hive.box('userOperations').put('loginResponse', json.encode(loginResponse.toJson()));

                                                  // await Hive.box('userOperations').put('loginResponse', json.encode(loginResponse.toJson()));
                                                  fixAssetOfflineCountItem$.value = record;
                                                  fixAssetOfflineCountItem$.add(fixAssetOfflineCountItem$.value);
                                                  // await Hive.box('userOperations').put('countStockOfflineMasterItem', json.encode(record.toJson()));

                                                  fixAssetOfflineCountItemFromHive.put('FixAssetOfflineCountItem', record);

                                                  // ignore: use_build_context_synchronously
                                                  await showDialog(
                                                    barrierDismissible: false,
                                                    context: currentContext,
                                                    builder: (context) {
                                                      print(newValue);
                                                      Hive.box('userOperations').put('offline', newValue);

                                                      isOffline$.add(newValue);

                                                      db.setDataFromOnline(
                                                        [true, true, true, true, true],
                                                      ).then((value) async {
                                                        Navigator.of(context).pop();

                                                        if (value == "") {
                                                          await Hive.box('userOperations').put('offline', newValue);

                                                          isOffline$.add(newValue);

                                                          Navigator.of(hereContext).pop();
                                                        } else {
                                                          print("-----------------Error_----------------------");
                                                          // showWarningDialog("Error".tr(), value);
                                                        }
                                                      });

                                                      return Container(
                                                          child: const Center(
                                                        child: CircularProgressIndicator(),
                                                      ));
                                                    },
                                                  );
                                                } else {
                                                  var fixAssetCountDetailsNewList =
                                                      (fixAssetCountDetailsFromHive.get('FixAssetCountDetailsFromHive') ?? []).cast<FixAssetCountDetail>();
                                                  var offlineLocationCountingItemsNewList =
                                                      (offlineLocationCountingItemsFromHive.get('OfflineLocationCountingItems') ?? []).cast<OfflineLocationCountingItem>();

                                                  // var barcodes = await sqlLite.sqlDB.rawQuery("SELECT COUNT(ID) FROM STOCK_BARCODE_NEW");
                                                  // var counting = await sqlLite.sqlDB.rawQuery("SELECT COUNT(ID) FROM COUNT_STOCK_RECORD_NEW");

                                                  if (offlineLocationCountingItemsNewList.isNotEmpty || (fixAssetCountDetailsNewList.isNotEmpty)) {
                                                    showErrorDialog("You Can't turn off Offline Mode before pushing all data.".tr());
                                                    await Hive.box('userOperations').put('offline', true);

                                                    isOffline$.add(true);
                                                  } else {
                                                    await Hive.box('userOperations').put('offline', newValue);
                                                    isOffline$.add(newValue);
                                                    fixAssetOfflineCountItemFromHive.put('FixAssetOfflineCountItem', null);

                                                    await Hive.box('userOperations').put('offline', newValue);

                                                    isOffline$.add(newValue);

                                                    fixAssetOfflineCountItem$.add(null);

                                                    // prefs.remove(
                                                    //     "countStockOfflineMasterItem");
                                                    // prefs.setString("countStockOfflineMasterItem", null);
                                                    Navigator.pushReplacementNamed(context, "/");

                                                    Navigator.of(context).pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                          builder: (context) => MyHomePage(),
                                                        ),
                                                        (route) => false);
                                                  }
                                                }
                                              },
                                            );
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(height: 20),
                          InkWell(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  "Logout",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ).tr(),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(hereContext);
                              Navigator.pushReplacementNamed(hereContext, "/");
                            },
                          )
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            Navigator.pop(hereContext);
                          },
                        )
                      ],
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(
            width: 50,
            child: InkWell(
              child: Icon(
                Icons.refresh_rounded,
                color: Colors.white,
              ),
              onTap: () {
                var enabledNames = {"Branches": true, "Locations": true, "Fixed Assets": true, "Counting": true, "Responsible Staff": true};
                showDialog(
                  context: context,
                  builder: (hereContext) {
                    return AlertDialog(
                      title: Text("Refresh Data").tr(),
                      content: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: enabledNames.keys
                            .toList()
                            .map((e) => CheckboxListTile(
                                title: Text(e.tr()),
                                value: enabledNames[e],
                                onChanged: (value) {
                                  enabledNames[e] = value ?? false;
                                  (hereContext as Element).markNeedsBuild();
                                }))
                            .toList(),
                      ),
                      actions: [
                        IconButton(icon: Icon(Icons.clear, color: Colors.redAccent), onPressed: () => Navigator.pop(hereContext)),
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.greenAccent),
                          onPressed: () {
                            Navigator.pop(hereContext);
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                db.setDataFromOnline(enabledNames.values.toList()).then((value) => Navigator.pop(context));
                                return Container(child: Center(child: CircularProgressIndicator(color: Colors.white)));
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          StreamBuilder(
              stream: isOffline$.stream,
              builder: (context, snapshot) {
                return isOffline$.value
                    ? IconButton(
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OfflineSummery(),
                              )).then((value) => currentContext = context);
                        },
                        icon: const Icon(Icons.upload_rounded))
                    : Container();
              }),
        ],
      ),
      body: Stack(
        children: [
          Image(
            image: AssetImage('assets/images/bg.png'),
            height: h / 2.5,
            alignment: Alignment.topCenter,
            width: w,
            fit: BoxFit.fitHeight,
          ),
          StreamBuilder(
              stream: isOffline$.stream,
              builder: (context, snapshot) {
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: InkWell(
                                child: Container(
                                  width: w,
                                  // height: h/10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isOffline$.value ? Colors.grey.shade400 : Colors.white,
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 3, offset: Offset.zero)],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Fixed assets Transfer".tr(),
                                      style: TextStyle(fontSize: w / 15),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  if (isOffline$.value == true) {
                                    return;
                                  }
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Transfer(),
                                      )).then((value) => currentContext = context);
                                },
                              ),
                            ),
                            Container(
                              width: w / 7,
                              height: w / 7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isOffline$.value ? Colors.grey.shade400 : Colors.white,
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 3, offset: Offset.zero)],
                              ),
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.shopping_cart),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: InkWell(
                                child: Container(
                                  width: w,
                                  // height: h/10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 3, offset: Offset.zero)],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Fixed assets Location Counting".tr(),
                                      style: TextStyle(fontSize: w / 15),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  showLoadingDialog(db.setDataFromOnline([true, true, true, true, true])).then((value) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Counting_Location(),
                                        )).then((value) => currentContext = context);
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: w / 7,
                              height: w / 7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 3, offset: Offset.zero)],
                              ),
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.add_business_rounded),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: InkWell(
                                child: Container(
                                  width: w,
                                  // height: h/10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 3, offset: Offset.zero)],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Fixed assets Counting".tr(),
                                      style: TextStyle(fontSize: w / 15),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  if (fixAssetOfflineCountItem$.value == null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Counting(),
                                        )).then((value) => currentContext = context);
                                  } else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CountingDetails(),
                                        )).then((value) => currentContext = context);
                                  }
                                },
                              ),
                            ),
                            Container(
                              width: w / 7,
                              height: w / 7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 3, offset: Offset.zero)],
                              ),
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.add_box_sharp),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }
}
