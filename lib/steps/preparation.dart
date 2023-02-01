import 'package:flutter/material.dart';

import '../models/spec_to_products.dart';
import '../models/batch.dart';
import '../models/product.dart';
import '../util.dart';

class PreparationStep extends StatefulWidget {
  final Batch batch;

  const PreparationStep({Key? key, required this.batch})
      : super(key: key);

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
  Map<Product, double> ingredients = {};
  Map<Product, bool> ingredientsCB = {};

  @override
  void initState() {
    Batch batch = widget.batch;
    List<SpecToProducts> stps = [...batch.mashing.malts, ...batch.cooking.steps.expand((step) => step.products)];
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Wrap(
      spacing: 20,
      runSpacing: 10,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Materialen", style: TextStyle(fontWeight: FontWeight.bold),),
          ...[for (var i = 0; i < materials.length; i++) i].map((i) => SizedBox(width: 250, child: Row(children: [Checkbox(value: materialsCB[i], onChanged: (value){
            setState(() {
              materialsCB[i] = !materialsCB[i];
            });
          }), Text(materials[i])]))),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Ingrediënten", style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(spacing: 20, runSpacing: 10, children: [
          ...ProductCategory.values.map((cat) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (ingredients.keys.where((p) => p.runtimeType == cat.productType).isNotEmpty) Text(cat.name, style: const TextStyle(
              decoration:
              TextDecoration
                  .underline,
            ),),
            ...ingredients.keys.where((p) => p.runtimeType == cat.productType).map((p) => SizedBox(width: 250, child: Row(children: [Checkbox(value: ingredientsCB[p], onChanged: (value){
              setState(() {
                ingredientsCB[p] = !(ingredientsCB[p]!);
              });
            }), Text("${Util.prettify(ingredients[p])}g ${p.name}")])))
          ],))
            ]),
      ],
    ),]),
      const SizedBox(height: 20),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text("Stappen", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("- Maak het materiaal goed schoon.")
      ])
    ]);
  }
}
