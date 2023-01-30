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
  Map<String, bool> steps = {};

  @override
  void initState() {
    batch = widget.batch;

    for (String text in [
      "Breng het wort aan een zacht rollende kook.",
      "Zorg er te allen tijde voor dat het deksel een beetje schuin op de pan staat.",
      "Voeg de hop toe volgens het kookschema.",
      "Vul na het koken, indien nodig, aan tot ${batch.amount} liter met heet water.",
      "Giet het wort voorzichtig over in de andere pan en probeer zoveel mogelijk resten achter te laten."
    ]) {
      steps[text] = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Stappen", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      ...steps.keys.map((step) => Row(children: [Checkbox(value: steps[step], onChanged: (value){
        setState(() {
          steps[step] = !(steps[step] ?? true);
        });
      }), Text(step)])),
      const SizedBox(height: 20),
      const Text("Kookschema", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      batch.getCookingSchedule()
    ]);
  }
}
