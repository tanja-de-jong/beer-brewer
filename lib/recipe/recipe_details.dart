import 'package:beer_brewer/main.dart';
import 'package:beer_brewer/recipe/recipe_creator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../batch/batch_creator.dart';
import '../data/store.dart';
import '../models/product_spec.dart';
import '../models/recipe.dart';

class RecipeDetails extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetails({Key? key, required this.recipe}) : super(key: key);

  @override
  State<RecipeDetails> createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {
  late Recipe recipe;

  Row _getRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        value
      ],
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<void>(
      builder: (BuildContext context) =>
          const MyHomePage(title: 'Bier Brouwen', selectedPage: 1,),
    ), (route) => false);
    return true;
  }

  @override
  void initState() {
    recipe = widget.recipe;
    super.initState();
  }

  Widget leftColumn() {
    return SizedBox(width: 350, child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Algemeen",
            style: TextStyle(
                fontWeight:
                FontWeight
                    .bold),
          ),
          const SizedBox(height: 10),
          _getRow("Naam", Text(recipe.name)),
          _getRow("Stijl", Text(recipe.style ?? "-")),
          _getRow("Bron",
              Text(recipe.source ?? "-")),
          _getRow("Hoeveelheid",
              Text("${recipe.amount} liter")),
          const SizedBox(height: 10),
          _getRow(
              "Start",
              Text(recipe.expStartSG == null
                  ? "-"
                  : ("${recipe.expStartSG!.toStringAsFixed(3)} SG"))),
          _getRow(
              "Eind",
              Text(recipe.expFinalSG == null
                  ? "-"
                  : ("${recipe.expFinalSG!.toStringAsFixed(3)} SG"))),
          _getRow(
              "Alcohol",
              Text(recipe.expFinalSG == null ||
                  recipe.expStartSG == null
                  ? "-"
                  : ("${((recipe.expStartSG! - recipe.expFinalSG!) * 131.25).toStringAsFixed(1)}%"))),
          _getRow(
              "Rendement",
              Text((recipe.efficiency == null
                  ? "-"
                  : "${recipe.efficiency! * 100}%"))),
          const SizedBox(height: 10),
          _getRow(
              "Kleur",
              Text(recipe.color == null
                  ? "-"
                  : "${recipe.color} EBC")),
          _getRow(
              "Bitterheid",
              Text(recipe.bitter == null
                  ? "-"
                  : "${recipe.bitter} EBU")),
          const SizedBox(height: 10),
          _getRow(
              "Maischwater",
              Text(
                  "${recipe.mashing.water} liter")),
          _getRow(
              "Spoelwater",
              Text(
                  "${recipe.rinsingWater} liter")),
          _getRow(
              "Bottelsuiker",
              Text(
                  recipe.bottleSugar?.getProductString() ?? "-")),
          const SizedBox(height: 20),
          Row(
              mainAxisAlignment:
              MainAxisAlignment.start,
              children: [
                Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    mainAxisAlignment:
                    MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Maischen",
                        style: TextStyle(
                            fontWeight:
                            FontWeight
                                .bold),
                      ),
                      const SizedBox(height: 10),
                      recipe.mashing.malts.isEmpty ? const Text("Geen mouten beschikbaar.", style: TextStyle(fontStyle: FontStyle.italic)) : Table(
                        border:
                        TableBorder.all(),
                        defaultColumnWidth:
                        const IntrinsicColumnWidth(),
                        children: [
                          const TableRow(
                              children: [
                                Padding(
                                    padding:
                                    EdgeInsets.all(10),
                                    child: Text("Type", style: TextStyle(fontWeight: FontWeight.bold),)),
                                Padding(
                                    padding: EdgeInsets.all(
                                        10),
                                    child: Text("EBC", style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(
                                    padding:
                                    EdgeInsets.all(10),
                                    child: Text("Gewicht", style: TextStyle(fontWeight: FontWeight.bold)))
                              ]),
                        ...recipe.mashing.malts
                            .map(
                              (m) => TableRow(
                              children: [
                                Padding(
                                    padding:
                                    const EdgeInsets.all(10),
                                    child: Text(m.spec.getName())),
                                Padding(
                                    padding: const EdgeInsets.all(
                                        10),
                                    child: Text((m.spec as MaltSpec).ebcToString())),
                                Padding(
                                    padding:
                                    const EdgeInsets.all(10),
                                    child: Text("${m.spec.amount} g"))
                              ]),
                        )],
                      ),
                      const SizedBox(
                          height: 10),
                      recipe.mashing.steps.isEmpty ? const Text("Geen moutschema beschikbaar.", style: TextStyle(fontStyle: FontStyle.italic)) : Table(
                        border:
                        TableBorder.all(),
                        defaultColumnWidth:
                        const IntrinsicColumnWidth(),
                        children: [
                          const TableRow(
                              children: [
                                Padding(
                                    padding:
                                    EdgeInsets.all(10),
                                    child: Text("Temperatuur", style: TextStyle(fontWeight: FontWeight.bold),)),
                                Padding(
                                    padding: EdgeInsets.all(
                                        10),
                                    child: Text("Tijd", style: TextStyle(fontWeight: FontWeight.bold))),
                              ]),
                        ...recipe.mashing.steps
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
                      )
                    ])
              ]),
        ]));
  }

  Widget rightColumn() {
    return SizedBox(width: 350, child: Column(children: [
      Row(
          mainAxisAlignment:
          MainAxisAlignment.start,
          children: [
            Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                mainAxisAlignment:
                MainAxisAlignment.start,
                children: [
                  const Text(
                    "Koken",
                    style: TextStyle(
                        fontWeight:
                        FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  recipe.cooking.steps.isEmpty ? const Text("Geen kookschema beschikbaar.", style: TextStyle(fontStyle: FontStyle.italic)) : Table(
                    border: TableBorder.all(),
                    defaultColumnWidth:
                    const IntrinsicColumnWidth(),
                    children: [
                      const TableRow(
                          children: [
                            Padding(
                                padding:
                                EdgeInsets.all(10),
                                child: Text("Tijd", style: TextStyle(fontWeight: FontWeight.bold),)),
                            Padding(
                                padding: EdgeInsets.all(
                                    10),
                                child: Text("Soort", style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(
                                padding:
                                EdgeInsets.all(10),
                                child: Text("Gewicht", style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(
                                padding:
                                EdgeInsets.all(10),
                                child: Text("α", style: TextStyle(fontWeight: FontWeight.bold)))
                          ]),
                    ...recipe.cooking.steps
                        .expand(
                          (cs) => cs
                          .products
                          .map((p) =>
                          TableRow(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(cs.products.indexOf(p) == 0 ? "${cs.time} min" : "")),
                                Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(p.spec.getName())),
                                Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text("${p.spec.amount} g")),
                                Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(p.spec is HopSpec ? "${(p.spec as HopSpec).alphaAcid}%" : ""))
                              ])),
                    )]
                  ),
                ])
          ]),
      const SizedBox(height: 20),
      Row(
          mainAxisAlignment:
          MainAxisAlignment.start,
          children: [
            Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                mainAxisAlignment:
                MainAxisAlignment.start,
                children: [
                  const Text(
                    "Vergisten",
                    style: TextStyle(
                        fontWeight:
                        FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  recipe.yeast?.name == null && recipe.yeast?.amount == null ? const Text("Geen gist beschikbaar.", style: TextStyle(fontStyle: FontStyle.italic)) : Table(
                      border: TableBorder.all(),
                      defaultColumnWidth:
                      const IntrinsicColumnWidth(),
                      children: [
                        const TableRow(
                            children: [
                              Padding(
                                  padding:
                                  EdgeInsets.all(10),
                                  child: Text("Gist", style: TextStyle(fontWeight: FontWeight.bold),)),
                              Padding(
                                  padding: EdgeInsets.all(
                                      10),
                                  child: Text("Gewicht", style: TextStyle(fontWeight: FontWeight.bold))),
                              Padding(
                                  padding:
                                  EdgeInsets.all(10),
                                  child: Text("Temperatuur", style: TextStyle(fontWeight: FontWeight.bold))),
                            ]),
                        if (recipe.yeast != null) TableRow(children: [
                          Padding(
                              padding:
                              const EdgeInsets
                                  .all(10),
                              child: Text(
                                  recipe.yeast!.getName())),
                          Padding(
                              padding:
                              const EdgeInsets
                                  .all(10),
                              child: Text(
                                  recipe.yeast!.getAmount())),
                          Padding(
                              padding:
                              const EdgeInsets
                                  .all(10),
                              child: Text(
                                  "${recipe.fermTempMin} - ${recipe.fermTempMax}ºC")),
                        ]),
                      ]),
                ])
          ]),
      const SizedBox(height: 20),
      Row(
          mainAxisAlignment:
          MainAxisAlignment.start,
          children: [
            Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                mainAxisAlignment:
                MainAxisAlignment.start,
                children: [
                  const Text(
                    "Opmerkingen",
                    style: TextStyle(
                        fontWeight:
                        FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(width: 300, child: Text(recipe.remarks ?? "-")),
                ])
          ]),
      const SizedBox(height: 20),
      Row(
            mainAxisAlignment:
            MainAxisAlignment.start,
            children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          "Batches",
          style: TextStyle(
              fontWeight:
              FontWeight.bold)),
        const SizedBox(height: 10),
        Table(border:
        TableBorder.all(),
          defaultColumnWidth:
          const IntrinsicColumnWidth(),
          children: [
            const TableRow(
                children: [
                  Padding(
                      padding:
                      EdgeInsets.all(10),
                      child: Text("Datum", style: TextStyle(fontWeight: FontWeight.bold),)),
                  Padding(
                      padding: EdgeInsets.all(
                          10),
                      child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
          ...(Store.batches.where((b) => b.recipeId == recipe.id).toList()..sort((a, b) => a.brewDate == null ? 0 : b.brewDate == null ? 1 : a.brewDate!.isBefore(b.brewDate!) ? 0 : 1)).map((b) => TableRow(
              children: [
                Padding(
                    padding:
                    const EdgeInsets.all(10),
                    child: Text(b.brewDate == null ? "-" : DateFormat("dd-MM-yyyy").format(b.brewDate!))),
                Padding(
                    padding: const EdgeInsets.all(
                        10),
                    child: Text(b.brewDate == null ? "Concept" : b.bottleDate == null ? "Vergisten" : DateTime.now().difference(b.bottleDate!).inDays > 21 ? "Klaar" : "Gebotteld (${DateTime.now().difference(b.bottleDate!).inDays} dagen)")),
              ]),)],)
      ],)])
    ]));
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: const Text("Recept"),
      actions: [
        Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => RecipeCreator(recipe: recipe)),
                );
              },
              child: const Icon(
                Icons.edit,
                size: 26.0,
              ),
            )),
      ],
    );

    return WillPopScope(onWillPop: _onWillPop, child: Scaffold(
        appBar: appBar,
        body: Column(children: [
          SizedBox(
              height: MediaQuery.of(context).size.height -
                  appBar.preferredSize.height -
                  80,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                        child: SingleChildScrollView(
                            child: Container(
                                padding: const EdgeInsets.all(10),
                                // width: 400,
                                child: MediaQuery.of(context).size.width >= 700 ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    leftColumn(),
                                    const SizedBox(width: 50),
                                    rightColumn()
                                  ],
                                ) : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    leftColumn(),
                                    const SizedBox(height: 20),
                                    rightColumn()
                                  ],
                                ))))
                  ])),
          const Divider(),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              if (recipe.amount != null && recipe.amount! > 0) {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      BatchCreator(recipe: recipe),
                ),
              );
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(
                    content:
                    Text("Recept heeft nog geen hoeveelheid.")));
              }
            },
            child: const Text("Brouwplan maken"),
          ),
        ])));
  }
}
