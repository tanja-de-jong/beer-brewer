import 'package:beer_brewer/data/database_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../util.dart';

class Store {
  static double? startSG; // TODO: necessary for FermentationStep => refactor

  static List<String> maltTypes = [
    "Pils",
    "Pale",
    "Vienna",
    "Münchener",
    "Amber",
    "Carapils",
    "Carahell",
    "Caramünich",
    "Caracrystal",
    "Biscuit",
    "Chocolade",
    "Zwart",
    "Tarwe"
  ];
  static List<String> hopTypes = [
    "Admiral",
    "Ahtanum",
    "Amarillo",
    "Apollo",
    "Brewer’s Gold",
    "Bullion",
    "Cascade",
    "Centennial",
    "Challenger",
    "Chinook",
    "Citra",
    "Cluster",
    "Columbus",
    "Crystal",
    "Eroica",
    "First Gold",
    "Fuggles",
    "Galaxy",
    "Galena",
    "Glacier",
    "Goldings",
    "Greenburg",
    "Hallertau / Hallertauer Mittelfrüh",
    "Herald",
    "Hersbrucker",
    "Horizon",
    "Liberty",
    "Lublin",
    "Magnum",
    "Millennium",
    "Mount Hood",
    "Nelson Sauvin",
    "Newport",
    "Northdown",
    "Northern Brewer",
    "Nugget",
    "Pacific Gem",
    "Palisade",
    "Perle",
    "Pilot",
    "Pioneer",
    "Polnischer Lublin",
    "Pride of Ringwood",
    "Progress",
    "Saaz",
    "Santiam",
    "Saphir",
    "Satus",
    "Select",
    "Simcoe",
    "Spalt",
    "Sterling",
    "Strisselspalt",
    "Styrian Goldings",
    "Summit",
    "Tardif de Bourgogne",
    "Target",
    "Tettnang",
    "Tomahawk",
    "Tradition",
    "Ultra",
    "Vanguard",
    "Warrior",
    "Willamette",
    "Zeus",
  ];

  static Map<Type, List> products = {
    Malt: maltProducts,
    Hop: hopProducts,
    Yeast: yeastProducts,
    Sugar: sugarProducts,
    Product: otherProducts,
  };
  static List<Malt> maltProducts = [];
  static List<Hop> hopProducts = [];
  static List<Sugar> sugarProducts = [];
  static List<Yeast> yeastProducts = [];
  static List<Sugar> otherProducts = [];

  static List<Recipe> recipes = [];
  static List<Batch> batches = [];

  static Future<Recipe> saveRecipe(Recipe recipe) async {
    String id = await DatabaseController.saveRecipe(recipe);
    if (recipe.id == null) {
      recipe.id == id;
      Store.recipes.add(recipe);
    } else {
      int idx = Store.recipes.indexWhere((r) => recipe.id == r.id);
      Store.recipes[idx] = recipe;
    }
    return recipe;
  }

  static Future<void> removeRecipe(Recipe recipe) async {
    await DatabaseController.removeRecipe(recipe);
    recipes.remove(recipe);
  }

  static Future<void> loadRecipes() async {
    recipes = await DatabaseController.getRecipes();
  }

  // TODO
  static Future<Batch> saveBatch(Batch batch) async {
    String newId = await DatabaseController.saveBatch(batch);
    if (batch.id == null) {
      batch.id = newId;
      Store.batches.add(batch);
    } else {
      int idx = Store.batches.indexWhere((b) => batch.id == b.id);
      Store.batches[idx] = batch;
    }

    return batch;
  }

  static Future<Batch> brewBatch(Batch batch, double startSG) async {
    Batch brewedBatch = await DatabaseController.brewBatch(batch, startSG);

    int idx = Store.batches.indexWhere((b) => brewedBatch.id == b.id);
    Store.batches[idx] = brewedBatch;

    return brewedBatch;
  }

  static Future<void> loadBatches() async {
    batches = await DatabaseController.getBatches();
  }

  static Future<Product> saveProduct(
      String? id,
      ProductCategory category,
      String name,
      String? brand,
      Map<String, Map<String, dynamic>>? stores,
      double? amount,
      Map? extraProps) async {
    Product product = await DatabaseController.saveProduct(
        id, category, name, brand, stores, amount, extraProps);

    if (id == null) {
      Store.products[category.productType]!.add(product);
    } else {
      int idx = products[category.productType]!.indexWhere((b) => id == b.id);
      Store.products[category.productType]![idx] = product;
    }
    return product;
  }

