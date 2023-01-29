import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/store.dart';

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
  Map<String, bool> steps = {};

  @override
  void initState() {
    batch = widget.batch;

    for (String text in [
      "Vanaf nu is het extra belangrijk om steriel te werk te gaan!",
      "Zet de pan in de gootsteen en vul de gootsteen met koud water en ijsblokjes.",
      "Zet de thermometer uit en weer aan en stel deze in op 26ºC met een afwijking van 1ºC.",
      "Ververs af en toe het koude water."
    ]) {
      steps[text] = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Stappen", style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height: 5),
      ...steps.keys.map((step) => Row(children: [Checkbox(value: steps[step], onChanged: (value){
        setState(() {
          steps[step] = !(steps[step] ?? true);
        });
      }), Text(step)])),
    ]);
  }
}
