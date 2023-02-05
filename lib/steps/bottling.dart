import 'package:beer_brewer/form/DoubleTextFieldRow.dart';
import 'package:beer_brewer/screen.dart';
import 'package:beer_brewer/steps/steps.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../batch/batches_overview.dart';
import '../data/store.dart';
import '../form/TextFieldRow.dart';
import '../models/batch.dart';

class BottlingStep extends StatefulWidget {
  final Batch batch;

  const BottlingStep({Key? key, required this.batch}) : super(key: key);

  @override
  State<BottlingStep> createState() => _BottlingStepState();
}

class _BottlingStepState extends State<BottlingStep> {
  late Batch batch;
  DateTime? date;
  double? batchAmount;
  List<String> steps = [];

  @override
  void initState() {
    batch = widget.batch;
    updateSteps();

    super.initState();
  }

  void updateSteps() {
    setState(() {
      steps = [
        "Zorg dat de flesjes schoon en steriel zijn.",
        "Schenk het bier voorzichtig over in een pan, zodat het besinksel achterblijft.",
        "Spoel de emmer schoon en schenk het bier hier weer in terug."
      ];

      if (batch.bottleSugar != null &&
          batch.bottleSugar!.products != null &&
          batch.bottleSugar!.products!.isNotEmpty) {
        double sugarAmount = batch.bottleSugar!.products![0].amount.toDouble();
        if (batchAmount == null) {
          steps.add("Weeg per liter $sugarAmount gram suiker af.");
          steps.add(
              "Vul de hoeveelheid suiker aan met water tot 15 ml per liter.");
        } else {
          steps.add("Weeg ${sugarAmount * batchAmount!} gram suiker af.");
          steps.add(
              "Vul de hoeveelheid suiker aan met water tot ${15 * batchAmount!} ml.");
        }
        steps.add("Breng het suikerwater kort aan de kook.");
        steps.add("Voeg het suikerwater toe aan de emmer.");
      }
      steps.add(
          "Gebruik het tapkraantje om de flesjes tot twee centimeter onder de rand te vullen.");
      steps.add("Sluit de flesjes met het kroonkurkapparaat en kroonkurken.");
      steps.add(
          "Draai de flesjes even om en terug en zet ze twee tot drie weken weg bij ${batch.getFermentationTemperature()}.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
        title: "Bottelen",
        bottomButton: ElevatedButton(
            onPressed: () {
              Store.bottleBatch(widget.batch, Store.date);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const BatchesOverview()),
                  (Route<dynamic> route) => false);
            },
            child: const Text("Rond af")),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DoubleTextFieldRow(
            label: "Aantal liters",
            onChanged: (value) {
              setState(() {
                batchAmount = value;
                updateSteps();
              });
            },
          ),
          Steps(steps: steps),
          SizedBox(height: 20),
          TextFieldRow(
            label: "Datum",
            initialValue: DateFormat("dd-MM-yyyy").format(DateTime.now()),
            onChanged: (value) {
              setState(() {
                Store.date = DateFormat("dd-MM-yyyy").parse(value);
              });
            },
          ),
        ]));
  }
}
