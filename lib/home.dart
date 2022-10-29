import 'package:flutter/material.dart';

import 'dbHelper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  var dataList = [];

  String? validateTextField(String? value) {
    if (value!.isEmpty) return "Field is Required";

    return null;
  }

  _refreshData() async {
    final data = await DatabaseHelper.getItems();

    setState(() {
      dataList = data;
    });
  }

  Future<void> addItem() async {
    await DatabaseHelper.createItem(
        _titleController.text, _descriptionController.text);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        "Successfully Added Data!",
      ),
      backgroundColor: Colors.green,
    ));

    _refreshData();
  }

  Future<void> updateItem(int id) async {
    await DatabaseHelper.updateItem(
        id, _titleController.text, _descriptionController.text);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        "Successfully Updated Data!",
      ),
      backgroundColor: Colors.green,
    ));

    _refreshData();
  }

  void deleteItem(int id) async {
    await DatabaseHelper.deleteItem(id);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        "Successfully Deleted Data!",
      ),
      backgroundColor: Colors.red,
    ));

    _refreshData();
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo"),
      ),
      body: dataList.isEmpty
          ? const Center(
              child: Text("No Data Availble"),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: dataList.length,
              itemBuilder: (ctx, index) {
                return Card(
                  color: index % 2 == 0 ? Colors.white70 : Colors.green[200],
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    title: Text(dataList[index]['title']),
                    subtitle: Text(dataList[index]['description']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () => showForm(dataList[index]['id']),
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.green,
                            )),
                        IconButton(
                            onPressed: () => deleteItem(dataList[index]['id']),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void showForm(int? id) async {
    if (id != null) {
      final existtingData =
          dataList.firstWhere((element) => element['id'] == id);

      _titleController.text = existtingData['title'];
      _descriptionController.text = existtingData['description'];
    } else {
      _titleController.text = "";
      _descriptionController.text = "";
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isDismissible: false,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                right: 15,
                left: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        validator: validateTextField,
                        controller: _titleController,
                        decoration: const InputDecoration(hintText: "Title"),
                      ),
                      TextFormField(
                        validator: validateTextField,
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(hintText: "Description"),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Exit")),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  if (id != null) {
                                    await updateItem(id);
                                  } else {
                                    await addItem();
                                  }
                                  Navigator.pop(context);
                                }
                                setState(() {
                                  _titleController.text = "";
                                  _descriptionController.text = "";
                                });
                              },
                              child: Text(id == null ? "Save" : "Update")),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ));
  }
}
