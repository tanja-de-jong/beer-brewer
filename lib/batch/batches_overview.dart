import 'package:beer_brewer/authentication/authentication.dart';
import 'package:beer_brewer/batch/batch_details.dart';
import 'package:beer_brewer/data/store.dart';
import 'package:beer_brewer/main.dart';
import 'package:beer_brewer/screen.dart';
import 'package:beer_brewer/steps/cooling.dart';
import 'package:beer_brewer/steps/fermentation.dart';
import 'package:beer_brewer/steps/filtering.dart';
import 'package:beer_brewer/steps/malting.dart';
import 'package:beer_brewer/steps/preparation.dart';
import 'package:beer_brewer/steps/cooking.dart';
import 'package:flutter/material.dart';

import '../models/batch.dart';
import '../settings.dart';

class BatchesOverview extends StatefulWidget {
  const BatchesOverview({Key? key}) : super(key: key);

  @override
  _BatchesOverviewState createState() => _BatchesOverviewState();
}

class _BatchesOverviewState extends State<BatchesOverview> {
  bool loading = true;

  List<Map<String, dynamic>> getTexts(Batch batch) {
    return [
      {"title": "Voorbereiding", "description": PreparationStep(batch: batch)},
      {"title": "Maischen", "description": MaltingStep(batch: batch)},
      {"title": "Filteren", "description": FilterStep(batch: batch)},
      {"title": "Koken", "description": CookingStep(batch: batch)},
      {
        "title": "Afkoelen",
        "description": CoolingStep(
          batch: batch,
        )
      },
      {
        "title": "Vergisten",
        "description": FermentationStep(
          batch: batch,
        )
      },
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

  void showSnackBar() {
    if (Store.newGroups.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.blue,
        showCloseIcon: true,
          duration: Duration(minutes: 1000),
          content: Text(Store.newGroups.length == 1
              ? "Je bent toegevoegd aan de groep: '${Store.newGroups.first}'"
              : "Je bent toegevoegd aan de groepen: ${Store.newGroups.join(', ')}")));
    }
  }

  @override
  void initState() {
    Store.loadData().then((value) => setState(() {
          showSnackBar();
          loading = false;
        }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
        title: 'Batches',
        page: OverviewPage.batches,
        loading: loading,
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Settings()));
                },
                child: const Icon(
                  Icons.settings,
                  size: 26.0,
                ),
              )),
        ],
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
            DataColumn(
                label: Text("Naam",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Status",
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ));
  }
}
