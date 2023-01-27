import 'package:flutter/material.dart';

import 'batches_overview.dart';
import 'data/store.dart';

class BrewStep extends StatefulWidget {
  final Batch batch;
  final List<Map<String, String>> texts;
  final int step;

  const BrewStep({Key? key, required this.batch, this.step = 0, required this.texts}) : super(key: key);

  @override
  State<BrewStep> createState() => _BrewStepState();
}

class _BrewStepState extends State<BrewStep> {
  // List<Map<String, String>> texts = [
  //   {"title": "Voorbereiding", "description": ""},
  //   {"title": "Maischen", "description": ""},
  //   {"title": "Filteren", "description": ""},
  //   {"title": "Spoelen", "description": ""},
  //   {"title": "Koken", "description": ""},
  //   {"title": "Afkoelen", "description": ""},
  //   {"title": "Vergisten", "description": ""},
  //   {"title": "Bottelen", "description": ""},
  // ];

  late String title;
  late String description;

  @override
  void initState() {
    title = widget.texts[widget.step]["title"] ?? "";
    description = widget.texts[widget.step]["description"] ?? "";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: Text(title),
    );

    return Scaffold(
        appBar: appBar,
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height -
                      appBar.preferredSize.height -
                      100,
                  child: SingleChildScrollView(
                    child: Column(children: [
                      Text(description),
                    ]),
                  )),
              const Divider(),
              const SizedBox(height: 15),
              widget.step < widget.texts.length - 1 ? ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => BrewStep(batch: widget.batch, texts: widget.texts, step: widget.step+1,)),
                  );
                },
                child: Text("Volgende"),
              ) : ElevatedButton(onPressed: () {
                Store.brewBatch(widget.batch, 0);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) =>
                        const BatchesOverview()),
                        (Route<dynamic> route) => false);
              }, child: const Text("Rond af")),
            ])));
  }
}
