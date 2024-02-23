import 'package:flutter/material.dart';
import '/providers/support_provider.dart';
import '/utils/color.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class CreateSupportTicketPage extends StatefulWidget {
  const CreateSupportTicketPage({Key? key}) : super(key: key);

  @override
  State<CreateSupportTicketPage> createState() =>
      _CreateSupportTicketPageState();
}

class _CreateSupportTicketPageState extends State<CreateSupportTicketPage> {
  String selectedDepartment = '';
  String selectedPriority = '';
  TextEditingController subject = TextEditingController(text: '');
  TextEditingController message = TextEditingController(text: '');
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Consumer<SupportProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () {
            primaryFocus?.unfocus();
          },
          child: Scaffold(
            backgroundColor: mainColor,
            appBar: AppBar(
                title: titleLargeText('Create A New Ticket', context,
                    useGradient: true)),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  fieldTitle('Subject'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: subject,
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(hintText: 'Subject'),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Subject is required.';
                            } else if (val.length < 5) {
                              return 'Subject should be at least 5 characters.';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  height10(),
                  fieldTitle('Department'),
                  buildDepartment(provider),
                  height10(),
                  fieldTitle('Priority'),
                  buildPriorities(provider),
                  height10(),
                  fieldTitle('Message'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: message,
                          cursorColor: Colors.white,
                          minLines: 6,
                          maxLines: null,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: 'Tell us your query',
                              contentPadding: EdgeInsets.all(8)),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Message is required.';
                            } else if (val.length <= 20) {
                              return 'Message should be at least 20 characters.';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  height50(),
                  buildSubmitButton(provider),
                  height20(),
                ],
              ),
            ),
            // bottomNavigationBar: buildSubmitButton(provider),
          ),
        );
      },
    );
  }

  Row buildDepartment(SupportProvider provider) {
    if (selectedDepartment == '' && provider.departments.isNotEmpty) {
      selectedDepartment = provider.departments.first.departmentid!;
    }
    return Row(
      children: [
        Expanded(child: FormField<String>(
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black)),
              ),
              isEmpty: selectedDepartment == '',
              child: DropdownButtonHideUnderline(
                child: provider.departments.isNotEmpty
                    ? DropdownButton<String>(
                        value: selectedDepartment == ''
                            ? provider.departments.first.departmentid
                            : selectedDepartment,
                        isDense: true,
                        hint: Text('Select type'),
                        alignment: AlignmentDirectional.bottomCenter,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDepartment = newValue!;
                            state.didChange(newValue);
                          });
                        },
                        items: <DropdownMenuItem<String>>[
                          ...provider.departments
                              .map<DropdownMenuItem<String>>((type) {
                            return DropdownMenuItem<String>(
                              value: type.departmentid,
                              child: Text(
                                type.name ?? '',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedDepartment = type.departmentid ?? '';
                                });
                              },
                            );
                          }).toList(),
                        ],
                        borderRadius: BorderRadius.circular(15),
                        iconEnabledColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        menuMaxHeight: double.maxFinite,
                        dropdownColor: bColor(),
                        focusColor: Colors.transparent,
                        elevation: 10,
                      )
                    : Container(),
              ),
            );
          },
        )),
      ],
    );
  }

  Row buildPriorities(SupportProvider provider) {
    if (selectedPriority == '' && provider.priorities.entries.isNotEmpty) {
      selectedPriority = provider.priorities.entries.first.key;
    }
    return Row(
      children: [
        Expanded(child: FormField<String>(
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black)),
              ),
              isEmpty: selectedPriority == '',
              child: DropdownButtonHideUnderline(
                child: provider.priorities.entries.isNotEmpty
                    ? DropdownButton<String>(
                        value: selectedPriority == ''
                            ? provider.priorities.entries.first.key
                            : selectedPriority,
                        isDense: true,
                        hint: Text('Select'),
                        alignment: AlignmentDirectional.bottomCenter,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPriority = newValue!;
                            state.didChange(newValue);
                          });
                        },
                        items: <DropdownMenuItem<String>>[
                          ...provider.priorities.entries
                              .toList()
                              .map<DropdownMenuItem<String>>((type) {
                            return DropdownMenuItem<String>(
                              value: type.key,
                              child: Text(
                                type.value ?? '',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedPriority = type.key;
                                });
                              },
                            );
                          }).toList(),
                        ],
                        borderRadius: BorderRadius.circular(15),
                        iconEnabledColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        menuMaxHeight: double.maxFinite,
                        dropdownColor: bColor(),
                        focusColor: Colors.transparent,
                        elevation: 10,
                      )
                    : Container(),
              ),
            );
          },
        )),
      ],
    );
  }

  Row buildSubmitButton(SupportProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    provider.newTicketSubmit(subject.text, selectedDepartment,
                        selectedPriority, message.text);
                  }
                },
                child: Text('Submit Ticket')),
          ),
        ),
      ],
    );
  }

  Widget fieldTitle(String title) {
    return Column(
      children: [
        Row(
          children: [
            bodyLargeText(title, context, color: Colors.white.withOpacity(0.8)),
          ],
        ),
        height10(),
      ],
    );
  }
}
