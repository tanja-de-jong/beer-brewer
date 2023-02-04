import 'package:beer_brewer/batch/batches_overview.dart';
import 'package:flutter/material.dart';

import '../data/store.dart';
import '../models/batch.dart';

class BrewStep extends StatefulWidget {
  final Batch batch;
  final List<Map<String, dynamic>> contentList;
  final int step;
  final BatchPhase phase;

  const BrewStep({Key? key, required this.batch, this.step = 0, required this.contentList, this.phase = BatchPhase.brewing}) : super(key: key);

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
                      170,
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
                if (widget.phase == BatchPhase.brewing) {
                  Store.brewBatch(widget.batch, Store.date, Store.startSG ?? 0);
                  Store.startSG = null;
                } else if (widget.phase == BatchPhase.lagering) {
                  Store.lagerBatch(widget.batch, Store.date);
                } else {
                  Store.bottleBatch(widget.batch, Store.date);
                }
                // Notify.instantNotify();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) =>
                        const BatchesOverview()),
                        (Route<dynamic> route) => false);
              }, child: const Text("Rond af")),
            ])));
  }
}
