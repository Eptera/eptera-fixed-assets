import 'package:eptera_fixed_asset/main.dart';
import 'package:flutter/services.dart';
import '../../Globals/index.dart';
import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: kWhite,
    ));

    // if (isOffline.value) sqlLite.setDataFromOffline();
  }

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    EdgeInsets padding = MediaQuery.of(context).padding;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leadingWidth: w / 2,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SvgPicture.asset("assets/images/fixed_asset_appbar_logo.svg"),
              const SizedBox(
                width: 8,
              ),
              Text(
                loginResponse.usercode ?? "",
                style: k20w600Black(color: kGrey900),
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              "assets/images/refresh.svg",
              color: kGrey600,
            ),
            onPressed: () {
              var enabledNames = {"Branches": false, "Locations": false, "Fixed Assets": false, "Counting": false, "Responsible Staff": false};
              showDialog(
                context: context,
                builder: (hereContext) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AlertDialog(
                        title: const Text("Refresh Data").tr(),
                        titlePadding: EdgeInsets.only(left: 16, top: 20, right: 16),
                        contentPadding: EdgeInsets.only(
                          left: 16,
                          top: 20,
                          right: 16,
                          bottom: 20,
                        ),
                        insetPadding: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 32),
                        content: Wrap(
                          runSpacing: 12,
                          children: enabledNames.keys
                              .toList()
                              .map((e) => InkWell(
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: enabledNames[e]! ? Color(0xFFE04F16) : Color(0xFFCFD4DC),
                                              width: 1,
                                            ),
                                          ),
                                          width: 20,
                                          height: 20,
                                          child: Checkbox(
                                            onChanged: (value) {
                                              enabledNames[e] = value ?? false;
                                              (hereContext as Element).markNeedsBuild();
                                            },
                                            activeColor: Color(0xFFFDEAD7),
                                            checkColor: kPrimaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            value: enabledNames[e],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          e.tr(),
                                          style: k14w500Black(color: kGrey700),
                                        )
                                      ],
                                    ),
                                    onTap: () {
                                      enabledNames[e] = !(enabledNames[e]!);
                                      (hereContext as Element).markNeedsBuild();
                                    },
                                  ))
                              .toList(),
                        ),
                        actions: [
                          Column(
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
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
                                  child: Text(
                                    "Refresh".tr(),
                                    style: k16w600Black(color: kWhite),
                                  )),
                              SizedBox(
                                height: 8,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(hereContext);
                                },
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
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              "assets/images/settings.svg",
              color: kGrey600,
            ),
            onPressed: () {
              showModalBottomSheet(
                  isDismissible: true,
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                  builder: (BuildContext settingsContext) {
                    return DraggableScrollableSheet(
                        expand: false,
                        maxChildSize: 0.7,
                        minChildSize: 0.55,
                        initialChildSize: 0.55,
                        builder: (context, controller) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(35),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(top: 24, left: 16, right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Settings".tr(),
                                    style: k18w600Black(color: kGrey900),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                          isDismissible: true,
                                          context: context,
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                                          builder: (BuildContext languageContext) {
                                            return DraggableScrollableSheet(
                                                expand: false,
                                                maxChildSize: 0.7,
                                                minChildSize: 0.5,
                                                initialChildSize: 0.5,
                                                builder: (context, controller) {
                                                  return Container(
                                                    decoration: const BoxDecoration(
                                                      color: kWhite,
                                                      borderRadius: BorderRadius.vertical(
                                                        top: Radius.circular(35),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.only(top: padding.top, left: 16, right: 16),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                child: Icon(
                                                                  Icons.arrow_back,
                                                                  size: 20,
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(languageContext);
                                                                },
                                                              ),
                                                              SizedBox(
                                                                width: 12,
                                                              ),
                                                              Text(
                                                                "Language Settings".tr(),
                                                                style: k16w600Black(color: kGrey700),
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 16,
                                                          ),
                                                          Divider(
                                                            color: kBorderColor2,
                                                          ),
                                                          StreamBuilder(
                                                              stream: selectedLang$.stream,
                                                              builder: (context, snapshot) {
                                                                return Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: languages.entries.map((entry) {
                                                                    String code = entry.key;
                                                                    String text = entry.value;
                                                                    return Padding(
                                                                      padding: EdgeInsets.only(bottom: 12),
                                                                      child: InkWell(
                                                                        onTap: () {
                                                                          selectedLang$.add(code);
                                                                          selectedLang$.add(selectedLang$.value);
                                                                          context.locale = Locale(code);
                                                                        },
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                SvgPicture.asset("assets/images/${code}_flag.svg"),
                                                                                SizedBox(width: 12),
                                                                                Text(
                                                                                  tr(text),
                                                                                  style: k14w500Black(color: kGrey700),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Radio<String>(
                                                                              value: code,
                                                                              groupValue: selectedLang$.value,
                                                                              onChanged: (value) {
                                                                                selectedLang$.add(value!);
                                                                                selectedLang$.add(selectedLang$.value);
                                                                                context.locale = Locale(value);
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                );
                                                              }),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                          });
                                    },
                                    child: Row(
                                      children: [
                                        SvgPicture.asset("assets/images/translate.svg"),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Text(
                                          "Language Settings".tr(),
                                          style: k16w600Black(color: kGrey700),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(child: Container()),
                                        StreamBuilder(
                                            stream: selectedLang$.stream,
                                            builder: (context, snapshot) {
                                              return Container(
                                                padding: const EdgeInsets.only(top: 2, left: 3, right: 8, bottom: 2),
                                                decoration: BoxDecoration(color: Color(0xFFF8F9FB), border: Border.all(color: kBorderColor2), borderRadius: BorderRadius.circular(16)),
                                                child: Row(
                                                  children: [
                                                    SvgPicture.asset("assets/images/${selectedLang$.value}_flag.svg"),
                                                    SizedBox(
                                                      width: 6,
                                                    ),
                                                    Text(
                                                      tr(languages[selectedLang$.value]!),
                                                      style: k12w500Black(color: kGrey700),
                                                    )
                                                    // Image.asset("assets/images/tr.png")
                                                  ],
                                                ),
                                              );
                                            }),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: kGrey500,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset("assets/images/offline_mode.svg"),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Text(
                                          "Offline Mode".tr(),
                                          style: k16w600Black(color: kGrey700),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        const Spacer(),
                                        StreamBuilder<bool>(
                                            stream: isOffline$.stream,
                                            builder: (context, snapshot) {
                                              return CustomSwitch(
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

                                                            Navigator.of(settingsContext).pop();
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
                                                    var fixAssetCountDetailsNewList = (fixAssetCountDetailsFromHive.get('FixAssetCountDetailsFromHive') ?? []).cast<FixAssetCountDetail>();
                                                    var offlineLocationCountingItemsNewList =
                                                        (offlineLocationCountingItemsFromHive.get('OfflineLocationCountingItems') ?? []).cast<OfflineLocationCountingItem>();

                                                    // var barcodes = await sqlLite.sqlDB.rawQuery("SELECT COUNT(ID) FROM STOCK_BARCODE_NEW");
                                                    // var counting = await sqlLite.sqlDB.rawQuery("SELECT COUNT(ID) FROM COUNT_STOCK_RECORD_NEW");

                                                    if (offlineLocationCountingItemsNewList.isNotEmpty || (fixAssetCountDetailsNewList.isNotEmpty)) {
                                                      kShowBanner(BannerType.ERROR, "Warning".tr(), "You Can't turn off Offline Mode before pushing all data.".tr(), context);
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
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  StreamBuilder(
                                      stream: cameraModeIsActive$.stream,
                                      builder: (context, snapshot) {
                                        return Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: InkWell(
                                                onTap: () {
                                                  cameraModeIsActive$.add(false);
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: Radio<bool>(
                                                        value: false,
                                                        groupValue: cameraModeIsActive$.value,
                                                        onChanged: (value) {
                                                          cameraModeIsActive$.add(false);
                                                        },
                                                        activeColor: kPrimaryColor,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      "Scanner".tr(),
                                                      style: k16w600Black(color: kGrey700),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: InkWell(
                                                onTap: () {
                                                  cameraModeIsActive$.add(true);
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: Radio<bool>(
                                                        value: true,
                                                        groupValue: cameraModeIsActive$.value,
                                                        onChanged: (value) {
                                                          cameraModeIsActive$.add(true);
                                                        },
                                                        activeColor: kPrimaryColor,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      "Camera".tr(),
                                                      style: k16w600Black(color: kGrey700),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Divider(
                                    color: kBorderColor2,
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 12,
                                      ),
                                      if (loginResponse.usercode != null)
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFFFDEAD7),
                                                border: Border.all(
                                                  color: Color(0xFFDF4F16), // Renk kodu: #096DD0
                                                  width: 0.75, // Kenarlık kalınlığı
                                                ),
                                                // border: Border.all(color: Color.fromRGBO(66, 48, 125, 0.75)),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  loginResponse.usercode!.substring(0, 1).toUpperCase(),
                                                  style: k16w600Black(
                                                    color: kPrimaryColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 12,
                                            ),
                                            Text(
                                              loginResponse.usercode!,
                                              style: k14w600Black(color: kGrey700),
                                            ),
                                          ],
                                        ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      if (!isOffline$.value)
                                        InkWell(
                                          onTap: () {
                                            showConfirmDialog("Logout".tr(), 'LOGOUT_DIALOG_TEXT'.tr(), imagePath: "assets/images/logout_dialog.svg", buttonColor: kPrimaryColor).then((value) async {
                                              if (value == true) {
                                                Navigator.pop(settingsContext);
                                                Navigator.pushReplacementNamed(context, "/");
                                              }
                                            });
                                          },
                                          child: SvgPicture.asset("assets/images/logout.svg"),
                                        )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 24,
                                  ),
                                  Center(
                                    child: Text(
                                      "App Version : ${packageInfo.version}",
                                      style: k12w400Black(color: kGrey500),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  });
            },
          ),
          StreamBuilder(
              stream: isOffline$.stream,
              builder: (context, snapshot) {
                if (isOffline$.value) {
                  return IconButton(
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OfflineSummary(),
                            )).then((value) => currentContext = context);
                      },
                      icon: SvgPicture.asset("assets/images/list.svg"));
                } else {
                  return Container();
                }
              }),
        ],
      ),
      body: StreamBuilder(
          stream: isOffline$.stream,
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InkWell(
                        onTap: isOffline$.value
                            ? null
                            : () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Transfer(),
                                    )).then((value) => currentContext = context);
                              },
                        child: modules(
                          true,
                          'assets/images/stock_transfer.svg',
                          'assets/images/disabled_stock_transfer.svg',
                          "Fixed assets Transfer",
                        )),
                    InkWell(
                        onTap: () {
                          showLoadingDialog(db.setDataFromOnline([true, true, true, true, true])).then((value) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Counting_Location(),
                                )).then((value) => currentContext = context);
                          });
                        },
                        child: modules(
                          false,
                          'assets/images/location_counting.svg',
                          'assets/images/disabled_location_counting.svg',
                          "Fixed assets Location Counting",
                        )),
                    InkWell(
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
                        child: modules(
                          false,
                          'assets/images/counting.svg',
                          'assets/images/disabled_dispatch.svg',
                          "Fixed assets Counting",
                        )),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget modules(bool isOfflineModeCheck, String iconPath, String disabledIconPath, String moduleName, {Function? func}) {
    currentContext = context;
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: w - 32,
        height: (w - 44) / 2.35,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderColor2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C101828),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SvgPicture.asset(
              (isOfflineModeCheck && isOffline$.value) ? disabledIconPath : iconPath,
            ),
            const Spacer(),
            Text(
              tr(moduleName),
              style: TextStyle(fontFamily: 'Inter', fontSize: w / 25, fontWeight: FontWeight.w600, color: (isOfflineModeCheck && isOffline$.value) ? kBorderColor : kGrey600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
