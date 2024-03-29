import 'package:beer_brewer/screen.dart';
import 'package:beer_brewer/steps/cooling.dart';
import 'package:beer_brewer/steps/steps.dart';
import 'package:flutter/material.dart';

import '../models/batch.dart';
import '../models/recipe.dart';

class CookingStep extends StatefulWidget {
  final Batch batch;

  const CookingStep({Key? key, required this.batch})
      : super(key: key);

  @override
  State<CookingStep> createState() => _CookingStepState();
}

class _CookingStepState extends State<CookingStep> {
  late Recipe recipe;
  late Batch batch;
  List<String> steps = [];

  @override
  void initState() {
    batch = widget.batch;

    steps = [
      "Breng het wort aan een zacht rollende kook.",
      "Zorg er te allen tijde voor dat het deksel een beetje schuin op de pan staat.",
      "Voeg de hop toe volgens het kookschema.",
      "Vul na het koken, indien nodig, aan tot ${batch.amount} liter met heet water.",
      "Giet het wort voorzichtig over in de andere pan en probeer zoveel mogelijk resten achter te laten."
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(title: "Koken", bottomButton: ElevatedButton(
      child: const Text("Volgende"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => CoolingStep(
                batch: widget.batch,
              )),
        );
      },
    ), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Steps(steps: steps),
      const SizedBox(height: 20),
      const Text("Kookschema", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      batch.getCookingSchedule()
    ]));
  }
}
