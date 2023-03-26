import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/attractions.dart';

class ConteudoFormDialog extends StatefulWidget {
  final Attraction? actualAttraction;
  final bool? ReadOnly;

  ConteudoFormDialog({Key? key, this.actualAttraction, this.ReadOnly})
      : super(key: key);

  @override
  ConteudoFormDialogState createState() => ConteudoFormDialogState();
}

class ConteudoFormDialogState extends State<ConteudoFormDialog> {
  final formKey = GlobalKey<FormState>();
  final descricaoController = TextEditingController();
  final titleController = TextEditingController();
  final createdDateController = TextEditingController();
  var readOnly = false;

  @override
  void initState() {
    super.initState();
    if (widget.actualAttraction != null) {
      descricaoController.text = widget.actualAttraction!.content;
      readOnly = widget.ReadOnly!;
      createdDateController.text = widget.actualAttraction!.registeredDate;
      titleController.text = widget.actualAttraction!.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    return !readOnly
        ? Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration:
                      const InputDecoration(labelText: 'Attraction Name'),
                  validator: (String? valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Insert a name!';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  validator: (String? valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Insert a description!';
                    }
                    return null;
                  },
                )
              ],
            ))
        : Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(titleController.text),
                Text(descricaoController.text),
                Text(createdDateController.text)
              ],
            ));
  }

  bool dadosValidados() => formKey.currentState!.validate() == true;

  Attraction get newAttraction => Attraction(
        id: widget.actualAttraction?.id ?? 0,
        content: descricaoController.text,
        title: titleController.text,
      );
}
