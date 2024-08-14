import 'package:flutter/services.dart';

import '../../Globals/index.dart';
import 'package:flutter/material.dart';

class Counting extends StatefulWidget {
  const Counting({super.key});

  @override
  _CountingState createState() => _CountingState();
}

class _CountingState extends State<Counting> {

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kWhite,
    ));
  }

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
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

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Text("Counting".tr(),style: k24w600Black(color: kGrey900),),
            SizedBox(height: 20,),
            ListView.builder(
              itemCount: fixAssetsCount$.value.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: h * 0.2),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    GetIt.I<CountingService>().selectedCounting$.add(fixAssetsCount$.value.values.toList()[index]);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CountingDetails())).then((value) => currentContext = context);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                        decoration: BoxDecoration(
                          color: kGrey50,
                          border: Border.all(color: kBorderColor2),
                          borderRadius: BorderRadius.only(topRight: Radius.circular(12),topLeft: Radius.circular(12)),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0C101828),
                              blurRadius: 1.64,
                              offset: Offset(0, 0.82),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child:
                        Row(
                          children: [
                            Container(
                              width: (w - 90) / 2,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFECDC9))),
                              child: Text(
                                fixAssetsCount$.value.values.toList()[index].periodstart != null
                                    ? DateFormat("yyyy/MM/dd").format(fixAssetsCount$.value.values.toList()[index].periodstart!)
                                    : "",
                                style: k14w500Black(
                                  color: const Color(0xFFB32218),
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
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
                            Container(
                              width: (w - 90) / 2,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFAAEFC6))),
                              child: Text(
                                fixAssetsCount$.value.values.toList()[index].periodend != null
                                    ? DateFormat("yyyy/MM/dd").format(fixAssetsCount$.value.values.toList()[index].periodend!)
                                    : "",
                                style: k14w500Black(
                                  color: const Color(0xFF067647),
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kWhite,
                          border: Border(
                            left: BorderSide(width: 0.82, color: kBorderColor2),
                            right: BorderSide(width: 0.82, color: kBorderColor2),
                            bottom: BorderSide(width: 0.82, color: kBorderColor2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0C101828),
                              blurRadius: 1.64,
                              offset: Offset(0, 0.82),
                              spreadRadius: 0,
                            )
                          ],
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset("assets/images/branch.svg"),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  branches$.value[fixAssetsCount$.value.values.toList()[index].branchid]?.name != null
                                      ? branches$.value[fixAssetsCount$.value.values.toList()[index].branchid]!.name!
                                      : "",
                                  style: k14w400Black(color: kGrey600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
