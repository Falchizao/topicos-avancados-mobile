import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/attractions.dart';

class FiltroPage extends StatefulWidget {
  static const routeName = '/filtro';
  static const chaveCampoOrdenacao = 'campoOrdenacao';
  static const chaveUsarOrdemDecrescente = 'usarOrdemDecrescente';
  static const keyFilterContent = 'contentFilter';
  static const keyFilterDate = 'dateFilter';

  @override
  _FiltroPageState createState() => _FiltroPageState();
}

class _FiltroPageState extends State<FiltroPage> {
  late final SharedPreferences _prefs;
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  bool _usarOrdemDecrescente = false;
  bool _alterouValores = false;
  final _formatter = DateFormat('dd/MM/yyyy HH:mm:ss');

  @override
  void initState() {
    super.initState();
    _carregarSharedPreferences();
  }

  void _carregarSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onVoltarClick,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Filter'),
        ),
        body: _criarBody(),
      ),
    );
  }

  Widget _criarBody() => ListView(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, top: 10),
            child: Text('Campo para ordenação'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Title starts with',
              ),
              controller: _titleController,
              onChanged: _onFiltroDescricaoChanged,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Content starts with',
              ),
              controller: _contentController,
              onChanged: _onFiltroDescricaoChanged,
            ),
          ),
        ],
      );

  void _showDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(Duration(days: 365 * 5)),
            lastDate: DateTime.now().add(Duration(days: 365 * 5)))
        .then((value) {
      if (value != null) {
        setState(() {
          _alterouValores = true;
          _dateController.text = _formatter.format(value);
        });
      }
    });
  }

  void _onUsarOrdemDecrescenteChanged(bool? valor) {
    _prefs.setBool(FiltroPage.chaveUsarOrdemDecrescente, valor!);
    _alterouValores = true;
    setState(() {
      _usarOrdemDecrescente = valor;
    });
  }

  void _onFiltroDescricaoChanged(String? valor) {
    _prefs.setString(FiltroPage.keyFilterContent, valor ?? '');
    _alterouValores = true;
  }

  Future<bool> _onVoltarClick() async {
    var att = [
      _alterouValores,
      _contentController.text,
      _dateController.text,
      _titleController.text
    ];

    if (_contentController.text != "") {
      _prefs.setString('content', _contentController.text);
    } else {
      try {
        _prefs.remove('content');
      } catch (e) {}
    }

    if (_titleController.text != "") {
      _prefs.setString('title', _titleController.text);
    } else {
      try {
        _prefs.remove('title');
      } catch (e) {}
    }

    Navigator.of(context).pop(att);
    return true;
  }
}
