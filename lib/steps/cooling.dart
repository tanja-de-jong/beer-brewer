import 'package:beer_brewer/screen.dart';
import 'package:beer_brewer/steps/fermentation.dart';
import 'package:beer_brewer/steps/steps.dart';
import 'package:flutter/material.dart';

import '../models/batch.dart';
import '../models/recipe.dart';

class CoolingStep extends StatefulWidget {
  final Batch batch;

  const CoolingStep({Key? key, required this.batch})
      : super(key: key);

  @override
  State<CoolingStep> createState() => _CoolingStepState();
}

class _CoolingStepState extends State<CoolingStep> {
  late Recipe recipe;
  late Batch batch;
  List<String> steps = [
    "Vanaf nu is het extra belangrijk om steriel te werk te gaan!",
    "Zet de pan in de gootsteen en vul de gootsteen met koud water en ijsblokjes.",
    "Zet de thermometer uit en weer aan en stel deze in op 26ºC met een afwijking van 1ºC.",
    "Ververs af en toe het koude water."
  ];

  @override
  void initState() {
    batch = widget.batch;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(title: "Koelen", bottomButton: ElevatedButton(
      child: const Text("Volgende"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => FermentationStep(
                batch: widget.batch,
              )),
        );
      },
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Steps(steps: steps),
    ]));
  }
}