  static Future<void> loadProducts() async {
    List<Product> allProducts = await DatabaseController.getProducts();
    products[Malt] = allProducts.whereType<Malt>().toList();
    products[Hop] = allProducts.whereType<Hop>().toList();
    products[Yeast] = allProducts.whereType<Yeast>().toList();
    products[Sugar] = allProducts.whereType<Sugar>().toList();
    products[Product] = allProducts
        .where((product) => !(product is Malt ||
            product is Hop ||
            product is Yeast ||
            product is Sugar))
        .toList();
  }

  static Future<Product> updateAmountForProduct(
      Product product, double amount) async {
    return DatabaseController.updateAmountForProduct(product, amount);
  }

  static Future<void> removeProduct(Product product) async {
    await DatabaseController.removeProduct(product);
    products[product.runtimeType]!.remove(product);
  }
}

class Batch {
  String? id;
  String name;
  String recipeId;
  double amount;
  String? style;
  double? expStartSG;
  double? expFinalSG;
  double? color;
  double? bitter;
  Mashing mashing;
  double? rinsingWater;
  Cooking cooking;
  List<SpecToProducts> yeast;
  double? fermTempMin;
  double? fermTempMax;
  List<SpecToProducts> bottleSugar;
  String? remarks;
  DateTime? brewDate;
  DateTime? lagerDate;
  DateTime? bottleDate;
  Map<DateTime, double> sgMeasurements;

  Batch(
      this.id,
      this.name,
      this.recipeId,
      this.amount,
      this.style,
      this.expStartSG,
      this.expFinalSG,
      this.color,
      this.bitter,
      this.mashing,
      this.rinsingWater,
      this.cooking,
      this.yeast,
      this.fermTempMin,
      this.fermTempMax,
      this.bottleSugar,
      this.remarks,
      this.brewDate,
      this.lagerDate,
      this.bottleDate,
      this.sgMeasurements);

  static Batch create(String id, Map data) {
    Map<DateTime, double> sgMeasurements = {};
    if (data.containsKey("sgMeasurements")) {
      List sgData = data["sgMeasurements"];
      for (var sg in sgData) {
        sgMeasurements.putIfAbsent(sg["date"].toDate(), () => sg["SG"]);
      }
    }

    List<SpecToProducts> yeast = data["yeast"]
            ?.map((y) => SpecToProducts.create(y))
            .toList()
            .cast<SpecToProducts>() ??
        [];
    List<SpecToProducts> bottleSugar = data["bottleSugar"]
            ?.map((b) => SpecToProducts.create(b))
            .toList()
            .cast<SpecToProducts>() ??
        [];

    return Batch(
        id,
        data["name"],
        data["recipeId"],
        data["amount"],
        data["style"],
        data["expStartSG"],
        data["expFinalSG"],
        data["color"],
        data["bitter"],
        Mashing.create(data["mashing"]),
        data["rinsingWater"],
        Cooking.create(data["cooking"]),
        yeast,
        data["yeastTempMin"],
        data["yeastTempMax"],
        bottleSugar,
        data["remarks"],
        data["brewDate"]?.toDate(),
        data["lagerDate"]?.toDate(),
        data["bottleDate"]?.toDate(),
        sgMeasurements);
  }

  double? getStartSG() {
    if (sgMeasurements.isEmpty) return null;
    List<DateTime> dates = sgMeasurements.keys.toList();
    dates.sort();
    return sgMeasurements[dates.first]!;
  }

  double? getEndSG() {
    if (sgMeasurements.length < 2) return null;
    List<DateTime> dates = sgMeasurements.keys.toList();
    dates.sort();
    return sgMeasurements[dates.last]!;
  }

  bool isReadyToBottle() {
    if (brewDate == null) return false;
    DateTime today = DateTime.now();
    return isSGSteady() || today.difference(brewDate!).inDays >= 21;
  }

