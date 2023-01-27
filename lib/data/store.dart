import 'package:beer_brewer/data/database_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Store {
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

  static Map<ProductCategory, Type> productMappings = {
    ProductCategory.malt: Malt,
    ProductCategory.hop: Hop,
    ProductCategory.yeast: Yeast,
    ProductCategory.sugar: Sugar,
  };

  static Map<ProductCategory, List<Product>> products = {
    ProductCategory.malt: maltProducts,
    ProductCategory.hop: hopProducts,
    ProductCategory.yeast: yeastProducts,
    ProductCategory.sugar: sugarProducts,
    ProductCategory.other: otherProducts,
  };
  static List<Malt> maltProducts = [
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
        1000,
        3.5,
        3.5),
    Malt("2", "Carapils/Carafoam", "Carapils", "Weyermann", {}, 0, 3.9, 3.9),
    Malt("3", "Caramunich II", "Caramunich", "Weyermann", {}, 100, 124, 124),
  ];
  static List<Hop> hopProducts = [
    Hop("1", "Goldings", "", {}, 1000, 0, HopType.korrels)
  ];
  static List<Hop> sugarProducts = [];
  static List<Yeast> yeastProducts = [];
  static List<Sugar> otherProducts = [];

  static List<Recipe> recipes = [];
  static List<Batch> batches = [];

  static Future<Recipe> saveRecipe(
      String? id,
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
        remarks);
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

  static Future<Batch> saveBatch(String? id, Recipe recipe,
      Map<ProductSpec, List<SpecToProduct>> ingredients) async {
    Batch batch = await DatabaseController.saveBatch(id, recipe, ingredients);
    if (id == null) {
      Store.batches.add(batch);
    } else {
      int idx = Store.batches.indexWhere((b) => id == b.id);
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

  static Future<Product> saveProduct(String? id, ProductCategory category, String name, String? brand, Map<String, Map<String, dynamic>>? stores, double? amount, Map? extraProps) async {
    Product product = await DatabaseController.saveProduct(id, category, name, brand, stores, amount, extraProps);

    if (id == null) {
      Store.products[category]!.add(product);
    } else {
      int idx = products[category]!.indexWhere((b) => id == b.id);
      Store.products[category]![idx] = product;
    }
    print("In saveProduct: ${products[ProductCategory.hop]!.length}");
    return product;
  }

  static Future<void> loadProducts() async {
    List<Product> allProducts = await DatabaseController.getProducts();
    products[ProductCategory.malt] = allProducts.whereType<Malt>().toList();
    products[ProductCategory.hop] = allProducts.whereType<Hop>().toList();
    products[ProductCategory.yeast] = allProducts.whereType<Yeast>().toList();
    products[ProductCategory.sugar] = allProducts.whereType<Sugar>().toList();
    products[ProductCategory.other] = allProducts.where((product) => !(product is Malt || product is Hop || product is Yeast || product is Sugar)).toList();
  }
}

class Batch {
  String id;
  String name;
  Recipe recipe;
  double amount;
  Map<ProductSpec, List<SpecToProduct>> ingredients;
  DateTime? brewDate;
  DateTime? bottleDate;
  Map<DateTime, double> sgMeasurements;

  Batch(this.id, this.name, this.recipe, this.amount, this.ingredients,
      this.brewDate, this.bottleDate, this.sgMeasurements);

  static Batch create(String id, Map data) {
    List ingredientsData = data["ingredients"]!;
    Set<ProductSpec> specs = ingredientsData
        .map((mapping) => ProductSpec.create(mapping["spec"]))
        .toSet();
    Map<ProductSpec, List<SpecToProduct>> ingredients = {};

    for (ProductSpec spec in specs) {
      Iterable relevantMappings = ingredientsData
          .where((ingredient) => ingredient["spec"]!["name"] == spec.name);
      List<SpecToProduct> relevantProducts = relevantMappings
          .expand((mapping) => mapping["products"]!)
          .map((data) => SpecToProduct.create(spec, data))
          .toList();
      ingredients.putIfAbsent(spec, () => relevantProducts);
    }

    Map<DateTime, double> sgMeasurements = {};
    if (data.containsKey("sgMeasurements")) {
      List sgData = data["sgMeasurements"];
      for (Map measurement in sgData) {
        sgMeasurements.putIfAbsent(
            (measurement["date"] as Timestamp).toDate(), () => measurement["SG"]);
      }
    }

    return Batch(
        id,
        data["name"],
        Store.recipes
            .firstWhere((recipe) => recipe.id == data["recipe"]!["id"]!),
        data["amount"],
        ingredients,
        data["brewDate"]?.toDate(),
        data["bottleData"]?.toDate(),
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
        YeastSpec.create(data["yeast"]),
        data["yeastTempMin"],
        data["yeastTempMax"],
        BottleSugarSpec.create(data["bottleSugar"]),
        data["remarks"]);
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
    return amount == null ? "-" : ("${amount}g");
  }

  String getProductString() {
    return "${amount ?? "- "}g ${name ?? "-"}";
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
    return {"name": name, "amount": amount, "category": describeEnum(category)};
  }
}

class MaltSpec extends ProductSpec {
  double? ebcMin;
  double? ebcMax;

  MaltSpec(super.name, this.ebcMin, this.ebcMax, super.amount,
      {category: ProductSpecCategory.malt});

  @override
  static MaltSpec create(Map data) {
    return MaltSpec(
        data["name"], data["ebcMin"], data["ebcMax"], data["amount"]);
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
      "category": "malt"
    };
  }
}

