import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:beer_brewer/data/database_controller.dart';

import '../models/batch.dart';
import '../models/product.dart';
import '../models/recipe.dart';
import '../notification.dart';

class Store {
  static DateTime? date;
  static num? startSG; // TODO: necessary for FermentationStep => refactor

  static List<int> notificationIds = [];

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
    Malt: [],
    Hop: [],
    Yeast: [],
    Sugar: [],
    Product: [],
  };

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
    if (batch.id != null) {
      Batch existingBatch = Store.batches.firstWhere((b) => batch.id == b.id);
      if (batch.brewDate != existingBatch.brewDate) {
        Notification.replaceNotification(
            batch,
            NotificationType.fermentationPossiblyDone,
            existingBatch
                .notifications[NotificationType.fermentationPossiblyDone]
                ?.toInt(),
            batch.brewDate);
        Notification.replaceNotification(
            batch,
            NotificationType.fermentationDone,
            existingBatch
                .notifications[NotificationType.fermentationDone]
                ?.toInt(),
            batch.brewDate);
      }
      if (batch.lagerDate != existingBatch.lagerDate) {
        Notification.replaceNotification(
            batch,
            NotificationType.lageringDone,
            existingBatch
                .notifications[NotificationType.lageringDone]
                ?.toInt(),
            batch.lagerDate);
      }
      if (batch.bottleDate != existingBatch.bottleDate) {
        Notification.replaceNotification(
            batch,
            NotificationType.bottlingDone,
            existingBatch
                .notifications[NotificationType.bottlingDone]
                ?.toInt(),
            batch.bottleDate);
      }
    }

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

  static Future<Batch> brewBatch(
      Batch batch, DateTime? date, num startSG) async {
    Notification.scheduleNotification(
        batch, NotificationType.fermentationPossiblyDone, date);
    Notification.scheduleNotification(
        batch, NotificationType.fermentationDone, date);

    Batch brewedBatch =
        await DatabaseController.brewBatch(batch, date, startSG);

    int idx = Store.batches.indexWhere((b) => brewedBatch.id == b.id);
    Store.batches[idx] = brewedBatch;

    return brewedBatch;
  }

  static Future<Batch> lagerBatch(Batch batch, DateTime? date) async {
    Notification.cancelNotification(
        batch, NotificationType.fermentationPossiblyDone);
    Notification.cancelNotification(batch, NotificationType.fermentationDone);
    Notification.scheduleNotification(
        batch, NotificationType.lageringDone, date);

    Batch lageredBatch = await DatabaseController.lagerBatch(batch, date);

    int idx = Store.batches.indexWhere((b) => lageredBatch.id == b.id);
    Store.batches[idx] = lageredBatch;

    return lageredBatch;
  }

  static Future<Batch> bottleBatch(Batch batch, DateTime? date) async {
    Notification.cancelNotification(batch, NotificationType.lageringDone);

    Notification.scheduleNotification(
        batch, NotificationType.bottlingDone, date);
    Notification.scheduleNotification(batch, NotificationType.done, date);

    Batch bottledBatch = await DatabaseController.bottleBatch(batch, date);

    int idx = Store.batches.indexWhere((b) => bottledBatch.id == b.id);
    Store.batches[idx] = bottledBatch;

    return bottledBatch;
  }

  static Future<Batch> addSGToBatch(
      Batch batch, DateTime date, num value) async {
    Batch updatedBatch =
        await DatabaseController.addSGToBatch(batch, date, value);

    int idx = Store.batches.indexWhere((b) => updatedBatch.id == b.id);
    Store.batches[idx] = updatedBatch;

    return updatedBatch;
  }

  static Future<void> removeBatch(Batch batch) async {
    await DatabaseController.removeBatch(batch);
    batches.remove(batch);
  }

  static Future<void> loadBatches() async {
    batches = await DatabaseController.getBatches();
    notificationIds =
        batches.expand((b) => b.notifications.values).toList().cast<int>();
  }

  static Future<Product> saveProduct(
      String? id,
      ProductCategory category,
      String name,
      String? brand,
      Map<String, Map<String, dynamic>>? stores,
      num? amount,
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
      Product product, num amount) async {
    return DatabaseController.updateAmountForProduct(product, amount);
  }

  static Future<void> removeProduct(Product product) async {
    await DatabaseController.removeProduct(product);
    products[product.runtimeType]!.remove(product);
  }
}
