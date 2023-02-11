import 'package:beer_brewer/form/TextFieldRow.dart';
import 'package:beer_brewer/main.dart';
import 'package:beer_brewer/screen.dart';
import 'package:beer_brewer/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'authentication/authentication.dart';
import 'data/store.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool loading = true;
  Map<String, List<String>> groups = {};
  Map<String, String> groupNames = {};
  bool showAddForm = false;
  Map<String, String> emails = {};
  TextEditingController controller = TextEditingController();

  void loadData() async {
    List<String> groupIds = await Store.getGroups(Authentication.email!);
    for (String groupId in groupIds) {
      String name = await Store.getGroupName(groupId);
      List<String> members = await Store.getMembers(groupId);
      setState(() {
        groupNames[groupId] = name;
        groups[groupId] = members;
        loading = false;
      });
    }
  }

  Widget getGroupWidget(String groupId) {
    List<String> members = groups[groupId] ?? [];
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          groupNames[groupId] ?? "Groep",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        // IconButton(onPressed: () {}, icon: Icon(Icons.edit), iconSize: 15,
        //   splashRadius: 15,),
      ]),
      ...(members..sort((a, b) => a.toLowerCase() == Authentication.email!.toLowerCase() ? 0 : 1)).map((m) => Row(
        children: [
          Expanded(
              child: Text(m + (m.toLowerCase() == Authentication.email!.toLowerCase() ? "*" : ""),
              )),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: members.length <= 1 ? null : () {
              Util.showDeleteDialog(context, "gebruiker", () {
                Store.removeMember(m);
                setState(() {
                  members.remove(m);
                });
                Navigator.pop(context);
              }, deze: true);
            },
            icon: const Icon(Icons.delete),
            iconSize: 15,
            splashRadius: 15,
          )
        ],
      )),
      if (!showAddForm) OutlinedButton.icon(
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              showAddForm = true;
            });
          },
          label: const Text("Voeg toe")
      ),
      if (showAddForm)
        Container(
            decoration: BoxDecoration(border: Border.all()),
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
            child: Column(
              children: [
                TextFieldRow(label: "E-mailadres", controller: controller, onChanged: (value) {
                  setState(() {
                    emails[groupId] = value.toLowerCase();
                  });
                },),
                const SizedBox(height: 10),
                OutlinedButton(
                    onPressed: emails[groupId] == null || emails[groupId]!.isEmpty
                        ? null
                        : () {
                      setState(() {
                        Store.addMember(groupId, emails[groupId]!);
                        members.add(emails[groupId]!);

                        emails.remove(groupId);
                        controller.clear();
                        showAddForm = false;
                      });
                    },
                    child: const Text("Voeg toe")),
                const SizedBox(height: 5),
              ],
            )),
    ]);
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(title: "Instellingen", loading: loading, actions: [
      Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () {
              Authentication.signOut(context: context);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const AuthenticationPage()),
                      (Route<dynamic> route) => false);
            },
            child: const Icon(
              Icons.logout,
              size: 26.0,
            ),
          )),
    ], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:
      groups.keys.map((g) => getGroupWidget(g)).toList()
    ));
  }
}
