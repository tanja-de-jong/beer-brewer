import 'package:beer_brewer/data/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BatchesOverview extends StatefulWidget {
  const BatchesOverview({Key? key}) : super(key: key);

  @override
  _BatchesOverviewState createState() => _BatchesOverviewState();
}

class _BatchesOverviewState extends State<BatchesOverview> {
  Row getRow(String label, Widget content) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text("$label:"), content]);
  }

  int daysSinceDate(DateTime date) {
    return DateTime.now().difference(date).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      direction: Axis.horizontal,
      children: Store.batches
          .map((e) => SizedBox(
              height: 200,
              width: 200,
              child: Card(
                  margin: EdgeInsets.all(10),
                  child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(children: [
                            Text(
                              e.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            getRow("Stijl", Text(e.name)),
                            if (e.bottleDate == null)
                              getRow("Vergisting",
                                  Text("${daysSinceDate(e.brewDate)} dagen")),
                            if (e.bottleDate != null)
                              getRow(
                                  "Gebotteld",
                                  Text(
                                      "${daysSinceDate(e.bottleDate!)} dagen")),
                            getRow("Start SG", Text(e.getStartSG().toString())),
                            getRow("Eind SG",
                                Text(e.getEndSG()?.toString() ?? "-")),
                          ]),
                          // ElevatedButton(onPressed: () {}, child: Text("Bottelen")),
                          ToggleButtons(
                              constraints: BoxConstraints(maxHeight: 30),
                              selectedBorderColor: Colors.blue,
                              selectedColor: Colors.white,
                              fillColor: Colors.blue,
                              color: Colors.blue,
                              borderColor: Colors.blue,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              onPressed: (int selected) {},
                              isSelected: [
                                true,
                                false
                              ],
                              children: [
                                e.isReadyToBottle()
                                    ? Text("Bottelen")
                                    : Container(
                                        color: Colors.blue,
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Row(children: [
                                          Icon(Icons.add),
                                          Text("Meting")
                                        ])),
                                PopupMenuButton(
                                    icon: Icon(Icons.keyboard_arrow_down,
                                        size: 20),
                                    itemBuilder: (BuildContext context) => [
                                          PopupMenuItem(child: Text("Bottelen"))
                                        ])
                              ])

                          // OutlinedButton(
                          //     onPressed: () {},
                          //     child: Text(e.bottleDate == null
                          //         ? "Bottelen"
                          //         : "Afronden"))
                        ],
                      )))))
          .toList(),
    );
  }
}
