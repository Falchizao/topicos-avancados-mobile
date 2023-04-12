import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas_utfpr/dao/attraction_dao.dart';
import 'package:gerenciador_tarefas_utfpr/pages/filtro_page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/attractions.dart';
import '../widgets/conteudo_form_dialog.dart';

class ListAtractions extends StatefulWidget {
  @override
  _ListAtractionsState createState() => _ListAtractionsState();
}

class _ListAtractionsState extends State<ListAtractions> {
  static const ACAO_EDITAR = 'editar';
  static const ACTION_READ = 'readOnly';
  static const ACAO_EXCLUIR = 'excluir';

  List<Attraction> attractions = <Attraction>[];
  final dao = AttractionDao();
  int _ultimoId = 0;
  bool isloadig = false;

  @override
  void initState() {
    super.initState();
    _fetchAttractions();
  }

  void _fetchAttractions() async {
    setState(() {
      isloadig = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final campoOrdenacao = Attraction.ID;
    final usarOrdemDecrescente =
        prefs.getBool(FiltroPage.chaveUsarOrdemDecrescente) == true;
    final filtroDescricao = prefs.getString("content") ?? '';
    final filtrotitle = prefs.getString("title") ?? '';
    final attractionsfetch = await dao.listar(
      filtrocontent: filtroDescricao,
      filtrotitle: filtrotitle,
      campoOrdenacao: campoOrdenacao,
      usarOrdemDecrescente: usarOrdemDecrescente,
    );
    setState(() {
      attractions.clear();
      if (attractionsfetch.isNotEmpty) {
        attractions.addAll(attractionsfetch);
      }
    });
    setState(() {
      isloadig = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _criarAppBar(),
      body: _criarBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirForm,
        tooltip: 'Add Attraction',
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _criarAppBar() {
    return AppBar(
      title: const Text('Attraction Viewer'),
      actions: [
        IconButton(
            onPressed: () {
              _abrirPaginaFiltro();
            },
            icon: const Icon(Icons.filter_list)),
      ],
    );
  }

  Widget _criarBody() {
    if (isloadig) {
      Center(
        child: CircularProgressIndicator(),
      );
    }
    if (attractions.isEmpty) {
      return const Center(
        child: Text(
          'No attraction registered!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        final attraction = attractions[index];
        return PopupMenuButton<String>(
          child: ListTile(
            leading: Checkbox(
              value: attraction.ended,
              onChanged: (bool? checked) {
                setState(() {
                  attraction.ended = checked == true;
                });
                dao.salvar(attraction);
              },
            ),
            title: Text('${attraction.id} - ${attraction.title}'),
            subtitle: Text('${attraction.content}'
                '\nRegistered on - ${attraction.registeredDate}'),
          ),
          itemBuilder: (BuildContext context) => criarItensMenuPopup(),
          onSelected: (String valorSelecionado) {
            if (valorSelecionado == ACAO_EDITAR) {
              _abrirForm(currentAttraction: attraction, idx: index);
            } else if (valorSelecionado == ACAO_EXCLUIR) {
              _excluir(index);
            } else {
              _view(index);
            }
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemCount: attractions.length,
    );
  }

  void sortDate(String date) {
    List<Attraction> filteredAttraction = <Attraction>[];

    var datetime = DateFormat("dd/MM/yyyy HH:mm:ss").parse(date);
    for (Attraction atr in attractions) {
      var atrDate = DateFormat("dd/MM/yyyy").parse(atr.registeredDate);
      if (atrDate.isAfter(datetime)) {
        filteredAttraction.add(atr);
      }
    }
    setState(() {
      attractions = filteredAttraction;
    });
  }

  void filterTitle(String title) {
    _fetchAttractions();
  }

  void filterList(String content) {
    _fetchAttractions();
  }

  void _abrirPaginaFiltro() {
    final navigator = Navigator.of(context);
    navigator.pushNamed(FiltroPage.routeName).then((alterouValores) {
      if (alterouValores != null) {
        dynamic values = alterouValores;
        filterTitle('');
      }
    });
  }

  List<PopupMenuEntry<String>> criarItensMenuPopup() {
    return [
      PopupMenuItem<String>(
          value: ACTION_READ,
          child: Row(
            children: const [
              Icon(Icons.remove_red_eye, color: Colors.black),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('View'),
              )
            ],
          )),
      PopupMenuItem<String>(
          value: ACAO_EDITAR,
          child: Row(
            children: const [
              Icon(Icons.edit, color: Colors.black),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Edit'),
              )
            ],
          )),
      PopupMenuItem<String>(
          value: ACAO_EXCLUIR,
          child: Row(
            children: const [
              Icon(Icons.delete, color: Colors.red),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Delete'),
              )
            ],
          ))
    ];
  }

  void _view(int idx) {
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(attractions[idx].title),
            content: ConteudoFormDialog(
                key: key, actualAttraction: attractions[idx], ReadOnly: true),
          );
        });
  }

  void _abrirForm({Attraction? currentAttraction, int? idx}) {
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(currentAttraction == null
                ? 'New Attraction'
                : ' Update attraction ${currentAttraction.id}'),
            content: ConteudoFormDialog(
              key: key,
              actualAttraction: currentAttraction,
              ReadOnly: false,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (key.currentState != null &&
                      key.currentState!.dadosValidados()) {
                    setState(() {
                      final newAttraction = key.currentState!.newAttraction;
                      dao.salvar(newAttraction).then((value) {
                        if (value) {
                          _fetchAttractions();
                        }
                      });
                      _fetchAttractions();
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save'),
              )
            ],
          );
        });
  }

  void _excluir(int idx) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('Warning'),
                ),
              ],
            ),
            content: const Text('This item will be deleted'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    dao.remover(idx).then((value) {
                      if (value) {
                        _fetchAttractions();
                      }
                    });
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }
}