class HopSpec extends ProductSpec {
  double alphaAcid;

  HopSpec(super.name, this.alphaAcid, super.amount,
      {category: ProductSpecCategory.hop});

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
    return {...super.toMap(), "alphaAcid": alphaAcid, "category": "hop"};
  }
}

class SugarSpec extends ProductSpec {
  SugarSpec(super.name, super.amount,
      {category: ProductSpecCategory.cookingSugar});
}

class CookingSugarSpec extends SugarSpec {
  CookingSugarSpec(super.name, super.amount,
      {category: ProductSpecCategory.cookingSugar});

  @override
  static CookingSugarSpec create(Map data) {
    return CookingSugarSpec(data["name"], data["amount"]);
  }

  @override
  Map toMap() {
    return {...super.toMap(), "category": "cookingSugar"};
  }
}

class BottleSugarSpec extends SugarSpec {
  BottleSugarSpec(super.name, super.amount,
      {category: ProductSpecCategory.bottleSugar});

  @override
  String getProductString() {
    return "${amount == null ? "- " : amount.toString()}g/L ${name == null ? "-" : name!}";
  }

  @override
  static BottleSugarSpec create(Map data) {
    return BottleSugarSpec(data["name"], data["amount"]);
  }

  @override
  Map toMap() {
    return {...super.toMap(), "category": "bottleSugar"};
  }
}

class YeastSpec extends ProductSpec {
  YeastSpec(super.name, super.amount, {category: ProductSpecCategory.yeast});

  @override
  static YeastSpec create(Map data) {
    return YeastSpec(data["name"], data["amount"]);
  }

  @override
  Map toMap() {
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
        return Product(id, data["name"], data["brand"] ?? "-", data["stores"], data["amount"]);
    }
  }
}

class Malt extends Product {
  String type;
  double? ebcMin;
  double? ebcMax;

  Malt(super.id, super.name, this.type, super.brand, super.stores, super.amount,
      this.ebcMin, this.ebcMax);

  @override
  static Malt create(String id, Map data) {
    return Malt(id, data["name"], data["type"], data["brand"] ?? "-", data["stores"], data["amount"], data["ebcMin"], data["ebcMax"]);
  }

  String ebcToString() {
    if (ebcMin == null && ebcMax == null) return "-";
    if (ebcMin == ebcMax || ebcMin == null) return "$ebcMin EBC";
    if (ebcMax == null) return "$ebcMax EBC";
    return "${ebcMin} - ${ebcMax} EBC";
  }
}

class Hop extends Product {
  double? alphaAcid;
  HopType type;

  Hop(super.id, super.name, super.brand, super.stores, super.amount,
      this.alphaAcid, this.type);

  static Hop create(String id, Map data) {
    return Hop(id, data["name"], data["brand"] ?? "-", data["stores"], data["amount"], data["alphaAcid"], data["type"] == "korrels" ? HopType.korrels : HopType.bellen);
  }
}

class Sugar extends Product {
  Sugar(super.id, super.name, super.brand, super.stores, super.amount);

  static Sugar create(String id, Map data) {
    return Sugar(id, data["name"], data["brand"] ?? "-", data["stores"], data["amount"]);
  }
}

class Yeast extends Product {
  Yeast(super.id, super.name, super.brand, super.stores, super.amount);

  static Yeast create(String id, Map data) {
    return Yeast(id, data["name"], data["brand"] ?? "-", data["stores"], data["amount"]);
  }
}

class Mashing {
  List<MaltSpec> malts;
  List<MashStep> steps;
  double water;

  Mashing(this.malts, this.steps, this.water);

  static Mashing create(Map data) {
    List<MaltSpec> maltsData = (data["malts"] as List)
        .map((m) => MaltSpec(m["name"], m["ebcMin"], m["ebcMax"], m["amount"]))
        .toList();
    List<MashStep> mashSchedule = (data["steps"] as List)
        .map((s) => MashStep(s["temp"], s["time"]))
        .toList();
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
    Iterable<CookingStep> matchingSteps =
        steps.where((step) => step.time == time);
    if (matchingSteps.isEmpty) {
      steps.add(CookingStep(time, products));
    } else {
      matchingSteps.first.products.addAll(products);
    }
  }

  static Cooking create(Map data) {
    return Cooking((data["steps"] as List)
        .map((step) => CookingStep(
            step["time"],
            (step["products"] as List)
                .map((p) => ProductSpec.create(p))
                .toList()))
        .toList());
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

  static SpecToProduct create(ProductSpec spec, Map data) {
    return SpecToProduct(
        spec, data["product"], data["amount"], data["explanation"]);
  }

  Map toMap() {
    return {
      "product": product.id,
      "amount": amount,
      "explanation": explanation
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
