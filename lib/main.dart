import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fixed_assets_v3/Services/Database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Elektra FixedAssets',
      theme: ThemeData(
        backgroundColor: Colors.white,
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: Theme.of(context).textTheme.copyWith(
            // bodyText1: Theme.of(context).textTheme.bodyText1.apply(color: Colors.black87)
            ),
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
  final api = GetIt.I<Api>();
  final formkey = GlobalKey<FormState>();
  BehaviorSubject loginRequested$ = BehaviorSubject.seeded(false);
  bool savePassword = false;

  TextEditingController authcodeController = TextEditingController(text: "");
  final endPoint = TextEditingController(text: "");
  // final endPoint =
  //     TextEditingController(text: "https://api.hillsidebeachclub.com");
  final tenant = TextEditingController(text: "");
  final usercode = TextEditingController(text: "");
  final password = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();

    initStorageVariables();
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

      // if (await Hive.box('userOperations').get('savePassword') ?? false) {
      //   tenant.text = await Hive.box('userOperations').get('tenant') ?? "";
      //   usercode.text = await Hive.box('userOperations').get('userCode') ?? "";
      //   password.text = await Hive.box('userOperations').get('password') ?? "";
      // }

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

      tenant.text = "20854";
      usercode.text = "demo";
      password.text = "123";

      // endPoint.text = "https://api.hillsidebeachclub.com";
      // tenant.text = "27214";
      // usercode.text = "ElektraWeb";
      // password.text = "s9@|eBTD198q";
    } else {
      print("RELEASE MODE !!!");
      setState(() async {
        endPoint.text = await Hive.box('userOperations').get('endPoint') ?? "";
        tenant.text = await Hive.box('userOperations').get('tenant') ?? "";
        usercode.text = await Hive.box('userOperations').get('userCode') ?? "";
        savePassword = await Hive.box('userOperations').get('savePassword') ?? false;
        if (savePassword == true) {
          password.text = await Hive.box('userOperations').get('password') ?? "";
        }
      });
    }
  }

  validator(value) {
    if (value.isEmpty) {
      return "Please don't leave this field empty".tr();
    }
    return null;
  }

  Future<void> login() async {
    if (formkey.currentState!.validate()) {
      loginRequested$.add(true);
      try {
        // endPoint.text = "https://cactusapi.pixagor.net";
        // tenant.text = "27741";
        // usercode.text = "ismail.ulgudur";
        // password.text = "Ch483435.";
        await api.login(tenant.text, usercode.text, password.text,
            endPoint: endPoint.text == "" ? null : endPoint.text, authcode: authcodeController.text == "" ? null : authcodeController.text);
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
        }
      } on Exception catch (e) {
        print(e.toString());
        if (e.toString().contains("Code: 30")) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Enter 2FA Code".tr()),
                content: TextField(
                  controller: authcodeController,
                  keyboardType: TextInputType.number,
                ),
                actions: [
                  TextButton(
                    child: Text("Cancel".tr()),
                    onPressed: () {
                      Navigator.of(context).pop();
                      loginRequested$.add(false);
                    },
                  ),
                  TextButton(
                    child: Text("OK".tr()),
                    onPressed: () {
                      login();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          loginRequested$.add(false);
          print(e.toString());
          await showWarningDialog("Wrong information".tr(), e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext pageContext) {
    currentContext = pageContext;
    final double h = MediaQuery.of(context).size.height;
    final double w = MediaQuery.of(context).size.height;

    BehaviorSubject<bool> passwordShow$ = BehaviorSubject.seeded(true);

    var newNewDesign = Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: InkWell(
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                      onTap: () {
                        showDialog(
                          context: pageContext,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Settings".tr()),
                              content: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
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
                                              color: context.locale.languageCode == "tr" ? Colors.blue : Colors.grey,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                          ),
                                          onTap: () {
                                            context.locale = Locale('tr');
                                            Navigator.pop(context);
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
                                              color: context.locale.languageCode == "en" ? Colors.blue : Colors.grey,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                          ),
                                          onTap: () {
                                            context.locale = Locale('en');
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextFormField(
                                    textInputAction: TextInputAction.next,
                                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0),
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                        labelText: "EndPoint (Optional)".tr(),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
                                    controller: endPoint,
                                  ),
                                  Center(
                                    child: Text("App Version : ${packageInfo.version}+${packageInfo.buildNumber}"),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: Icon(
                                    Icons.done,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  height: h - 50,
                  child: Center(
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Wrap(
                            spacing: 20,
                            runSpacing: 10,
                            children: [
                              Container(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Center(
                                        child: Image(
                                          image: AssetImage('assets/images/POS_LOGO.png'),
                                          height: h / 6,
                                        ),
                                      ),
                                    ),
                                    Text("Elektra " + "Fixed Assets".tr(), style: TextStyle(color: Colors.black87, fontSize: 26))
                                  ],
                                ),
                              ),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0),
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                    labelText: "Tenant".tr(),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
                                validator: (value) => validator(value),
                                controller: tenant,
                              ),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0),
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                    labelText: "UserCode".tr(),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
                                validator: (value) => validator(value),
                                controller: usercode,
                              ),
                              StreamBuilder<bool>(
                                  stream: passwordShow$.stream,
                                  builder: (context, snapshot) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: TextFormField(
                                            textInputAction: TextInputAction.done,
                                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0),
                                            obscureText: passwordShow$.value,
                                            decoration: InputDecoration(
                                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                                labelText: "Password".tr(),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
                                            validator: (value) => validator(value),
                                            controller: password,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            child: Icon((passwordShow$.value == true) ? Icons.visibility_off_sharp : Icons.visibility_sharp),
                                            onTap: () => passwordShow$.add(!passwordShow$.value),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          savePassword = !savePassword;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: savePassword,
                                            onChanged: (v) {
                                              setState(() {
                                                savePassword = !savePassword;
                                              });
                                            },
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          Text("Remember me".tr())
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        var result = await api.forgotPassword(usercode: usercode.text, tenant: tenant.text);
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
                                                actions: <Widget>[
                                                  new TextButton(
                                                      child: Text("OK".tr()),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      }),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Text("Forgot Password".tr(), textAlign: TextAlign.right),
                                    ),
                                  )
                                ],
                              ),
                              Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.blue,
                                child: MaterialButton(
                                  minWidth: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                  onPressed: () {
                                    login();
                                  },
                                  child: Text("Login".tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0).copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    var bodyProgress = new Container(
      child: new Stack(
        children: <Widget>[
          newNewDesign,
          new Container(
            color: Colors.black38,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          )
        ],
      ),
    );

    return StreamBuilder(
      stream: loginRequested$.stream,
      builder: (context, snapshot) {
        return loginRequested$.value == true ? bodyProgress : newNewDesign;
      },
    );
  }
}
