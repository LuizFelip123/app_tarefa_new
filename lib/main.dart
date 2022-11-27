import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _todoController = TextEditingController();
  List _todoList = [];
  Map<String, dynamic> _lastRemove = Map();
  int? _lastRemovePos;
  void _addTodo() {
    String text = _todoController.text;

    if (text.isNotEmpty) {
      setState(() {
        Map<String, dynamic> newTodo = Map();
        newTodo['title'] = text;
        _todoController.text = '';
        newTodo['ok'] = false;
        _todoList.add(newTodo);
        _saveFile();
      });
    }
  }
Future<Null> _refresh() async{
  await Future.delayed(Duration(seconds: 2));
  setState(() {
    _todoList.sort((A, B){
      if(A['ok'] && !B['ok'])
        return 1;

      
      if(!A['ok'] && B['ok'])
      return -1;

      return 0;
      _saveFile();
  });
  });
}
  @override
  void initState() {
    super.initState();
    _readFile().then((value) {
      setState(() {
        _todoList = json.decode(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: [
                Expanded(
                  child: RefreshIndicator( onRefresh: _refresh, child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Nova tarefa',
                      labelStyle: TextStyle(color: Colors.blueAccent),
                    ),
                    controller: _todoController,
                  ),
                ),),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
              itemCount: _todoList.length,
              itemBuilder: buildItem,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(
          _todoList[index]['title'],
        ),
        value: _todoList[index]['ok'],
        secondary: CircleAvatar(
          child: Icon(_todoList[index]['ok'] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _todoList[index]['ok'] = c;
            _saveFile();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemove = Map.from(_todoList[index]);
          _lastRemovePos = index;
          _todoList.removeAt(index);
          _saveFile();
        });
        final snack = SnackBar(
          content: Text('Tarefa: ${_lastRemove['title']} removida!'),
          action: SnackBarAction(
            label: 'Defazer',
            onPressed: () {
               setState(() {
                  if(_lastRemovePos!= null){
                     _todoList.insert(_lastRemovePos!, _lastRemove);
                    _saveFile();
                  }
               });
            },
          ),
          duration: Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).showSnackBar(snack);
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File('${directory.path}/data.json');
  }

  Future<File> _saveFile() async {
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readFile() async {
    final file = await _getFile();
    try {
      return file.readAsString();
    } catch (e) {
      return '';
    }
  }
}