  bool isSGSteady() {
    if (sgMeasurements.length < 2) return false;
    List<DateTime> dates = sgMeasurements.keys.toList();
    dates.sort();
    DateTime latestDate = dates.last;
    double lastValue = sgMeasurements[latestDate]!;
    DateTime prevDate = dates
        .where((date) =>
            !date.isAfter(dates.last.subtract(const Duration(days: 2))))
        .last;
    double diff = (sgMeasurements[prevDate]! - lastValue).abs();
    return diff < 1;
  }

  // For Brewing in a Bag
  String getBiabWater() {
    return Util.prettify(amount * 1.5) ?? "-";
  }

  Widget getMashingSchedule() {
    return mashing.steps.isEmpty
        ? Text("Geen moutschema beschikbaar.",
            style: TextStyle(fontStyle: FontStyle.italic))
        : Table(
            border: TableBorder.all(),
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
                TableRow(children: [
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Temperatuur",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text("Tijd",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
                ...mashing.steps.map(
                  (s) => TableRow(children: [
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text("${s.temp}ºC")),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text("${s.time} min"))
                  ]),
                )
              ]);
  }

  Widget getCookingSchedule() {
    return cooking.steps.isEmpty
        ? Text("Geen kookschema beschikbaar.",
            style: TextStyle(fontStyle: FontStyle.italic))
        : Table(
            border: TableBorder.all(),
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
                TableRow(children: [
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Tijd",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text("Soort",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text("Gewicht",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text("α",
                          style: TextStyle(fontWeight: FontWeight.bold)))
                ]),
                ...cooking.steps.expand((cs) => cs.products.expand(
                      (stp) => stp.products!.map((pi) {
                        Product p = pi.product;
                        return TableRow(children: [
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text("${cs.time} min")),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(p.name)),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text("${p.amount}g")),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(p is Hop ? "${p.alphaAcid}%" : ""))
                        ]);
                      }),
                    ))
              ]);
  }

  String getFermentationTemperature() {
    return "${fermTempMin ?? "?"} - ${fermTempMax ?? "?"}°C";
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "recipeId": recipeId,
      "amount": amount,
      "style": style,
      "expStartSG": expStartSG,
      "expFinalSG": expFinalSG,
      "color": color,
      "bitter": bitter,
      "mashing": mashing.toMap(),
      "rinsingWater": rinsingWater,
      "cooking": cooking.toMap(),
      "yeast": yeast.map((e) => e.toMap()).toList(),
      "yeastTempMin": fermTempMin,
      "yeastTempMax": fermTempMax,
      "bottleSugar": bottleSugar.map((e) => e.toMap()).toList(),
      "remarks": remarks,
      "brewDate": brewDate,
      "lagerDate": lagerDate,
      "bottleDate": bottleDate,
      "sgMeasurements": sgMeasurements
    };
  }
}

class Recipe {
  String? id;
  String name;
  String? style;
  String? source;
  double? amount;
  double? expStartSG;
  double? expFinalSG;
  double? efficiency;
  double? color;
  double? bitter;
  late Mashing mashing;
  double? rinsingWater;
  late Cooking cooking;
  YeastSpec? yeast;
  double? fermTempMin;
  double? fermTempMax;
  BottleSugarSpec? bottleSugar;
  String? remarks;

  Recipe(
      this.id,
      this.name,
      this.style,
      this.source,
      this.amount,
      this.expStartSG,
      this.expFinalSG,
      this.efficiency,
      this.color,
      this.bitter,
      mashing,
      this.rinsingWater,
      cooking,
      this.yeast,
      this.fermTempMin,
      this.fermTempMax,
      this.bottleSugar,
      this.remarks) {
    this.mashing = mashing ?? Mashing([], [], 0);
    this.cooking = cooking ?? Cooking([]);
  }

  static Recipe create(String id, Map data) {
    return Recipe(
      id,
      data["name"],
      data["style"],
      data["source"],
      data["amount"],
      data["expStartSG"],
      data["expFinalSG"],
      data["efficiency"],
      data["color"],
      data["bitter"],
      Mashing.create(data["mashing"]),
      data["rinsingWater"],
      Cooking.create(data["cooking"]),
      data["yeast"] == null ? null : YeastSpec.create(data["yeast"]),
      data["yeastTempMin"],
      data["yeastTempMax"],
      data["bottleSugar"] == null
          ? null
          : BottleSugarSpec.create(data["bottleSugar"]),
      data["remarks"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "style": style,
      "source": source,
      "amount": amount,
      "expStartSG": expStartSG,
      "expFinalSG": expFinalSG,
      "efficiency": efficiency,
      "color": color,
      "bitter": bitter,
      "mashing": mashing.toMap(),
      "rinsingWater": rinsingWater,
      "cooking": cooking.toMap(),
      "yeast": yeast?.toMap(),
      "yeastTempMin": fermTempMin,
      "yeastTempMax": fermTempMax,
      "bottleSugar": bottleSugar?.toMap(),
      "remarks": remarks
    };
  }
}

class ProductSpec {
  String? name;
  double? amount;
  ProductSpecCategory category;

