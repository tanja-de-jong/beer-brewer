import 'package:beer_brewer/data/database_controller.dart';
import 'package:flutter/foundation.dart';

class Store {
  static List<String> maltTypes = ["Pils", "Pale", "Vienna", "Münchener", "Amber", "Carapils", "Carahell", "Caramünich", "Caracrystal", "Biscuit", "Chocolade", "Zwart", "Tarwe"];
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

  static List<Malt> maltProducs = [
    Malt(
      "1",
        "Chateau Pilsen 2-Row",
        "Pilsmout",
        "Castle Malting",
        {
          "Brouwland": {
            "1kg":
                "https://brouwland.com/nl/mout/20089-castle-malting-pilsmout-3-35-ebc-1-kg.html"
          },
          "Brouwstore": {
            "1kg":
                "https://brouwland.com/nl/mout/20089-castle-malting-pilsmout-3-35-ebc-1-kg.html"
          }
        },
        3.5,
        3.5),
    Malt("2", "Carapils/Carafoam", "Carapils", "Weyermann", {}, 3.9, 3.9),
    Malt("3", "Caramunich II", "Caramunich", "Weyermann", {}, 124, 124),
  ];
  static List<Hop> hopProducts = [];
  static List<Hop> sugarProducts = [];
  static List<Hop> yeastProducts = [];
  static List<Hop> otherProducts = [];

  static List<Recipe> recipes = [
    Recipe(
      "abc",
        "Tripel uit 'Bierbrouwen voor Dummies'",
        "Tripel",
        "Bierbrouwen voor Dummies",
        5,
        1.080,
        1.014,
        0.75,
        14,
        37,
        Mashing([
          MaltSpec("Pilsmout", 3, 3, 1100),
          MaltSpec("Carapils", 6, 6, 85),
          MaltSpec("Munichmout", 15, 15, 10),
          MaltSpec("Caramunich", 110, 130, 25)
        ], [
          MashStep(64, 49),
          MashStep(73, 73),
          MashStep(76, 5)
        ], 9),
        8,
        Cooking([
          CookingStep(75, [
            HopSpec("Aurora", 9, 2),
            HopSpec("East Kent Golding", 5.5, 2),
            HopSpec("Crystal", 5.5, 1.5),
            HopSpec("Summit", 16, 1.5)
          ]),
          CookingStep(10, [
            HopSpec("Aurora", 9, 1.5),
            HopSpec("East Kent Golding", 5.5, 2),
            HopSpec("Crystal", 5.5, 1.5),
            CookingSugarSpec("Kristalsuiker", 375)
          ]),
        ]),
        YeastSpec("Fermentis S-33", 4),
        19,
        21,
        BottleSugarSpec("Kristalsuiker", 7.5),
        ""),
    Recipe("def",
        "Dubbel uit 'Bierbrouwen voor Dummies'",
        "Dubbel",
        "Bierbrouwen voor Dummies",
        5,
        1080,
        1014,
        0.75,
        14,
        37,
        Mashing([
          MaltSpec("Pilsmout", 3, 3, 1100),
          MaltSpec("Carapils", 6, 6, 85),
          MaltSpec("Munichmout", 15, 15, 10),
          MaltSpec("Caramunich", 110, 130, 25)
        ], [
          MashStep(64, 49),
          MashStep(73, 73),
          MashStep(76, 5)
        ], 9),
        8,
        Cooking([
          CookingStep(75, [
            HopSpec("Aurora", 9, 2),
            HopSpec("East Kent Golding", 5.5, 2),
            HopSpec("Crystal", 5.5, 1.5),
            HopSpec("Summit", 16, 1.5)
          ]),
          CookingStep(10, [
            HopSpec("Aurora", 9, 1.5),
            HopSpec("East Kent Golding", 5.5, 2),
            HopSpec("Crystal", 5.5, 1.5),
            SugarSpec("Kristalsuiker", 375)
          ]),
        ]),
        YeastSpec("TBD", 4),
        19,
        21,
        SugarSpec("Kristalsuiker", 7.5),
        ""),
  ];
  static List<Batch> batches = [
    Batch(
        "Dubbel",
        "abc",
        "Dubbel",
        DateTime.now().subtract(Duration(days: 20)),
        null,
        {DateTime.now(): 1070}),
  ];

