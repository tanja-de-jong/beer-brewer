import 'package:beer_brewer/screen.dart';
import 'package:beer_brewer/steps/steps.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../batch/batches_overview.dart';
import '../data/store.dart';
import '../form/TextFieldRow.dart';
import '../models/batch.dart';

class LageringStep extends StatefulWidget {
  final Batch batch;

  const LageringStep({Key? key, required this.batch})
      : super(key: key);

  @override
  State<LageringStep> createState() => _LageringStepState();
}

class _LageringStepState extends State<LageringStep> {
  late Batch batch;
  List<String> steps = ["Zet de emmer een week in de koelkast."];

  @override
  void initState() {
    batch = widget.batch;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(title: "Lageren", bottomButton: ElevatedButton(onPressed: () {
      Store.lagerBatch(widget.batch, Store.date);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
              const BatchesOverview()),
              (Route<dynamic> route) => false);
    }, child: const Text("Rond af")), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
