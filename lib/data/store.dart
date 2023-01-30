import 'package:beer_brewer/data/database_controller.dart';

import '../models/batch.dart';
import '../models/product.dart';
import '../models/recipe.dart';

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
    String id = DatabaseController.saveRecipe(recipe);
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

  static Future<Batch> addSGToBatch(Batch batch, DateTime date, double value) async {
    Batch updatedBatch = await DatabaseController.addSGToBatch(batch, date, value);

    int idx = Store.batches.indexWhere((b) => updatedBatch.id == b.id);
    Store.batches[idx] = updatedBatch;

    return updatedBatch;
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