  static Future<Recipe> saveRecipe(String? id,
      String name,
      String style,
      String? source,
      double amount,
      double? expStartSG,
      double? expFinalSG,
      double? efficiency,
      double? color,
      double? bitter,
      double mashWater,
      double rinsingWater,
      List<MaltSpec> malts,
      List<MashStep> mashSchedule,
      Map<double?, List<HopSpec>> hops,
      String? yeastName,
      double? yeastAmount,
      String? cookingSugarName,
      double? cookingSugarAmount,
      double? cookingSugarTime,
      String? bottleSugarName,
      double? bottleSugarAmount,
      Map<double?, List<ProductSpec>> otherIngredients,
      double? yeastTempMin,
      double? yeastTempMax,
      String? remarks) async {
    Recipe recipe = await DatabaseController.saveRecipe(
      id,
      name,
      style,
      source,
      amount,
      expStartSG,
      expFinalSG,
      efficiency,
      color,
      bitter,
      mashWater,
      rinsingWater,
      malts,
      mashSchedule,
      hops,
      yeastName,
      yeastAmount,
      cookingSugarName,
      cookingSugarAmount,
      cookingSugarTime,
      bottleSugarName,
      bottleSugarAmount,
      otherIngredients,
      yeastTempMin,
      yeastTempMax,
      remarks
    );
    if (id == null) {
      Store.recipes.add(recipe);
    } else {
      int idx = Store.recipes.indexWhere((r) => id == r.id);
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
}

class Batch {
  String name;
  String recipeId;
  String beerType;
  DateTime brewDate;
  DateTime? bottleDate;
  Map<DateTime, double> sgMeasurements;

  Batch(this.name, this.recipeId, this.beerType, this.brewDate, this.bottleDate,
      this.sgMeasurements);

  double getStartSG() {
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
    DateTime today = DateTime.now();
    return isSGSteady() || today.difference(brewDate).inDays >= 21;
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
}

class Recipe {
  String id;
  String name;
  String style;
  String? source;
  double amount;
  double? expStartSG;
  double? expFinalSG;
  double? efficiency;
  double? color;
  double? bitter;
  Mashing mashing;
  double rinsingWater;
  Cooking cooking;
  YeastSpec yeast;
  double? yeastTempMin;
  double? yeastTempMax;
  SugarSpec bottleSugar;
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
      this.mashing,
      this.rinsingWater,
      this.cooking,
      this.yeast,
      this.yeastTempMin,
      this.yeastTempMax,
      this.bottleSugar,
      this.remarks);

  static Recipe create(String id, Map data) {
    return Recipe(id, data["name"], data["style"], data["source"], data["amount"], data["expStartSG"], data["expFinalSG"], data["efficiency"], data["color"], data["bitter"], Mashing.create(data["mashing"]), data["rinsingWater"], Cooking.create(data["cooking"]), YeastSpec.create(data["yeast"]), data["yeastTempMin"], data["yeastTempMax"], BottleSugarSpec.create(data["bottleSugar"]), data["remarks"]);
  }
}

class ProductSpec {
  String? name;
  double? amount;
  ProductCategory category;

  ProductSpec(this.name, this.amount, { this.category = ProductCategory.other });

  String getName() {
    return name ?? "";
  }

  String getAmount() {
    return amount == null ? "-" : ("${amount}g");
  }

  String getProductString() {
    return "${amount ?? "- "}g ${name ?? "-"}";
  }

  static ProductSpec create(Map data) {
    String cat = data["category"];
    switch (cat) {
      case "malt": return MaltSpec.create(data);
      case "hop": return HopSpec.create(data);
      case "cookingSugar": return CookingSugarSpec.create(data);
      case "bottleSugar": return BottleSugarSpec.create(data);
      case "yeast": return YeastSpec.create(data);
      default: return ProductSpec(data["name"], data["amount"], category: ProductCategory.other);
    }
  }

  // ProductCategory mapStringToEnum(String cat) {
  //   switch (cat) {
  //     case "malt": return ProductCategory.malt;
  //     case "hop": return ProductCategory.hop;
  //     case "cookingSugar": return ProductCategory.cookingSugar;
  //     case "bottleSugar": return ProductCategory.bottleSugar;
  //     case "yeast": return ProductCategory.yeast;
  //     default: return ProductCategory.other;
  //   }
  // }

  Map toMap() {
    return {
      "name": name,
      "amount": amount,
      "category": describeEnum(category)
    };
  }
}

class MaltSpec extends ProductSpec {
  double? ebcMin;
  double? ebcMax;

  MaltSpec(super.name, this.ebcMin, this.ebcMax, super.amount, { category: ProductCategory.malt });

  @override
  static MaltSpec create(Map data) {
    return MaltSpec(data["name"], data["ebcMin"], data["ebcMax"], data["amount"]);
  }

  String ebcToString() {
    if (ebcMin == null && ebcMax == null) return "-";
    if (ebcMin == ebcMax || ebcMin == null) return "$ebcMin EBC";
    if (ebcMax == null) return "$ebcMax EBC";
    return "${ebcMin} - ${ebcMax} EBC";
  }

  @override
  String getProductString() {
    return "${amount}g ${name} (${ebcToString()})";
  }

  @override
  Map toMap() {
    return {
      ...super.toMap(),
      "ebcMin": ebcMin,
      "ebcMax": ebcMax,
    };
  }
}

class HopSpec extends ProductSpec {
  double alphaAcid;

  HopSpec(super.name, this.alphaAcid, super.amount, { category: ProductCategory.hop });

  @override
  static HopSpec create(Map data) {
    return HopSpec(data["name"], data["alphaAcid"], data["amount"]);
  }

  @override
  String getProductString() {
    return "${amount}g ${name} (${alphaAcid}%)";
  }

  @override
  Map toMap() {
    return {
      ...super.toMap(),
      "alphaAcid": alphaAcid,
      "category": "hop"
    };
  }
}

class SugarSpec extends ProductSpec {
  SugarSpec(super.name, super.amount, { category: ProductCategory.cookingSugar });
}

class CookingSugarSpec extends SugarSpec {
  CookingSugarSpec(super.name, super.amount, { category: ProductCategory.cookingSugar });

  @override
  static CookingSugarSpec create(Map data) {
    return CookingSugarSpec(data["name"], data["amount"]);
  }

  @override
  Map toMap() {
    return {
      ...super.toMap(),
      "category": "cookingSugar"
    };
  }
}

class BottleSugarSpec extends SugarSpec {
  BottleSugarSpec(super.name, super.amount, { category: ProductCategory.bottleSugar });

  @override
  String getProductString() {
    return "${amount == null ? "- " : amount.toString()}g/L ${name == null ? "-" : name!}";
  }

  @override
  static BottleSugarSpec create(Map data) {
    return BottleSugarSpec(data["name"], data["amount"]);
  }
}

class YeastSpec extends ProductSpec {
  YeastSpec(super.name, super.amount, { category: ProductCategory.yeast });

  @override
  static YeastSpec create(Map data) {
    return YeastSpec(data["name"], data["amount"]);
  }
}

class Product {
  String id;
  String name;
  String brand;
  Map<String, Map<String, String>> stores; // Brouwstore => {1kg: www.bla.com}

  Product(this.id, this.name, this.brand, this.stores);

  String getStoreUrl() {
    Map<String, String> firstStore = stores[stores.keys.first]!;
    String firstUrl = firstStore[firstStore.keys.first]!;
    return firstUrl;
  }

  String storesToString() {
    return stores.keys.join(", ");
  }
}

class Malt extends Product {
  String type;
  double ebcMin;
  double ebcMax;

  Malt(super.id, super.name, this.type, super.brand, super.url, this.ebcMin, this.ebcMax);

  String ebcToString() {
    if (ebcMin == ebcMax) return "$ebcMin EBC";
    return "${ebcMin} - ${ebcMax} EBC";
  }
}

class Hop extends Product {
  double alphaAcid;

  Hop(super.id, super.name, super.brand, super.url, this.alphaAcid);
}

class Sugar extends Product {
  Sugar(super.id, super.name, super.brand, super.url);
}

class Yeast extends Product {
  Yeast(super.id, super.name, super.brand, super.url);
}

class Mashing {
  List<MaltSpec> malts;
  List<MashStep> steps;
  double water;

  Mashing(this.malts, this.steps, this.water);

  static Mashing create(Map data) {
    List<MaltSpec> maltsData = (data["malts"] as List).map((m) => MaltSpec(m["name"], m["ebcMin"], m["ebcMax"], m["amount"])).toList();
    List<MashStep> mashSchedule = (data["steps"] as List).map((s) => MashStep(s["temp"], s["time"])).toList();
    return Mashing(maltsData, mashSchedule, data["water"]);
  }
}

class MashStep {
  int temp;
  int time;

  MashStep(this.temp, this.time);
}

class Cooking {
  List<CookingStep> steps;

  Cooking(this.steps);

  Set getCookingIngredients() {
    return steps.expand((step) => step.products).toSet();
  }

  void addStep(double? time, List<ProductSpec> products) {
    Iterable<CookingStep> matchingSteps = steps.where((step) => step.time == time);
    if (matchingSteps.isEmpty) {
      steps.add(CookingStep(time, products));
    } else {
      matchingSteps.first.products.addAll(products);
    }
  }

  static Cooking create(Map data) {
    return Cooking((data["steps"] as List).map((step) => CookingStep(step["time"], (step["products"] as List).map((p) => ProductSpec.create(p)).toList())).toList());
  }
}

class CookingStep {
  List<ProductSpec> products = [];
  double? time;

  CookingStep(this.time, products) {
    this.products.addAll(products);
  }
}

class SpecToProduct {
  ProductSpec spec;
  Product product;
  double amount;
  String? explanation;

  SpecToProduct(this.spec, this.product, this.amount, this.explanation);
}

enum ProductCategory {
  malt,
  hop,
  cookingSugar,
  bottleSugar,
  yeast,
  other
}

extension ProductName on ProductCategory {
  String get name {
    switch (this) {
      case ProductCategory.malt:
        return "Mout";
      case ProductCategory.hop:
        return "Hop";
      case ProductCategory.cookingSugar:
        return "Kooksuiker";
      case ProductCategory.bottleSugar:
        return "Bottelsuiker";
      case ProductCategory.yeast:
        return "Gist";
      default:
        return "Overige";
    }
  }
}