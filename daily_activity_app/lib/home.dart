import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'sql_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _products = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshproducts() async {
    final data = await SQLHelper.getproduct();
    print("jdfh");
    setState(() {
      _products = data;
      _isLoading = false;
    });
    print(data);
  }

  @override
  void initState() {
    super.initState();
    _refreshproducts(); // Loading the diary when the app starts
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController =TextEditingController();
  
  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingproducts =
          _products.firstWhere((element) => element['id'] == id);
      _nameController.text = existingproducts['name'];
      _descriptionController.text = existingproducts['description'];
      _priceController.text=existingproducts['price'].toString();
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                   TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(hintText: 'Price'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new journal
                      if (id == null) {
                        await _addproduct();
                      }

                      if (id != null) {
                        await _updateproduct(id);
                      }

                      // Clear the text fields
                      _nameController.text = '';
                      _descriptionController.text = '';
                       _priceController.text = '';

                      // Close the bottom sheet
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

// Insert a new journal to the database
  Future<void> _addproduct() async {
    await SQLHelper.createproduct(
        _nameController.text, _descriptionController.text, double.parse(_priceController.text) );
    _refreshproducts();
  }

  // Update an existing journal
  Future<void> _updateproduct(int id) async {
    await SQLHelper.updateproduct(
        id, _nameController.text, _descriptionController.text,double.parse(_priceController.text));
    _refreshproducts();
  }

  // Delete an item
  void _deleteproduct(int id) async {
    await SQLHelper.deleteproduct(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshproducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kindacode.com'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) => Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                   // title: Text(_products[index]['name']),
                   // subtitle: Text(_products[index]['description']),
                   title: Column(
                    children: [
                    Text(_products[index]['name']),
                    Text(_products[index]['description']),
                    Text(_products[index]['price'].toString())

                    ],
                   ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_products[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteproduct(_products[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}