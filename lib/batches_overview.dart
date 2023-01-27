import 'package:beer_brewer/data/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'brew_step.dart';

class BatchesOverview extends StatefulWidget {
  const BatchesOverview({Key? key}) : super(key: key);

  @override
  _BatchesOverviewState createState() => _BatchesOverviewState();
}

class _BatchesOverviewState extends State<BatchesOverview> {
  bool loading = true;

  List<Map<String, String>> texts = [
    {"title": "Voorbereiding", "description": ""},
    {"title": "Maischen", "description": ""},
    {"title": "Filteren", "description": ""},
    {"title": "Spoelen", "description": ""},
    {"title": "Koken", "description": ""},
    {"title": "Afkoelen", "description": ""},
    {"title": "Vergisten", "description": ""},
  ];

  Row getRow(String label, Widget content) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text("$label:"), content]);
  }

  String daysSinceDate(DateTime? date) {
    if (date == null) return "-";
    return "${DateTime.now().difference(date).inDays} dagen";
  }

  @override
  void initState() {
    Store.loadBatches().then((value) => setState(() {
          loading = false;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        : Wrap(
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  getRow("Stijl", Text(e.recipe.style)),
                                  if (e.bottleDate == null)
                                    getRow("Vergisting",
                                        Text(daysSinceDate(e.brewDate))),
                                  if (e.bottleDate != null)
                                    getRow("Gebotteld",
                                        Text(daysSinceDate(e.bottleDate!))),
                                  getRow("Start SG",
                                      Text(e.getStartSG()?.toString() ?? "-")),
                                  getRow("Eind SG",
                                      Text(e.getEndSG()?.toString() ?? "-")),
                                ]),
                                e.brewDate == null
                                    ? ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BrewStep(batch: e, texts: texts)),
                                          );
                                        },
                                        child: Text("Start"))
                                    : ToggleButtons(
                                        constraints:
                                            BoxConstraints(maxHeight: 30),
                                        selectedBorderColor: Colors.blue,
                                        selectedColor: Colors.white,
                                        fillColor: Colors.blue,
                                        color: Colors.blue,
                                        borderColor: Colors.blue,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
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
                                                icon: Icon(
                                                    Icons.keyboard_arrow_down,
                                                    size: 20),
                                                itemBuilder:
                                                    (BuildContext context) => [
                                                          PopupMenuItem(
                                                              child: Text(
                                                                  "Bottelen"))
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
