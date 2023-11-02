import '../../Globals/index.dart';
import 'package:flutter/material.dart';

class Counting_Location extends StatefulWidget {
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

  List<FixAssetLocation> searchFixedAssetsLoaction(String pattern) {
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
        title: Text("Location Counting".tr()),
      ),
      body: Container(
        width: w,
        height: h,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: TextFormField(
                onChanged: (value) {
                  if (value == "") {
                    setState(() {
                      searchingList = allList;
                      return;
                    });
                  }
                  setState(() {
                    searchingList = searchFixedAssetsLoaction(value);
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search Location".tr(),
                  errorStyle: TextStyle(height: 0),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(9),
                    ),
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(9),
                    ),
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                  contentPadding: EdgeInsets.only(left: 10),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  children: [
                    SizedBox(height: 10),
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
                            width: w,
                            padding: EdgeInsets.only(
                              left: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(height: 1),
                                SizedBox(height: 10),
                                Text(
                                  searchingList[i].name ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                                SizedBox(height: 10),
                                Divider(height: 1),
                              ],
                            )),
                      ),
                    SizedBox(
                      height: padding.bottom + 10,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // body: ListView.separated(
      //   itemBuilder: (context, index) => ListTile(
      //     title: Text(fixAssetsLocations$
      //             .value[fixAssets_byLocation$.value.keys.toList()[index]]
      //             .name ??
      //         "-"),
      //     minVerticalPadding: 0,
      //     onTap: () {
      //       if (fixAssets_byLocation$
      //               .value[fixAssets_byLocation$.value.keys.toList()[index]]
      //               .length >
      //           0) {
      //         print(fixAssetsLocations$
      //             .value[fixAssets_byLocation$.value.keys.toList()[index]]
      //             .name);
      //         GetIt.I<Counting_LocationService>().selectedLocation$.add(
      //             fixAssetsLocations$
      //                 .value[fixAssets_byLocation$.value.keys.toList()[index]]);
      //         Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => Counting_LocationDetails(),
      //             )).then((value) => currentContext = context);
      //       }
      //     },
      //   ),
      //   separatorBuilder: (context, index) => Divider(
      //     height: 1,
      //   ),
      //   itemCount: fixAssets_byLocation$.value.length,
      // ),
    );
  }
}
