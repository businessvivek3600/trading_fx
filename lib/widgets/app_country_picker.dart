import 'package:flutter/material.dart';
import '/database/model/response/additional/signup_country_model.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/sizedbox_utils.dart';

class ShowAppCountryPicker extends StatefulWidget {
  const ShowAppCountryPicker({
    super.key,
    required this.callback,
  });
  final Function(SignUpCountry? country) callback;
  @override
  State<ShowAppCountryPicker> createState() => _ShowAppCountryPickerState();
}

class _ShowAppCountryPickerState extends State<ShowAppCountryPicker> {
  List<SignUpCountry> _countries = [];
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    _countries = sl.get<AuthProvider>().countriesList;
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
                      _countries = sl
                          .get<AuthProvider>()
                          .countriesList
                          .where((element) => (element.name!
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              element.phonecode!
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
                  ..._countries.map((e) => ListTile(
                        onTap: () {
                          focusNode.unfocus();
                          setState(() {});
                          widget.callback(e);
                        },
                        title: Text(e.name ?? '' + " (${e.sortname ?? ''})"),
                        trailing: Text('(+${e.phonecode ?? ' '})'),
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