  ProductSpec(this.name, this.amount,
      {this.category = ProductSpecCategory.other});

  String getName() {
    return name ?? "";
  }

  String getAmount() {
    return amount == null ? "-" : ("${Util.prettify(amount)}g");
  }

  String getProductString() {
    return "${getAmount()} ${name ?? "-"}";
  }

  static ProductSpec create(Map data) {
    String cat = data["category"];
    switch (cat) {
      case "malt":
        return MaltSpec.create(data);
      case "hop":
        return HopSpec.create(data);
      case "cookingSugar":
        return CookingSugarSpec.create(data);
      case "bottleSugar":
        return BottleSugarSpec.create(data);
      case "yeast":
        return YeastSpec.create(data);
      default:
        return ProductSpec(data["name"], data["amount"],
            category: ProductSpecCategory.other);
    }
  }

  Map<String, dynamic> toMap() {
    return {"name": name, "amount": amount, "category": describeEnum(category)};
  }
}

class MaltSpec extends ProductSpec {
  double? ebcMin;
  double? ebcMax;

  MaltSpec(name, this.ebcMin, this.ebcMax, amount) : super(name, amount) {
    category = ProductSpecCategory.malt;
  }

  @override
  static MaltSpec create(Map data) {
    return MaltSpec(
        data["name"], data["ebcMin"], data["ebcMax"], data["amount"]);
  }

  String ebcToString({double? min, double? max}) {
    double? minEbc = min ?? ebcMin;
    double? maxEbc = max ?? ebcMax;
    if (minEbc == null && ebcMax == null) return "-";
    if (minEbc == maxEbc || minEbc == null) return "$maxEbc EBC";
    if (maxEbc == null) return "$minEbc EBC";
    return "$minEbc - $maxEbc EBC";
  }

  static String getEbcToString(double? min, double? max) {
    if (min == null && max == null) return "-";
    if (min == max || min == null) return "$max EBC";
    if (max == null) return "$min EBC";
    return "$min - $max EBC";
  }

  @override
  String getProductString() {
    return "${getAmount()} ${name} (${ebcToString()})";
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      "ebcMin": ebcMin,
      "ebcMax": ebcMax,
      "category": "malt"
    };
  }
}

class HopSpec extends ProductSpec {
  double? alphaAcid;

  HopSpec(name, this.alphaAcid, amount) : super(name, amount) {
    category = ProductSpecCategory.hop;
  }

  @override
  static HopSpec create(Map data) {
    return HopSpec(data["name"], data["alphaAcid"], data["amount"]);
  }

  @override
  String getProductString() {
    return "${getAmount()} ${name} (${alphaAcid}%)";
  }

  @override
  Map<String, dynamic> toMap() {
    return {...super.toMap(), "alphaAcid": alphaAcid, "category": "hop"};
  }
}

class SugarSpec extends ProductSpec {
  SugarSpec(super.name, super.amount);
}

class CookingSugarSpec extends SugarSpec {
  CookingSugarSpec(name, amount) : super(name, amount) {
    category = ProductSpecCategory.cookingSugar;
  }

  @override
  static CookingSugarSpec create(Map data) {
    return CookingSugarSpec(data["name"], data["amount"]);
  }

  @override
  Map<String, dynamic> toMap() {
    return {...super.toMap(), "category": "cookingSugar"};
  }
}

class BottleSugarSpec extends SugarSpec {
  BottleSugarSpec(name, amount) : super(name, amount) {
    category = ProductSpecCategory.bottleSugar;
  }

  @override
  String getProductString() {
    return "${amount == null ? "- " : getAmount()}/L ${name == null ? "-" : name!}";
  }

