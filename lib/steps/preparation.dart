import 'package:beer_brewer/screen.dart';
import 'package:beer_brewer/steps/steps.dart';
import 'package:flutter/material.dart';

import '../models/spec_to_products.dart';
import '../models/batch.dart';
import '../models/product.dart';
import '../util.dart';
import 'malting.dart';

class PreparationStep extends StatefulWidget {
  final Batch batch;

  const PreparationStep({Key? key, required this.batch}) : super(key: key);

  @override
  State<PreparationStep> createState() => _PreparationStepState();
}

class _PreparationStepState extends State<PreparationStep> {
  List<String> materials = [
    "2 Soeppannen",
    "Vergiet",
    "Filterzak",
    "Thermometer",
    "Keukenweegschaal",
    "Precisieweegschaal",
    "Refractometer",
    "Ijsblokjes",
    "Schoonmaakmiddel",
    "Emmer + kraantje + waterslot"
  ];
  late List<bool> materialsCB;
  // List<String> materialsLater = ["Bierflessen", "Bierdoppen", ""];
  Map<Product, num> ingredients = {};
  Map<Product, bool> ingredientsCB = {};

  @override
  void initState() {
    Batch batch = widget.batch;
    List<SpecToProducts> stps = [
      ...batch.mashing.malts,
      ...batch.cooking.steps.expand((step) => step.products)
    ];
    if (batch.bottleSugar != null) stps.add(batch.bottleSugar!);
    if (batch.yeast != null) stps.add(batch.yeast!);
    for (SpecToProducts stp in stps) {
      if (stp.products != null) {
        for (ProductInstance pi in stp.products!) {
          ingredients[pi.product] = pi.amount;
        }
      }
    }

    materialsCB = List.generate(materials.length, (index) => false);
    for (var p in ingredients.keys) {
      ingredientsCB[p] = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
        title: "Voorbereiding",
        bottomButton: ElevatedButton(
          child: const Text("Volgende"),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => MaltingStep(
                        batch: widget.batch,
                      )),
            );
          },
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 20, runSpacing: 10, children: [
            Steps(steps: materials, title: "Materialen"),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Ingrediënten",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(spacing: 20, runSpacing: 10, children: [
                  ...ProductCategory.values
                      .where((cat) => ingredients.keys
                          .where((p) => p.runtimeType == cat.productType)
                          .isNotEmpty)
                      .map((cat) => Steps(
                            steps: ingredients.keys
                                .map((p) =>
                                    "${Util.prettify(ingredients[p])}g ${p.name}")
                                .toList(),
                            title: cat.name,
                            subgroup: true,
                          ))
                ]),
              ],
            ),
          ]),
          const SizedBox(height: 20),
          const Steps(steps: ["Maak het materiaal goed schoon"])
        ]));
  }
}
