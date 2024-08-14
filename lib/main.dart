import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'Globals/index.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
  }
}

//PAHO3634
//PAHO1542
//PAHO5192
//1-05 : PAHO6597

Future<void> main() async {
  await Hive.initFlutter();

  Hive.registerAdapter<FixAsset>(FixAssetAdapter());
  Hive.registerAdapter<Branch>(BranchAdapter());
  Hive.registerAdapter<FixAssetLocation>(FixAssetLocationAdapter());
  Hive.registerAdapter<FixAssetCount>(FixAssetCountAdapter());
  Hive.registerAdapter<FixAssetCountDetail>(FixAssetCountDetailAdapter());
  Hive.registerAdapter<OfflineLocationCountingItem>(OfflineLocationCountingItemAdapter());
  Hive.registerAdapter<BarcodeItem>(BarcodeItemAdapter());

  var dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  fixAssetsFromHive = await Hive.openBox<Map?>('FixAssets');
  branchesFromHive = await Hive.openBox<Map?>('Branches');
  fixAssetsLocationsFromHive = await Hive.openBox<Map?>('FixAssetsLocations');
  fixAssetsCountFromHive = await Hive.openBox<Map?>('FixAssetsCount');
  fixAssetCountDetailsFromHive = await Hive.openBox<List?>('FixAssetCountDetailsFromHive');
  offlineLocationCountingItemsFromHive = await Hive.openBox<List?>('OfflineLocationCountingItems');
  fixAssetOfflineCountItemFromHive = await Hive.openBox<Object?>('FixAssetOfflineCountItem');

  if (!Hive.isBoxOpen('userOperations')) {
    await Hive.openBox('userOperations');
  }

  GetIt.I.registerSingleton<Database>(Database());
  GetIt.I.registerSingleton<Api>(Api());
  GetIt.I.registerSingleton<TransferService>(TransferService());
  GetIt.I.registerSingleton<CountingService>(CountingService());
  GetIt.I.registerSingleton<Counting_LocationService>(Counting_LocationService());
  GetIt.I.registerSingleton<Scanner>(Scanner());

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('tr')],
      path: 'assets/translations', // <-- change patch to your
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    selectedLang$ = BehaviorSubject<String>.seeded(EasyLocalization.of(context)!.currentLocale!.languageCode);
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Eptera Fixed Asset',
      theme: ThemeData(
        expansionTileTheme: ExpansionTileThemeData(
          iconColor: kGrey500,
          collapsedIconColor: kGrey500,
          tilePadding: EdgeInsets.only(left: 14, right: 14),
          childrenPadding: EdgeInsets.only(
            left: 14,
            right: 14,
            bottom: 12,
          ),
        ),
        useMaterial3: false,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: kBorderColor2,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFE04F16),
          secondary: const Color(0xFFFAC515),
          background: Colors.white,
        ),

        appBarTheme: const AppBarTheme(
            foregroundColor: Colors.black,
            shadowColor: Colors.black54,
            surfaceTintColor: Colors.transparent,
            backgroundColor: kWhite,
            elevation: 1,
            titleSpacing: 50,
            iconTheme: IconThemeData(color: kGrey500)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: kPrimaryColor)),
            minimumSize: Size(double.maxFinite, 44),
            textStyle: k16w600Black(color: kWhite),
            shadowColor: Color(0x0C101828),
            padding: EdgeInsets.only(left: 18, top: 10, right: 18, bottom: 10),
          ),
        ),
        scaffoldBackgroundColor: kWhite,
        cardTheme: CardTheme(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return kPrimaryColor;
              }
              return kWhite;
            },
          ),
          checkColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return kBorderColor2;
            },
          ),
          side: BorderSide(
            color: kBorderColor!,
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        radioTheme: RadioThemeData(
          overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return kBorderColor2;
            },
          ),
          fillColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return kPrimaryColor;
              }
              return kBorderColor2;
            },
          ),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        dialogTheme: DialogTheme(
          // titleTextStyle: k18w600Black(color: kGrey900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          surfaceTintColor: Colors.transparent,
          backgroundColor: kWhite,
          actionsPadding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
        ),

        // bottomSheetTheme: BottomSheetThemeData(
        //   backgroundColor: kWhite,
        //   modalBackgroundColor: kWhite
        // )
      ),
      // home: MyHomePage(),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/welcome': (context) => Welcome(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BehaviorSubject<String> tfaCode$ = BehaviorSubject<String>.seeded("");

  FocusNode focusNode = FocusNode();
  final api = GetIt.I<Api>();
  final formkey = GlobalKey<FormState>();
  BehaviorSubject loginRequested$ = BehaviorSubject.seeded(false);
  bool savePassword = false;

  final endPoint = TextEditingController(text: "");
  final tenant = TextEditingController(text: "");
  final usercode = TextEditingController(text: "");
  final password = TextEditingController(text: "");
  TextEditingController authcodeController = TextEditingController(text: "");

  BehaviorSubject<bool> passwordEyeClosed$ = BehaviorSubject.seeded(true);
  BehaviorSubject<bool> rememberMeCheck$ = BehaviorSubject.seeded(false);

  @override
  void initState() {
    super.initState();

    _setStatusBarColor();
    initStorageVariables();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setStatusBarColor();
  }

  void _setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: kPrimaryColor,
    ));
  }

  @override
  void didUpdateWidget(w) {
    super.didUpdateWidget(w);
  }

  Future<void> initPlatformState() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
        if (androidDeviceInfo.brand == "Honeywell") {
          // isScannerDevice$.add(true);
          // isScannerDevice$.add(isScannerDevice$.value);

          cameraModeIsActive$.value = await Hive.box('userOperations').get('camera') ?? false;
          cameraModeIsActive$.add(cameraModeIsActive$.value);

          scanner = Scanner();
        } else {
          await Hive.box('userOperations').put('camera', true);
          cameraModeIsActive$.value = true;
          cameraModeIsActive$.add(cameraModeIsActive$.value);
        }
      } else if (Platform.isIOS) {
        await Hive.box('userOperations').put('camera', true);

        cameraModeIsActive$.value = true;
        cameraModeIsActive$.add(cameraModeIsActive$.value);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
    }
  }

  initStorageVariables() async {
    packageInfo = await PackageInfo.fromPlatform();

    var isFirstTime = await Hive.box('userOperations').get('isFirstTime');

    var newFixAssetOfflineCountItem = fixAssetOfflineCountItemFromHive.get('FixAssetOfflineCountItem');

    if (newFixAssetOfflineCountItem != null) {
      fixAssetOfflineCountItem$.value = newFixAssetOfflineCountItem as FixAssetCount?;
      fixAssetOfflineCountItem$.add(fixAssetOfflineCountItem$.value);
    }

    if (isFirstTime != null && !isFirstTime) {
      isOffline$.add(await Hive.box('userOperations').get('offline') ?? false);

      if (isOffline$.value) {
        await db.setDataFromOffline();

        var loginResponseToDecode = await Hive.box('userOperations').get('loginResponse');
        LoginResponse? loginResponseFromStorage;

        if (loginResponseToDecode != null) {
          loginResponseFromStorage = LoginResponse.fromJson(json.decode(loginResponseToDecode));
          loginResponse = loginResponseFromStorage;
        }

        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, "/welcome");
      }
    } else {
      await Hive.box('userOperations').put('isFirstTime', false);
      await Hive.box('userOperations').put('first_time_done', false);
      await Hive.box('userOperations').put('Camera', false);
      await Hive.box('userOperations').put('Scanner', false);
    }

    if (!kReleaseMode) {
      print("DEBUG MODE !!!");

      tenant.text = "1002";
      usercode.text = "eptera";
      password.text = "Eptera123.";
    } else {
      print("RELEASE MODE !!!");
      setState(() async {
        endPoint.text = await Hive.box('userOperations').get('endPoint') ?? "";
        tenant.text = await Hive.box('userOperations').get('tenant') ?? "";
        usercode.text = await Hive.box('userOperations').get('userCode') ?? "";
        if (await Hive.box('userOperations').get('savePassword') == true) {
          password.text = await Hive.box('userOperations').get('password') ?? '';
          rememberMeCheck$.add(true);
        }
      });
    }
  }

  Future<void> login() async {
    if (formkey.currentState!.validate()) {
      loginRequested$.add(true);
      try {
        await api.login(
          tenant.text,
          usercode.text,
          password.text,
          endPoint: endPoint.text == "" ? null : endPoint.text,
          authcode: tfaCode$.value == "" ? null : tfaCode$.value,
          context: context,
        );
        if (loginResponse.loginToken != "") {
          await Hive.box('userOperations').put('endPoint', endPoint.text);
          await Hive.box('userOperations').put('tenant', tenant.text);
          await Hive.box('userOperations').put('userCode', usercode.text);
          await Hive.box('userOperations').put('password', password.text);
          await Hive.box('userOperations').put('savePassword', savePassword);
          // loginRequested$.add(false);
          if (true || loginResponse.tenancy?.elektraFixedassetsLicanceExpire != null) {
            if (true || loginResponse.tenancy!.elektraFixedassetsLicanceExpire!.isAfter(DateTime.now())) {
              List<bool> activeSelection = [true, true, true, true, true];

              await db.setDataFromOnline(activeSelection);

              loginRequested$.add(false);

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Welcome()));
            } else {
              await showErrorDialog("Your program licence has finished.\nPlease renew it to continue using the application.".tr());
              loginRequested$.add(false);
            }
          } else {
            await showErrorDialog("You have no licence to use this application.\nPlease contact support to use the application.".tr());
            loginRequested$.add(false);
          }
          loginRequested$.add(false);
        }
      } catch (e) {
        loginRequested$.add(false);
        print(e.toString());
        if (e.toString().contains("Code: 0")) {
          kShowBanner(BannerType.ERROR, "Error".tr(), "Login Unsuccessful".tr(), context);
        } else if (e.toString().contains("Code: 30")) {
          showDialog(
            context: context,
            builder: (dialogContext) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AlertDialog(
                    backgroundColor: kWhite,
                    titlePadding: EdgeInsets.only(left: 16, top: 20, right: 16),
                    contentPadding: EdgeInsets.only(left: 16, top: 24, bottom: 24, right: 16),
                    actionsPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    insetPadding: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 80),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset("assets/images/2FA_image.svg"),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.pop(dialogContext);
                              },
                              child: Icon(
                                Icons.close,
                                color: kGrey500,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Enter 2FA Code".tr(),
                          style: k18w600Black(color: kGrey900),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          "Enter 6-digit 2FA code to verify your identity".tr(),
                          style: k14w400Black(color: kGrey600),
                        )
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: Stack(
                        children: [
                          StreamBuilder(
                              stream: tfaCode$.stream,
                              builder: (context, snapshot) {
                                List<String> codeDigits = tfaCode$.value.split('');

                                List<Widget> codeContainers = List.generate(6, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Container(
                                      width: (MediaQuery.of(context).size.width - 64) / 7,
                                      height: (MediaQuery.of(context).size.width - 64) / 7,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        index < codeDigits.length ? codeDigits[index] : '',
                                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
                                      ),
                                    ),
                                  );
                                });

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: codeContainers,
                                );
                              }),
                          TextFormField(
                            focusNode: focusNode,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            onChanged: (text) async {
                              tfaCode$.add(text);
                              if (tfaCode$.value.length == 6) {
                                Navigator.pop(dialogContext, true);
                                await login();
                              }
                            },
                            style: const TextStyle(color: Color(0x00000000)),
                            cursorHeight: 0,
                            cursorColor: Colors.red,
                            cursorWidth: 0,
                            maxLength: 6,
                            decoration: const InputDecoration(border: InputBorder.none, counterText: "", focusColor: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          if (e.toString().contains("Code: 31")) {
            tfaCode$.add("");
            kShowBanner(BannerType.ERROR, "Error".tr(), "2FA code does not match".tr(), context);
          } else {
            kShowBanner(BannerType.ERROR, "Error".tr(), "An error occurred while logging in".tr(), context);
            await showDialog(
                context: currentContext,
                builder: (context) {
                  return Container(
                    child: AlertDialog(
                      title: Text("Error".tr()),
                      contentPadding: const EdgeInsets.all(16.0),
                      content: Text(e.toString()),
                      actions: <Widget>[
                        TextButton(
                            child: Text("Ok").tr(),
                            onPressed: () {
                              Navigator.pop(context);
                              tfaCode$.add("");
                            }),
                      ],
                    ),
                  );
                });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext pageContext) {
    currentContext = pageContext;
    void changePasswordEyeStatus() {
      passwordEyeClosed$.value = !passwordEyeClosed$.value;
    }

    EdgeInsets padding = MediaQuery.of(context).padding;
    final double h = MediaQuery.of(context).size.height;
    final double w = MediaQuery.of(context).size.width;

    var newNewDesign = Form(
      key: formkey,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: w,
            height: h,
            child: Stack(
              children: [
                Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: kPrimaryColor),
                        width: w,
                        height: (h) / 3,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: kWhite,
                        ),
                        width: w,
                        height: (h * 2) / 3,
                      )
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      SizedBox(
                          height: h / 3 - 50,
                          child: Center(
                              child: SvgPicture.asset(
                            "assets/images/fixed_asset_logo.svg",
                            width: w / 7,
                            height: w / 7,
                          ))),
                      Container(
                        width: w - 32,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x2D0F1728),
                              blurRadius: 48,
                              offset: Offset(0, 24),
                              spreadRadius: -12,
                            )
                          ],
                          color: kWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Wrap(
                            runSpacing: 24,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(10)),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  runSpacing: 20,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Tenant".tr()),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        CTextFormField(
                                          hintText: "Tenant".tr(),
                                          hasIcon: false,
                                          textInputAction: TextInputAction.next,
                                          withoutPadding: true,
                                          controller: tenant,
                                          // initialValue: tenant.text,
                                          validator: validate,
                                          onChange: (text) {},
                                          textInputType: TextInputType.number,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Usercode".tr()),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        CTextFormField(
                                          hintText: "Usercode".tr(),
                                          hasIcon: false,
                                          textInputAction: TextInputAction.next,
                                          // initialValue: usercode.text,
                                          controller: usercode,
                                          onChange: (text) {},
                                          withoutPadding: true,
                                          validator: validate,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Password".tr()),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        StreamBuilder(
                                            stream: passwordEyeClosed$.stream,
                                            builder: (context, snapshot) {
                                              return CTextFormField(
                                                hintText: "Password".tr(),
                                                hasIcon: false,
                                                textInputAction: TextInputAction.next,
                                                // initialValue: password.text,
                                                controller: password,
                                                onChange: (text) {},
                                                // onChange: setPassword,
                                                isPasswordForm: true,
                                                passwordEyeClosed: passwordEyeClosed$.value,
                                                changePasswordEyeStatus: changePasswordEyeStatus,
                                                validator: validate,
                                              );
                                            }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              StreamBuilder(
                                  stream: rememberMeCheck$.stream,
                                  builder: (context, snapshot) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              rememberMeCheck$.add(!rememberMeCheck$.value);
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  child: Checkbox(
                                                    value: rememberMeCheck$.value,
                                                    onChanged: (value) {
                                                      rememberMeCheck$.add(!rememberMeCheck$.value);
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: Text(
                                                    "Remember me".tr(),
                                                    style: k14w500Black(color: kGrey700),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              var result = await api.forgotPassword(usercode: usercode.text, tenant: tenant.text);
                                              print(result);

                                              var title = result != "\"User not found\"" ? "Success".tr() : "Unsuccessful".tr();
                                              var content = result != "\"User not found\"" ? "Password Reset".tr() : "Unsuccessful".tr();
                                              await showDialog<String>(
                                                context: context,
                                                builder: (context) {
                                                  return Container(
                                                    child: AlertDialog(
                                                      title: Text(title),
                                                      contentPadding: const EdgeInsets.all(16.0),
                                                      content: Text(content),
                                                      actions: [
                                                        new TextButton(
                                                            child: Text("Ok".tr()),
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            }),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Text("Forgot Password?".tr(), style: k14w600Black(color: Color(0xFF1B113A)), textAlign: TextAlign.right),
                                          ),
                                        )
                                      ],
                                    );
                                  }),
                              ElevatedButton(
                                  onPressed: () {
                                    login();
                                    focusNode.requestFocus();
                                  },
                                  child: Text(
                                    "Login".tr(),
                                    style: k16w600Black(color: kWhite),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: padding.top + 16,
                  right: 16,
                  child: InkWell(
                    child: SvgPicture.asset(
                      "assets/images/settings.svg",
                      color: kWhite,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                          isDismissible: true,
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                          builder: (BuildContext settingsContext) {
                            return DraggableScrollableSheet(
                                expand: false,
                                maxChildSize: 0.7,
                                minChildSize: 0.4,
                                initialChildSize: 0.4,
                                builder: (context, controller) {
                                  return Stack(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: kWhite,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(35),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: padding.top > 0 ? padding.top : 24, left: 16, right: 16),
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
                                                            minChildSize: 0.4,
                                                            initialChildSize: 0.4,
                                                            builder: (context, controller) {
                                                              return Container(
                                                                decoration: const BoxDecoration(
                                                                  color: kWhite,
                                                                  borderRadius: BorderRadius.vertical(
                                                                    top: Radius.circular(35),
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets.only(top: padding.top > 0 ? padding.top : 24, left: 16, right: 16),
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
                                                                                return InkWell(
                                                                                  onTap: () {
                                                                                    selectedLang$.add(code);
                                                                                    selectedLang$.add(selectedLang$.value);
                                                                                    context.locale = Locale(code);
                                                                                  },
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Radio düğmeleri ve metin arasında boşluğu kontrol eder
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
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text("EndPoint".tr()),
                                                      SizedBox(
                                                        height: 6,
                                                      ),
                                                      Container(
                                                        width: w - 48,
                                                        child: CTextFormField(
                                                          hintText: "EndPoint (Optional)".tr(),
                                                          hasIcon: false,
                                                          textInputAction: TextInputAction.next,
                                                          withoutPadding: true,
                                                          initialValue: endPoint.text,
                                                          onChange: (text) {},
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                                      ),
                                      Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.pop(settingsContext);
                                              },
                                              child: Icon(
                                                Icons.close,
                                                color: kGrey500,
                                              ),
                                            ),
                                          )),
                                    ],
                                  );
                                });
                          });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // var newNewDesign2 = Scaffold(
    //   body: SafeArea(
    //     child: SingleChildScrollView(
    //       child: Padding(
    //         padding: const EdgeInsets.all(10.0),
    //         child: Stack(
    //           children: [
    //             Align(
    //               alignment: Alignment.topRight,
    //               child: Container(
    //                 width: 50,
    //                 height: 50,
    //                 decoration: BoxDecoration(
    //                   color: Colors.blue,
    //                   borderRadius: BorderRadius.circular(25),
    //                   boxShadow: const [
    //                     BoxShadow(
    //                       color: Colors.black54,
    //                       spreadRadius: 1,
    //                       blurRadius: 3,
    //                     ),
    //                   ],
    //                 ),
    //                 child: InkWell(
    //                   child: const Icon(
    //                     Icons.settings,
    //                     color: Colors.white,
    //                   ),
    //                   onTap: () {
    //                     showDialog(
    //                       context: pageContext,
    //                       builder: (context) {
    //                         return AlertDialog(
    //                           title: Text("Settings".tr()),
    //                           content: Wrap(
    //                             spacing: 10,
    //                             runSpacing: 10,
    //                             children: [
    //                               Row(
    //                                 children: [
    //                                   Expanded(
    //                                     child: InkWell(
    //                                       child: Container(
    //                                         height: 50,
    //                                         child: Center(
    //                                           child: Text(
    //                                             "Turkish".tr(),
    //                                             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    //                                           ),
    //                                         ),
    //                                         decoration: BoxDecoration(
    //                                           color: context.locale.languageCode == "tr" ? Colors.blue : Colors.grey,
    //                                           borderRadius: BorderRadius.circular(5),
    //                                         ),
    //                                       ),
    //                                       onTap: () {
    //                                         context.locale = Locale('tr');
    //                                         Navigator.pop(context);
    //                                       },
    //                                     ),
    //                                   ),
    //                                   SizedBox(width: 20),
    //                                   Expanded(
    //                                     child: InkWell(
    //                                       child: Container(
    //                                         height: 50,
    //                                         child: Center(
    //                                           child: Text(
    //                                             "English".tr(),
    //                                             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    //                                           ),
    //                                         ),
    //                                         decoration: BoxDecoration(
    //                                           color: context.locale.languageCode == "en" ? Colors.blue : Colors.grey,
    //                                           borderRadius: BorderRadius.circular(5),
    //                                         ),
    //                                       ),
    //                                       onTap: () {
    //                                         context.locale = Locale('en');
    //                                         Navigator.pop(context);
    //                                       },
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                               TextFormField(
    //                                 textInputAction: TextInputAction.next,
    //                                 style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0),
    //                                 autocorrect: false,
    //                                 enableSuggestions: false,
    //                                 decoration: InputDecoration(
    //                                     contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    //                                     labelText: "EndPoint (Optional)".tr(),
    //                                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
    //                                 controller: endPoint,
    //                               ),
    //                               Center(
    //                                 child: Text("App Version : ${packageInfo.version}+${packageInfo.buildNumber}"),
    //                               ),
    //                             ],
    //                           ),
    //                           actions: [
    //                             TextButton(
    //                               child: Icon(
    //                                 Icons.done,
    //                                 color: Colors.green,
    //                               ),
    //                               onPressed: () {
    //                                 Navigator.pop(context);
    //                               },
    //                             )
    //                           ],
    //                         );
    //                       },
    //                     );
    //                   },
    //                 ),
    //               ),
    //             ),
    //             Container(
    //               height: h - 50,
    //               child: Center(
    //                 child: Form(
    //                   key: formkey,
    //                   child: Column(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     children: <Widget>[
    //                       Wrap(
    //                         spacing: 20,
    //                         runSpacing: 10,
    //                         children: [
    //                           Container(
    //                             child: Column(
    //                               children: [
    //                                 Padding(
    //                                   padding: const EdgeInsets.all(15.0),
    //                                   child: Center(
    //                                     child: Image(
    //                                       image: AssetImage('assets/images/POS_LOGO.png'),
    //                                       height: h / 6,
    //                                     ),
    //                                   ),
    //                                 ),
    //                                 Text("Eptera " + "Fixed Asset".tr(), style: TextStyle(color: Colors.black87, fontSize: 26))
    //                               ],
    //                             ),
    //                           ),
    //                           TextFormField(
    //                             textInputAction: TextInputAction.next,
    //                             style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0),
    //                             decoration: InputDecoration(
    //                                 contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    //                                 labelText: "Tenant".tr(),
    //                                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
    //                             validator: (value) => validator(value),
    //                             controller: tenant,
    //                           ),
    //                           TextFormField(
    //                             textInputAction: TextInputAction.next,
    //                             style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0),
    //                             decoration: InputDecoration(
    //                                 contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    //                                 labelText: "UserCode".tr(),
    //                                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
    //                             validator: (value) => validator(value),
    //                             controller: usercode,
    //                           ),
    //                           StreamBuilder<bool>(
    //                               stream: passwordShow$.stream,
    //                               builder: (context, snapshot) {
    //                                 return Row(
    //                                   children: [
    //                                     Expanded(
    //                                       flex: 5,
    //                                       child: TextFormField(
    //                                         textInputAction: TextInputAction.done,
    //                                         style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0),
    //                                         obscureText: passwordShow$.value,
    //                                         decoration: InputDecoration(
    //                                             contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    //                                             labelText: "Password".tr(),
    //                                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
    //                                         validator: (value) => validator(value),
    //                                         controller: password,
    //                                       ),
    //                                     ),
    //                                     Expanded(
    //                                       flex: 1,
    //                                       child: InkWell(
    //                                         child: Icon((passwordShow$.value == true) ? Icons.visibility_off_sharp : Icons.visibility_sharp),
    //                                         onTap: () => passwordShow$.add(!passwordShow$.value),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 );
    //                               }),
    //                           Row(
    //                             children: [
    //                               Expanded(
    //                                 child: InkWell(
    //                                   onTap: () {
    //                                     setState(() {
    //                                       savePassword = !savePassword;
    //                                     });
    //                                   },
    //                                   child: Row(
    //                                     children: [
    //                                       Checkbox(
    //                                         value: savePassword,
    //                                         onChanged: (v) {
    //                                           setState(() {
    //                                             savePassword = !savePassword;
    //                                           });
    //                                         },
    //                                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //                                       ),
    //                                       Text("Remember me".tr())
    //                                     ],
    //                                   ),
    //                                 ),
    //                               ),
    //                               Expanded(
    //                                 child: InkWell(
    //                                   onTap: () async {
    //                                     var result = await api.forgotPassword(usercode: usercode.text, tenant: tenant.text);
    //                                     var title = result != "\"User not found\"" ? "Success".tr() : "Unsuccessful".tr();
    //                                     var content = result != "\"User not found\"" ? "Password Reset".tr() : "Unsuccessful".tr();
    //                                     await showDialog<String>(
    //                                       context: context,
    //                                       builder: (context) {
    //                                         return Container(
    //                                           child: AlertDialog(
    //                                             title: Text(title),
    //                                             contentPadding: const EdgeInsets.all(16.0),
    //                                             content: Text(content),
    //                                             actions: <Widget>[
    //                                               new TextButton(
    //                                                   child: Text("OK".tr()),
    //                                                   onPressed: () {
    //                                                     Navigator.pop(context);
    //                                                   }),
    //                                             ],
    //                                           ),
    //                                         );
    //                                       },
    //                                     );
    //                                   },
    //                                   child: Text("Forgot Password".tr(), textAlign: TextAlign.right),
    //                                 ),
    //                               )
    //                             ],
    //                           ),
    //                           Material(
    //                             elevation: 5.0,
    //                             borderRadius: BorderRadius.circular(8.0),
    //                             color: Colors.blue,
    //                             child: MaterialButton(
    //                               minWidth: MediaQuery.of(context).size.width,
    //                               padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    //                               onPressed: () {
    //                                 login();
    //                               },
    //                               child: Text("Login".tr(),
    //                                   textAlign: TextAlign.center,
    //                                   style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0).copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
    //                             ),
    //                           ),
    //                         ],
    //                       )
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );

    var bodyProgress = Stack(
      children: <Widget>[
        newNewDesign,
        Container(
          color: Colors.black38,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        )
      ],
    );

    return StreamBuilder(
      stream: loginRequested$.stream,
      builder: (context, snapshot) {
        return loginRequested$.value == true ? bodyProgress : newNewDesign;
      },
    );
  }
}
