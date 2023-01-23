import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DropDownRow extends StatefulWidget {
  final MainAxisAlignment alignment;
  final String label;
  final List<String> items;
  final String? initialValue;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const DropDownRow({Key? key, required this.label, required this.items, this.initialValue, this.onChanged, this.controller, this.focusNode, this.alignment = MainAxisAlignment.spaceBetween}) : super(key: key);

  @override
  State<DropDownRow> createState() => _DropDownRowState();
}

class _DropDownRowState extends State<DropDownRow> {

  late GlobalKey dropDownKey;
  TextEditingController controller = TextEditingController();
  int? selectedItem;
  List<String> items = [];
  FocusNode focusNode = FocusNode();

  DropdownButtonFormField2 getDropDown(String label, List<String> items) {
    Widget searchField = TextFormField(
      focusNode: focusNode,
      controller: widget.controller ?? controller,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        hintText: 'Zoek item...',
        hintStyle: const TextStyle(fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onFieldSubmitted: (value) {
        setState(() {
          if (!items.map((item) => item.toLowerCase()).contains(value.toLowerCase())) items.add(value);
          selectedItem = items.indexOf(value);
          Navigator.pop(dropDownKey.currentContext!);
          if (widget.onChanged != null) widget.onChanged!(value);
        });
      },
    );

    return DropdownButtonFormField2<int>(
      key: dropDownKey,
        decoration: InputDecoration(
          //Add isDense true and zero Padding.
          //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
          isDense: true,
          contentPadding: EdgeInsets.only(left: 15, right: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          //Add more decoration as you want here
          //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
        ),
        isExpanded: true,
        hint: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<int>(value: items.indexOf(item), child: Text(item));
        }).toList(),
        value: selectedItem,
        onChanged: (value) {
          setState(() {
            selectedItem = value;
            if (widget.onChanged != null) widget.onChanged!(items[value!]);
          });
        },
        buttonHeight: 40,
        buttonWidth: 250,
        itemHeight: 40,
        dropdownMaxHeight: 200,
        searchController: controller,
        searchInnerWidget: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 4,
              right: 8,
              left: 8,
            ),
            child: searchField
        ),
        searchMatchFn: (item, searchValue) {
          return (items[item.value].toLowerCase().contains(searchValue.toLowerCase()));
        },
        //This to clear the search value when you close the menu
        onMenuStateChange: (isOpen) {
          if (!isOpen) {
            controller.clear();
            FocusScope.of(context).requestFocus(FocusNode());
          } else {
            focusNode.requestFocus();
          }
        }
    );
  }

  @override
  void initState() {
    items = widget.items;

    if (widget.initialValue != null) {
      String initialValue = widget.initialValue!;
      if (!items.contains(initialValue)) {
        items.add(initialValue);
      }
      items.sort();
      selectedItem = items.indexOf(initialValue);
    } else {
      items.sort();
    }

    if (widget.controller != null) controller = widget.controller!;
    if (widget.focusNode != null) focusNode = widget.focusNode!;

    dropDownKey = GlobalKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 350, child: Row(mainAxisAlignment: widget.alignment, children: [
      Text(
        "${widget.label}:",
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      Column(children: [
      SizedBox(height: 30, width: 200, child: getDropDown(widget.label, items)),
        SizedBox(height: 5),
    ])
    ],));
  }
}