  @override
  static BottleSugarSpec create(Map data) {
    return BottleSugarSpec(data["name"], data["amount"]);
  }

  @override
  Map<String, dynamic> toMap() {
    return {...super.toMap(), "category": "bottleSugar"};
  }
}

class YeastSpec extends ProductSpec {
  YeastSpec(name, amount) : super(name, amount) {
    category = ProductSpecCategory.yeast;
  }

  @override
  static YeastSpec create(Map data) {
    return YeastSpec(data["name"], data["amount"]);
  }

  @override
  Map<String, dynamic> toMap() {
    return {...super.toMap(), "category": "yeast"};
  }
}

class Product {
  String id;
  String name;
  String brand;
  Map<String, Map<String, dynamic>>?
      stores; // Brouwstore => {url: www.brouwstore.com, variants: {1kg: www.bla.com}}
  double? amount;

  Product(this.id, this.name, this.brand, this.stores, this.amount);

  String getStoreUrl(String storeName) {
    return stores?[storeName]?["url"] ?? "-";
  }

  String storesToString() {
    return stores?.keys.join(", ") ?? "-";
  }

  String amountToString() {
    return amount == null
        ? "-"
        : amount! >= 1000
            ? "${(amount! / 1000).toString().replaceAll(RegExp(r'\.'), ",")} kg"
            : "${amount} g";
  }

  static Product create(String id, Map data) {
    String cat = data["category"];
    switch (cat) {
      case "malt":
        return Malt.create(id, data);
      case "hop":
        return Hop.create(id, data);
      case "sugar":
        return Sugar.create(id, data);
      case "yeast":
        return Yeast.create(id, data);
      default:
        return Product(id, data["name"], data["brand"] ?? "-", data["stores"],
            data["amount"]);
    }
  }
}

class Malt extends Product {
  String? type;
  double? ebcMin;
  double? ebcMax;

  Malt(super.id, super.name, this.type, super.brand, super.stores, super.amount,
      this.ebcMin, this.ebcMax);

  @override
  static Malt create(String id, Map data) {
    return Malt(id, data["name"], data["type"], data["brand"] ?? "-",
        data["stores"], data["amount"], data["ebcMin"], data["ebcMax"]);
  }

  String ebcToString() {
    if (ebcMin == null && ebcMax == null) return "-";
    if (ebcMin == ebcMax || ebcMin == null) return "$ebcMin EBC";
    if (ebcMax == null) return "$ebcMax EBC";
    return "${ebcMin} - ${ebcMax} EBC";
  }

  String typeToString() {
    return type ?? "-";
  }
}

class Hop extends Product {
  double? alphaAcid;
  HopType type;

  Hop(super.id, super.name, super.brand, super.stores, super.amount,
      this.alphaAcid, this.type);

  static Hop create(String id, Map data) {
    return Hop(
        id,
        data["name"],
        data["brand"] ?? "-",
        data["stores"],
        data["amount"],
        data["alphaAcid"],
        data["type"] == "korrels" ? HopType.korrels : HopType.bellen);
  }
}

class Sugar extends Product {
  Sugar(super.id, super.name, super.brand, super.stores, super.amount);

  static Sugar create(String id, Map data) {
    return Sugar(
        id, data["name"], data["brand"] ?? "-", data["stores"], data["amount"]);
  }
}

class Yeast extends Product {
  Yeast(super.id, super.name, super.brand, super.stores, super.amount);

  static Yeast create(String id, Map data) {
    return Yeast(
        id, data["name"], data["brand"] ?? "-", data["stores"], data["amount"]);
  }
}

class Mashing {
  List<SpecToProducts> malts;
  List<MashStep> steps;
  double? water;

  Mashing(this.malts, this.steps, this.water);

  static Mashing create(Map<String, dynamic> data) {
    List<SpecToProducts> maltsData =
        (data["malts"] as List).map((m) => SpecToProducts.create(m)).toList();
    List<MashStep> mashSchedule = (data["steps"] as List)
        .map((s) => MashStep(s["temp"], s["time"]))
        .toList();
    return Mashing(maltsData, mashSchedule, data["water"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "malts": malts.map((e) => e.toMap()),
      "steps": steps.map((e) => e.toMap()),
      "water": water
    };
  }
}

class MashStep {
  int temp;
  int time;

