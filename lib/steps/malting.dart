import 'package:beer_brewer/screen.dart';
import 'package:beer_brewer/steps/steps.dart';
import 'package:flutter/material.dart';

import '../models/batch.dart';
import '../models/product.dart';
import '../models/spec_to_products.dart';
import '../util.dart';
import 'filtering.dart';

class MaltingStep extends StatefulWidget {
  final Batch batch;

  const MaltingStep({Key? key, required this.batch}) : super(key: key);

  @override
  State<MaltingStep> createState() => _MaltingStepState();
}

class _MaltingStepState extends State<MaltingStep> {
  late Batch batch;
  List<String> steps = [];

  @override
  void initState() {
    batch = widget.batch;

    steps = [
      "Plaats de filterzak in een pan.",
      "Verwarm ${batch.getBiabWater()} liter water (voor zover mogelijk) tot een paar graden boven ${batch.mashing.steps.isEmpty ? '?' : batch.mashing.steps[0].temp}°C.",
      "Vul de pan met het warme water.",
      "Als deze temperatuur is bereikt, voeg dan alle mout toe.",
      "Stel de thermometer en timer in en roer regelmatig door.",
      "Volg hierna het maischschema.",
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
        title: "Maischen",
        bottomButton: ElevatedButton(
          child: const Text("Volgende"),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => FilterStep(
                        batch: widget.batch,
                      )),
            );
          },
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Steps(steps: steps),
          const SizedBox(height: 20),
          const Text("Maischschema",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Table(
              border: TableBorder.all(),
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                const TableRow(children: [
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Temperatuur",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Tijd",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
                ...batch.mashing.steps.map(
                  (s) => TableRow(children: [
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text("${s.temp}ºC")),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text("${s.time} min"))
                  ]),
                )
              ]),
          const SizedBox(height: 20),
          const Text("Mouten", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          ...batch.mashing.malts.expand((stp) => stp.products ?? []).map((pi) =>
              Text(
                  "${Util.amountToString((pi as ProductInstance).amount)} ${pi.product.name} van ${pi.product.brand} (${(pi.product as Malt).ebcToString()})")),
          const SizedBox(height: 10),
        ]));
  }
}
