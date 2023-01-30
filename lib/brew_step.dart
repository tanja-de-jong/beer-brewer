import 'package:beer_brewer/main.dart';
import 'package:flutter/material.dart';

import 'data/store.dart';
import 'models/batch.dart';

class BrewStep extends StatefulWidget {
  final Batch batch;
  final List<Map<String, dynamic>> contentList;
  final int step;

  const BrewStep({Key? key, required this.batch, this.step = 0, required this.contentList}) : super(key: key);

  @override
  State<BrewStep> createState() => _BrewStepState();
}

class _BrewStepState extends State<BrewStep> {

  late String title;
  late Widget description;

  @override
  void initState() {
    title = widget.contentList[widget.step]["title"] ?? "";
    description = widget.contentList[widget.step]["description"] ?? Container();

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
                    child: description,
                  )),
              const Divider(),
              const SizedBox(height: 15),
              widget.step < widget.contentList.length - 1 ? ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => BrewStep(batch: widget.batch, contentList: widget.contentList, step: widget.step+1,)),
                  );
                },
                child: const Text("Volgende"),
              ) : ElevatedButton(onPressed: () {
                Store.brewBatch(widget.batch, Store.startSG ?? 0);
                Store.startSG = null;
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) =>
                        const MyHomePage(title: "Bier Brouwen")),
                        (Route<dynamic> route) => false);
              }, child: const Text("Rond af")),
            ])));
  }
}
