import 'package:beer_brewer/products_overview.dart';
import 'package:beer_brewer/recipe/recipes_overview.dart';
import 'package:flutter/material.dart';

import 'batch/batches_overview.dart';

class Screen extends StatefulWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? child;
  final bool loading;
  final OverviewPage page;
  final bool scroll;
  final Map<String, Widget>? tabs;
  final TabController? tabController;
  final Widget? bottomButton;

  const Screen(
      {Key? key,
      required this.title,
      this.actions,
      this.child,
      this.loading = false,
      this.page = OverviewPage.other,
      this.scroll = true,
      this.tabs,
      this.tabController,
      this.bottomButton})
      : super(key: key);

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  int? selected;

  @override
  void initState() {
    switch (widget.page) {
      case OverviewPage.batches:
        selected = 0;
        break;
      case OverviewPage.recipes:
        selected = 1;
        break;
      case OverviewPage.products:
        selected = 2;
        break;
      default:
        selected = null;
        break;
    }
    super.initState();
  }

  AppBar getAppBar() {
    if (widget.tabs == null) {
      return AppBar(
        title: Text(widget.title),
        actions: widget.actions,
      );
    } else {
      return AppBar(
        title: Text(widget.title),
        actions: widget.actions,
        bottom: widget.tabs == null
            ? null
            : TabBar(
          controller: widget.tabController,
                labelPadding: const EdgeInsets.all(0),
                tabs: widget.tabs!.keys
                    .map((e) => Tab(height: 20, text: e))
                    .toList()),
      );
    }
  }

  Widget getBody() {
    if (widget.tabs == null) {
      return widget.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              SizedBox(height: getBodyHeight(), child: getScrollableContent()),
              if (widget.bottomButton != null)
                Column(
                  children: [
                    const Divider(),
                    SizedBox(height: 50, child: widget.bottomButton!),
                  ],
                )
            ]);
    } else {
      return widget.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              SizedBox(
                  height: getBodyHeight(),
                  child: TabBarView(controller: widget.tabController, children: widget.tabs!.values.toList())),
              if (widget.bottomButton != null)
                Column(
                  children: [
                    const Divider(),
                    SizedBox(height: 50, child: widget.bottomButton!),
                  ],
                )
            ]);
    }
  }

  double getBodyHeight() {
    double bottomButtonHeight = widget.bottomButton != null ? 20 : 0;
    double tabBarHeight = widget.tabs != null ? 48 : 0;
    return MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top -
        kBottomNavigationBarHeight -
        bottomButtonHeight -
        tabBarHeight;
  }

  Widget getTabbedContent() {
    return widget.tabs == null
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: getAppBar(),
            body: getBody(),
            bottomNavigationBar:
                selected != null ? getMainBottomNavigationBar(selected!) : null,
          )
        : DefaultTabController(
            length: widget.tabs!.length,
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: getAppBar(),
                bottomNavigationBar: selected != null
                    ? getMainBottomNavigationBar(selected!)
                    : null,
                body: getBody()),
          );
  }

  Widget getScrollableContent() {
    return widget.scroll
        ? SingleChildScrollView(child: getPaddedContent())
        : getPaddedContent();
  }

  Widget getPaddedContent() {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: widget.child!)
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: getAppBar(),
      body: getBody(),
      bottomNavigationBar:
      selected != null ? getMainBottomNavigationBar(selected!) : null,
    );
  }

  BottomNavigationBar getMainBottomNavigationBar(int selected) {
    return BottomNavigationBar(
      currentIndex: selected,
      onTap: (int value) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => OverviewPage.values[value].widget!),
            (Route<dynamic> route) => false);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.sync), label: "Batches"),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: "Recepten"),
        BottomNavigationBarItem(
            icon: Icon(Icons.local_grocery_store), label: "Voorraad")
      ],
    );
  }
}

enum OverviewPage { batches, recipes, products, other }

extension ProductName on OverviewPage {
  Widget? get widget {
    switch (this) {
      case OverviewPage.batches:
        return const BatchesOverview();
      case OverviewPage.recipes:
        return const RecipesOverview();
      case OverviewPage.products:
        return const ProductsOverview();
      default:
        return null;
    }
  }
}
