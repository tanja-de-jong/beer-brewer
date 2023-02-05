import 'package:beer_brewer/screen.dart';
import 'package:beer_brewer/steps/steps.dart';
import 'package:flutter/material.dart';

import '../models/batch.dart';
import '../models/recipe.dart';
import 'cooking.dart';

class FilterStep extends StatefulWidget {
  final Batch batch;

  const FilterStep({Key? key, required this.batch})
      : super(key: key);

  @override
  State<FilterStep> createState() => _FilterStepState();
}

class _FilterStepState extends State<FilterStep> {
  late Recipe recipe;
  late Batch batch;
  List<String> steps = [
    "Til de filterzak uit de pan en laat deze erboven uitlekken. Gebruik eventueel een vergiet.",
    "Vul indien nodig de hoeveelheid water aan."
  ];

  @override
  void initState() {
    batch = widget.batch;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(title: "Filteren", bottomButton: ElevatedButton(
      child: const Text("Volgende"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => CookingStep(
                batch: widget.batch,
              )),
        );
      },
    ), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Steps(steps: steps),
    ]));
  }
}
