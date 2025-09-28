import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finflow/services/budget_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:restart_app/restart_app.dart';

class CustomDrawer extends StatefulWidget {
  final String userName;
  final String? mail;
  final double budget;

  const CustomDrawer(
      {Key? key,
      required this.userName,
      required this.mail,
      required this.budget})
      : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late String username;
  late double budget;

  @override
  void initState() {
    super.initState();
    username = widget.userName;
    budget = widget.budget;
  }

  Future<void> _changeUsername() async {
    TextEditingController usernameController = TextEditingController();

    bool? result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change Username"),
        content: TextField(
          controller: usernameController,
          decoration: InputDecoration(hintText: "Enter new username"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              String newName = usernameController.text.trim();
              if (newName.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .update({'name': newName});
                setState(() {
                  username = newName;
                });
              }
              Navigator.pop(context, true);
            },
            child: Text("Change"),
          ),
        ],
      ),
    );
  }

  Future<void> _changeBudget() async {
    TextEditingController budgetController = TextEditingController();
    await BudgetNotificationService.resetThresholdFlags();

    bool? result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change Budget"),
        content: TextField(
          controller: budgetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "Enter new budget"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              String newBudget = budgetController.text.trim();
              if (newBudget.isNotEmpty && double.tryParse(newBudget) != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .update({'budget': double.parse(newBudget)});
                setState(() {
                  budget = double.parse(newBudget);
                });
              }
              Restart.restartApp();
              Navigator.pop(context, true);
            },
            child: Text("Change"),
          ),
        ],
      ),
    );
  }

  Future<void> _startFresh() async {
    bool? confirmReset = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Start Fresh"),
        content:
            Text("This will delete all your income and expenses. Continue?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Yes")),
        ],
      ),
    );

    if (confirmReset == true) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('income')
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      _changeBudget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade800, Colors.grey.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(username,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              accountEmail: widget.mail == null
                  ? Text('')
                  : Text(widget.mail!, style: TextStyle(color: Colors.white70)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white30,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.userEdit, color: Colors.white70),
              title: Text("Change Username",
                  style: TextStyle(color: Colors.white)),
              onTap: _changeUsername,
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.wallet, color: Colors.white70),
              title:
                  Text("Change Budget", style: TextStyle(color: Colors.white)),
              subtitle: Text("Current Budget: \$${budget.toStringAsFixed(2)}",
                  style: TextStyle(color: Colors.white54)),
              onTap: _changeBudget,
            ),
            ListTile(
              leading: Icon(Icons.refresh, color: Colors.orangeAccent),
              title: Text("Start Fresh",
                  style: TextStyle(color: Colors.orangeAccent)),
              onTap: _startFresh,
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: Text("Logout", style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                bool confirmLogout = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Confirm Logout"),
                        content: Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text("Cancel")),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text("Logout")),
                        ],
                      ),
                    ) ??
                    false;
                if (confirmLogout) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
