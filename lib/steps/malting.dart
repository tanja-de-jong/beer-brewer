import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/store.dart';
import '../util.dart';

class MaltingStep extends StatefulWidget {
  final Batch batch;

  const MaltingStep({Key? key, required this.batch})
      : super(key: key);

  @override
  State<MaltingStep> createState() => _MaltingStepState();
}

class _MaltingStepState extends State<MaltingStep> {
  late Batch batch;
  Map<String, bool> steps = {};

  @override
  void initState() {
    batch = widget.batch;

    for (String text in [
      "Plaats de filterzak in een pan.",
      "Verwarm ${batch.getBiabWater()} liter water (voor zover mogelijk) tot een paar graden boven ${batch.mashing.steps.isEmpty ? '?' : batch.mashing.steps[0].temp}°C.",
      "Vul de pan met het warme water.",
      "Als deze temperatuur is bereikt, voeg dan alle mout toe.",
      "Stel de thermometer en timer in en roer regelmatig door.",
      "Volg hierna het maischschema.",
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
        SizedBox(height: 20),
        const Text("Maischschema", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Table(
            border:
            TableBorder.all(),
            defaultColumnWidth:
            const IntrinsicColumnWidth(),
            children: [
              TableRow(
                  children: [
                    Padding(
                        padding:
                        const EdgeInsets.all(10),
                        child: Text("Temperatuur", style: TextStyle(fontWeight: FontWeight.bold),)),
                    Padding(
                        padding: const EdgeInsets.all(
                            10),
                        child: Text("Tijd", style: TextStyle(fontWeight: FontWeight.bold))),
                  ]),
              ...batch.mashing.steps
                  .map(
                    (s) => TableRow(
                    children: [
                      Padding(
                          padding:
                          const EdgeInsets.all(10),
                          child: Text("${s.temp}ºC")),
                      Padding(
                          padding:
                          const EdgeInsets.all(10),
                          child: Text("${s.time} min"))
                    ]),
              )]
        ),
        SizedBox(height: 20),
        const Text("Mouten", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        ...batch.mashing.malts.expand((stp) => stp.products ?? []).map((pi) => Text("${Util.amountToString(pi.amount)} ${pi.product.name} van ${pi.product.brand} (${(pi.product as Malt).ebcToString()})")),
        SizedBox(height: 10),
    ]);
  }
}
