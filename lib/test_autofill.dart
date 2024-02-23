import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AutofillTestPage extends StatefulWidget {
  @override
  _AutofillTestPageState createState() => _AutofillTestPageState();
}

class _AutofillTestPageState extends State<AutofillTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text("Password Autofill"),
        backgroundColor: Colors.red,
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        color: Colors.red[900],
        child: AutofillGroup(
            child: Column(
          children: [
            TextFormField(
              autofillHints: [AutofillHints.username],
              decoration: InputDecoration(hintText: "Username"),
            ),
            TextFormField(
              obscureText: true,
              autofillHints: [AutofillHints.password],
              decoration: InputDecoration(hintText: "Password"),
            ),
            ElevatedButton(
                onPressed: () {
                  //--- trigger Password Save
                  TextInput.finishAutofillContext();

                  //--- OR ----
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return Panel();
                  }));
                },
                child: Text("Log In"))
          ],
        )),
      ),
    );
  }
}

class Panel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
      ),
    );
  }
}
