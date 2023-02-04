import 'package:beer_brewer/form/DoubleTextFieldRow.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/store.dart';
import '../form/TextFieldRow.dart';
import '../models/batch.dart';

class BottlingStep extends StatefulWidget {
  final Batch batch;

  const BottlingStep({Key? key, required this.batch})
      : super(key: key);

  @override
  State<BottlingStep> createState() => _BottlingStepState();
}

class _BottlingStepState extends State<BottlingStep> {
  late Batch batch;
  Map<String, bool> steps = {};
  DateTime? date;
  double? batchAmount;
  List<String> texts = [];

  @override
  void initState() {
    batch = widget.batch;

    updateTexts();

    for (String text in texts) {
      steps[text] = false;
    }

    super.initState();
  }

  void updateTexts() {
    setState(() {
      texts = [
        "Zorg dat de flesjes schoon en steriel zijn.",
        "Schenk het bier voorzichtig over in een pan, zodat het besinksel achterblijft.",
        "Spoel de emmer schoon en schenk het bier hier weer in terug."];

      if (batch.bottleSugar != null && batch.bottleSugar!.products != null && batch.bottleSugar!.products!.isNotEmpty) {
        double sugarAmount = batch.bottleSugar!.products![0].amount.toDouble();
        if (batchAmount == null) {
          texts.add("Weeg per liter $sugarAmount gram suiker af.");
          texts.add("Vul de hoeveelheid suiker aan met water tot 15 ml per liter.");
        } else {
          texts.add("Weeg ${sugarAmount * batchAmount!} gram suiker af.");
          texts.add("Vul de hoeveelheid suiker aan met water tot ${15 * batchAmount!} ml.");
        }
        texts.add("Breng het suikerwater kort aan de kook.");
        texts.add("Voeg het suikerwater toe aan de emmer.");
      }
      texts.add("Gebruik het tapkraantje om de flesjes tot twee centimeter onder de rand te vullen.");
      texts.add("Sluit de flesjes met het kroonkurkapparaat en kroonkurken.");
      texts.add("Draai de flesjes even om en terug en zet ze twee tot drie weken weg bij ${batch.getFermentationTemperature()}.");
    });

    Map<String, bool> temp = {};
    for (int i = 0; i < steps.values.length; i++) {
      temp[texts[i]] =  steps.values.toList()[i];
    }
    steps = temp;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DoubleTextFieldRow(label: "Aantal liters", onChanged: (value) {
        setState(() {
          batchAmount = value;
          updateTexts();
        });
      },),
      const Text("Stappen", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      ...steps.keys.map((step) => Row(children: [Checkbox(value: steps[step], onChanged: (value){
        setState(() {
          steps[step] = !(steps[step] ?? true);
        });
      }), Text(step)])),
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
    ]);
  }
}
