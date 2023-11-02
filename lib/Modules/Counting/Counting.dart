import '../../Globals/index.dart';
import 'package:flutter/material.dart';

class Counting extends StatefulWidget {
  @override
  _CountingState createState() => _CountingState();
}

class _CountingState extends State<Counting> {
  @override
  Widget build(BuildContext context) {
    currentContext = context;
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Fixed assets Counting".tr()),
      ),
      body: Container(
        width: w,
        height: h,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              ListView.separated(
                itemCount: fixAssetsCount$.value.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      GetIt.I<CountingService>().selectedCounting$.add(fixAssetsCount$.value.values.toList()[index]);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CountingDetails())).then((value) => currentContext = context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 3, offset: Offset.zero)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent.shade100,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1, offset: Offset.zero)],
                                    ),
                                    child: Text(
                                      fixAssetsCount$.value.values.toList()[index].periodstart != null
                                          ? DateFormat("yyyy/MM/dd").format(fixAssetsCount$.value.values.toList()[index].periodstart!)
                                          : "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(Icons.arrow_forward_rounded),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.shade100,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1, offset: Offset.zero)],
                                    ),
                                    child: Text(
                                      fixAssetsCount$.value.values.toList()[index].periodend != null
                                          ? DateFormat("yyyy/MM/dd").format(fixAssetsCount$.value.values.toList()[index].periodend!)
                                          : "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1, offset: Offset.zero)],
                              ),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          "Branch".tr() + " : ",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          branches$.value[fixAssetsCount$.value.values.toList()[index].branchid]?.name != null
                                              ? branches$.value[fixAssetsCount$.value.values.toList()[index].branchid]!.name!
                                              : "",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                separatorBuilder: (context, index) => Divider(height: 1),
              ),
              SizedBox(
                height: h * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
