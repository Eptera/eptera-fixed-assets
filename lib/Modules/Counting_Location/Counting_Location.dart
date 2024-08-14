import 'package:flutter/services.dart';

import '../../Globals/index.dart';
import 'package:flutter/material.dart';

class Counting_Location extends StatefulWidget {
  const Counting_Location({super.key});

  @override
  _Counting_LocationState createState() => _Counting_LocationState();
}

class _Counting_LocationState extends State<Counting_Location> {
  List<FixAssetLocation> searchingList = [];
  List<FixAssetLocation> allList = [];

  var search = TextEditingController(text: "");
  BehaviorSubject<List<FixAssetLocation>> newList$ = BehaviorSubject.seeded([]);

  late StreamSubscription barcodeListener;
  bool firstRun = true;

  List<FixAssetLocation> searchFixedAssetsLocation(String pattern) {
    var value = searchingList.where((item) {
      if (item.name == null) {
        return false;
      }
      return item.name!.toLowerCase().contains(pattern.toLowerCase());
    });
    return value.isEmpty ? [] : value.toList();
  }

  @override
  void didUpdateWidget(covariant Counting_Location oldWidget) {
    fixAssets_byLocation$.add(fixAssets_byLocation$.value);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kWhite,
    ));

    for (var i = 0; i < fixAssets_byLocation$.value.keys.toList().length; i++) {
      if (fixAssets_byLocation$.value[fixAssets_byLocation$.value.keys.toList()[i]] != null &&
          fixAssets_byLocation$.value[fixAssets_byLocation$.value.keys.toList()[i]]!.isNotEmpty) {
        searchingList.add(fixAssetsLocations$.value[fixAssets_byLocation$.value.keys.toList()[i]]!);
        allList.add(fixAssetsLocations$.value[fixAssets_byLocation$.value.keys.toList()[i]]!);
      }
    }
    searchingList.sort(((a, b) => (a.name ?? "").compareTo(b.name ?? "")));

    allList.sort(((a, b) => (a.name ?? "").compareTo(b.name ?? "")));

    barcodeListener = lastBarcode$.listen((barcode) async {
      if ((scannerBusy.value == false)) {
        scannerBusy.add(true);
        if (firstRun) {
          firstRun = false;
          print("First Time.");
        } else {
          int? fixAssetLocationId;

          for (var i = 0; i < fixAssetsLocations$.value.values.toList().length; i++) {
            if (fixAssetsLocations$.value.values.toList()[i].barcode == barcode) {
              fixAssetLocationId = fixAssetsLocations$.value.values.toList()[i].id;
              break;
            }
          }

          if (fixAssetLocationId != null) {
            barcodeListener.pause();
            GetIt.I<Counting_LocationService>().selectedLocation$.add(fixAssetsLocations$.value[fixAssetLocationId]);

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Counting_LocationDetails(),
                )).then((value) {
              currentContext = context;
              print(barcodeListener.isPaused);
              // lastBarcode$.add("");
              // scannerBusy.add(false);
              barcodeListener.resume();
            });
          }
        }
        scannerBusy.add(false);
      }
    });

    super.initState();
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
      ),
      body: SizedBox(
        width: w,
        height: h,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Text("Location Counting".tr(),style: k24w600Black(color: kGrey900),),
              SizedBox(height: 16,),
              CTextFormField(
                hintText: "Search Location".tr(),
                textInputAction: TextInputAction.done, onChange: (value) {
                if (value == "") {
                  setState(() {
                    searchingList = allList;
                    return;
                  });
                }
                setState(() {
                  searchingList = searchFixedAssetsLocation(value);
                });
              },hasIcon: true, iconPath: "assets/images/search_logo.svg",),
              SizedBox(height: 20,),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: Column(
                    children: [
                      for (var i = 0; i < searchingList.length; i++)
                        InkWell(
                          onTap: () {
                            {
                              barcodeListener.pause();

                              GetIt.I<Counting_LocationService>().selectedLocation$.add(allList.firstWhere((element) => element.id == searchingList[i].id));

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Counting_LocationDetails(),
                                  )).then((value) {
                                currentContext = context;
                                barcodeListener.resume();
                              });
                            }
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: kBorderColor2))
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  searchingList[i].name ?? "",
                                  style: k14w500Black(color: kGrey700),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                                SvgPicture.asset("assets/images/arrow_right.svg")
                              ],
                            ),
                          ),
                        ),
                      SizedBox(
                        height: padding.bottom + (h * 0.1),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
