import 'package:beer_brewer/batch/batch_details.dart';
import 'package:beer_brewer/data/store.dart';
import 'package:beer_brewer/steps/cooling.dart';
import 'package:beer_brewer/steps/fermentation.dart';
import 'package:beer_brewer/steps/filtering.dart';
import 'package:beer_brewer/steps/malting.dart';
import 'package:beer_brewer/steps/preparation.dart';
import 'package:beer_brewer/steps/cooking.dart';
import 'package:flutter/material.dart';

import '../steps/brew_step.dart';
import '../models/batch.dart';

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
    return Center(child: loading
        ? const CircularProgressIndicator()
        : Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: DataTable(
          showCheckboxColumn: false,
          rows: Store.batches
              .map(
                (b) => DataRow(
                cells: [
                  DataCell(Text(b.name)),
                  DataCell(Text(b.getStatus().text)),
                ],
                onSelectChanged: (bool? selected) async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          BatchDetails(batch: b),
                    ),
                  );
                }),
          )
              .toList(),
          columns: const [
            DataColumn(label: Text("Naam", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
      )
    ]));



    Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            direction: Axis.horizontal,
            children: Store.batches
                .map((batch) {
              return Card(
                  margin: const EdgeInsets.all(10),
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(children: [
                            Text(
                              batch.name,
                              style:
                              const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Status:"), const Text("Stijl:")],),
                            SizedBox(width: 10),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(batch.getStatus().text), Text(batch.style ?? "-")],)
                              ])
                          ]),
                          SizedBox(height: 20),
                          ElevatedButton(onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    BatchDetails(batch: batch),
                              ),
                            );
                          }, child: const Text("Bekijken"))
                        ],
                      )));
            })
                .toList(),
          );
  }
}
