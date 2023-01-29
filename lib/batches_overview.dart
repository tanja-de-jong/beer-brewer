import 'package:beer_brewer/batch_creator.dart';
import 'package:beer_brewer/data/store.dart';
import 'package:beer_brewer/steps/cooling.dart';
import 'package:beer_brewer/steps/fermentation.dart';
import 'package:beer_brewer/steps/filtering.dart';
import 'package:beer_brewer/steps/malting.dart';
import 'package:beer_brewer/steps/preparation.dart';
import 'package:beer_brewer/steps/cooking.dart';
import 'package:flutter/material.dart';

import 'brew_step.dart';

class BatchesOverview extends StatefulWidget {
  const BatchesOverview({Key? key}) : super(key: key);

  @override
  _BatchesOverviewState createState() => _BatchesOverviewState();
}

class _BatchesOverviewState extends State<BatchesOverview> {
  bool loading = true;

  List<Map<String, dynamic>> getTexts(Batch batch) {
    return [
      {
        "title": "Voorbereiding",
        "description": PreparationStep(batch: batch)
      },
      {"title": "Maischen", "description": MaltingStep(batch: batch)},
      {"title": "Filteren", "description": FilterStep(batch: batch)},
      {"title": "Koken", "description": CookingStep(batch: batch)},
      {"title": "Afkoelen", "description": CoolingStep(batch: batch,)},
      {"title": "Vergisten", "description": FermentationStep(batch: batch,)},
    ];
  }

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
    Store.loadRecipes();
    Store.loadProducts();
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
                .map((batch) {
              return SizedBox(
                  height: 200,
                  width: 200,
                  child: InkWell(onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              BatchCreator(batch: batch),
                        ),
                      );
                  }, child: Card(
                      margin: EdgeInsets.all(10),
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(children: [
                                Text(
                                  batch.name,
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold),
                                ),
                                getRow("Stijl", Text(batch.style ?? "-")),
                                if (batch.bottleDate == null)
                                  getRow("Vergisting",
                                      Text(daysSinceDate(batch.brewDate))),
                                if (batch.bottleDate != null)
                                  getRow("Gebotteld",
                                      Text(daysSinceDate(batch.bottleDate!))),
                                getRow("Start SG",
                                    Text(
                                        batch.getStartSG()?.toString() ?? "-")),
                                getRow("Eind SG",
                                    Text(batch.getEndSG()?.toString() ?? "-")),
                              ]),
                              batch.brewDate == null
                                  ? ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BrewStep(batch: batch,
                                                  contentList: getTexts(
                                                      batch))),
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
                                    batch.isReadyToBottle()
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
                                            (BuildContext context) =>
                                        [
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
                          )))));
            })
                .toList(),
          );
  }
}
