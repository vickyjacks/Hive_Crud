import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('myHiveBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Hive Database'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  final _myHiveBox = Hive.box('myHiveBox');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    final data = _myHiveBox.keys.map((key) {
      final item = _myHiveBox.get(key);
      return {
        'key': key,
        "name": item['name'],
        "quantity": item['quantity'],
      };
    }).toList();
    setState(() {
      _items = data.reversed.toList();
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _myHiveBox.add(newItem);
    _refreshItems();
    print("data is  ++++++ ${_myHiveBox.length.toString()}");
  }

  Future<void> _updateItem(int itemkey, Map<String, dynamic> item) async {
    await _myHiveBox.put(itemkey, item);
    _refreshItems();
    print("data is  update ++++++ ${_myHiveBox.length.toString()}");
  }

  Future<void>_deleteItem(int itemkey)async{
    await _myHiveBox.delete(itemkey);
    _refreshItems();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An item has been deleted')));
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final exitingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _nameController.text = exitingItem['name'];
      _quantityController.text = exitingItem['quantity'];
    }
    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        builder: (_) => SingleChildScrollView(
          child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    top: 15,
                    left: 15,
                    right: 15),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(hintText: 'Name'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: 'Quantity'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (itemKey == null) {
                              _createItem({
                                'name': _nameController.text,
                                'quantity': _quantityController.text
                              });
                            }

                            if (itemKey != null) {
                              _updateItem(itemKey, {
                                'name': _nameController.text.trim(),
                                'quantity': _quantityController.text.trim()
                              });
                            }
                            _nameController.text = '';
                            _quantityController.text = '';
                            Navigator.pop(context);
                          },
                          child:(itemKey==null)? Text('Create New'):Text('Update')),
                      SizedBox(
                        height: 15,
                      )
                    ],
                  ),
                ),
              ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final _currentItem = _items[index];
            return Card(
              color: Colors.orange.shade200,
              margin: EdgeInsets.all(10),
              elevation: 3,
              child: ListTile(
                title: Text(_currentItem['name']),
                subtitle: Text(_currentItem['quantity'].toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          _showForm(context, _currentItem['key']);
                        },
                        icon: Icon(Icons.edit)),
                    IconButton(onPressed: () {
                      _deleteItem(_currentItem['key']);
                    }, icon: Icon(Icons.delete)),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm(context, null);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
