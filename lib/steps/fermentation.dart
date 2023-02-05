import 'package:beer_brewer/form/DoubleTextFieldRow.dart';
import 'package:beer_brewer/screen.dart';
import 'package:beer_brewer/steps/steps.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../batch/batches_overview.dart';
import '../data/store.dart';
import '../form/TextFieldRow.dart';
import '../models/batch.dart';

class FermentationStep extends StatefulWidget {
  final Batch batch;

  const FermentationStep({Key? key, required this.batch})
      : super(key: key);

  @override
  State<FermentationStep> createState() => _FermentationStepState();
}

class _FermentationStepState extends State<FermentationStep> {
  late Batch batch;
  List<String> steps = [];

  @override
  void initState() {
    batch = widget.batch;

    steps = [
      "Giet het (zo helder mogelijke) wort in de schone, steriele vergistingsemmer.",
      "Meet het SG met de refractometer.",
      "Voeg de gist toe en roer goed door.",
      "Sluit de emmer af, vul het waterslot voor 3/4 met water en plaats deze in het deksel."
      "Zet de emmer 2 tot 3 weken in een donkere ruimte met een temperatuur tussen ${batch.getFermentationTemperature()}."
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(title: "Vergisting", bottomButton: ElevatedButton(onPressed: () {
      Store.brewBatch(widget.batch, Store.date, Store.startSG ?? 0);
      Store.startSG = null;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
              const BatchesOverview()),
              (Route<dynamic> route) => false);
    }, child: const Text("Rond af")), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Steps(steps: steps),
      const SizedBox(height: 20),
      TextFieldRow(
        label: "Datum",
        initialValue: DateFormat("dd-MM-yyyy").format(DateTime.now()),
        onChanged: (value) {
          setState(() {
            Store.date = DateFormat("dd-MM-yyyy").parse(value);
          });
        },
      ),
      const SizedBox(height: 10),
      DoubleTextFieldRow(label: "SG", onChanged: (value) {
        setState(() {
          Store.startSG = value;
        });
      })
    ]));
  }
}
