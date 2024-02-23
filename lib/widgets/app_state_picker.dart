import 'package:flutter/material.dart';
import '/database/model/response/states_model.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/sizedbox_utils.dart';

class ShowAppStatePicker extends StatefulWidget {
  const ShowAppStatePicker({
    super.key,
    required this.callback,
  });
  final Function(States? state) callback;
  @override
  State<ShowAppStatePicker> createState() => _ShowAppStatePickerState();
}

class _ShowAppStatePickerState extends State<ShowAppStatePicker> {
  List<States> _states = [];
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    _states = sl.get<AuthProvider>().states;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 200),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            height20(),
            Row(
              children: <Widget>[
                Expanded(
                    child: TextFormField(
                  focusNode: focusNode,
                  style: TextStyle(color: mainColor),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: mainColor),
                    hintText: 'Search',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor),
                        borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor),
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty) {
                      _states = sl
                          .get<AuthProvider>()
                          .states
                          .where((element) => (element.name!
                              .toLowerCase()
                              .contains(val.toLowerCase())))
                          .toList();
                      setState(() {});
                    }
                  },
                ))
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  ..._states.map((e) => ListTile(
                        onTap: () {
                          focusNode.unfocus();
                          setState(() {});
                          widget.callback(e);
                        },
                        title: Text(e.name ?? ''),
                        // trailing: Text('(+${e.phonecode ?? ' '})'),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