  MashStep(this.temp, this.time);

  Map<String, dynamic> toMap() {
    return {"temp": temp, "time": time};
  }
}

class Cooking {
  List<CookingScheduleStep> steps;

  Cooking(this.steps);

  Set getCookingIngredients() {
    return steps.expand((step) => step.products).toSet();
  }

  void addStep(double? time, List<SpecToProducts> products) {
    Iterable<CookingScheduleStep> matchingSteps =
        steps.where((step) => step.time == time);
    if (matchingSteps.isEmpty) {
      steps.add(CookingScheduleStep(time, products));
    } else {
      matchingSteps.first.products.addAll(products);
    }
  }

  static Cooking create(List data) {
    return Cooking(data
        .map((step) => CookingScheduleStep(
            step["time"],
            (step["products"] as List)
                .map((e) => SpecToProducts.create(e))
                .toList()))
        .toList());
  }

  List<Map<String, dynamic>> toMap() {
    return steps.map((e) => e.toMap()).toList();
  }
}

class CookingScheduleStep {
  List<SpecToProducts> products = [];
  double? time;

  CookingScheduleStep(this.time, List<SpecToProducts> products) {
    this.products.addAll(products);
  }

  Map<String, dynamic> toMap() {
    return {"time": time, "products": products.map((e) => e.toMap()).toList()};
  }
}

class SpecToProducts {
  ProductSpec spec;
  List<ProductInstance>? products;
  String? explanation;

  SpecToProducts(this.spec, this.products, this.explanation);

  static SpecToProducts create(Map data) {
    ProductSpec spec = ProductSpec.create(data["spec"]);
    List productsData = data["products"];
    var result = SpecToProducts(
        spec,
        productsData.map((data) => ProductInstance.create(spec.category, data)).toList(),
        data["explanation"]);
    return result;
  }

  Map<String, dynamic> toMap() {
    return {
      "spec": spec.toMap(),
      "products": products?.map((ProductInstance p) => p.toMap()).toList(),
      "explanation": explanation
    };
  }
}

class ProductInstance {
  Product product;
  double amount;

  ProductInstance(this.product, this.amount);

  static ProductInstance create(ProductSpecCategory category, Map data) {
    Product product = Store.products[category.product]!.firstWhere((p) => p.id == data["productId"]);
    return ProductInstance(
        product,
        data["amount"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "productId": product.id,
      "amount": amount
    };
  }
}

enum HopType { korrels, bellen }

enum ProductSpecCategory { malt, hop, cookingSugar, bottleSugar, yeast, other }

extension ProductSpecName on ProductSpecCategory {
  String get name {
    switch (this) {
      case ProductSpecCategory.malt:
        return "Mout";
      case ProductSpecCategory.hop:
        return "Hop";
      case ProductSpecCategory.cookingSugar:
        return "Kooksuiker";
      case ProductSpecCategory.bottleSugar:
        return "Bottelsuiker";
      case ProductSpecCategory.yeast:
        return "Gist";
      default:
        return "Overige";
    }
  }
}

extension ProductSpecCategoryToProduct on ProductSpecCategory {
  Type get product {
    switch (this) {
      case ProductSpecCategory.malt:
        return Malt;
      case ProductSpecCategory.hop:
        return Hop;
      case ProductSpecCategory.cookingSugar:
        return Sugar;
      case ProductSpecCategory.bottleSugar:
        return Sugar;
      case ProductSpecCategory.yeast:
        return Yeast;
      default:
        return Product;
    }
  }
}

enum ProductCategory { malt, hop, sugar, yeast, other }

extension ProductName on ProductCategory {
  String get name {
    switch (this) {
      case ProductCategory.malt:
        return "Mout";
      case ProductCategory.hop:
        return "Hop";
      case ProductCategory.yeast:
        return "Gist";
      case ProductCategory.sugar:
        return "Suiker";
      default:
        return "Overige";
    }
  }
}

extension ProductCategoryToProduct on ProductCategory {
  Type get productType {
    switch (this) {
      case ProductCategory.malt:
        return Malt;
      case ProductCategory.hop:
        return Hop;
      case ProductCategory.sugar:
        return Sugar;
      case ProductCategory.yeast:
        return Yeast;
      default:
        return Product;
    }
  }
}
