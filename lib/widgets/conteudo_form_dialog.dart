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
  final differentialsController = TextEditingController();
  final titleController = TextEditingController();
  final createdDateController = TextEditingController();
  var readOnly = false;

  @override
  void initState() {
    super.initState();
    if (widget.actualAttraction != null) {
      descricaoController.text = widget.actualAttraction!.content;
      readOnly = widget.ReadOnly!;
      differentialsController.text = widget.actualAttraction!.differentials;
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
                      const InputDecoration(labelText: 'Attraction Title'),
                  validator: (String? valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Insert a title!';
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
                ),
                TextFormField(
                  controller: differentialsController,
                  decoration: const InputDecoration(
                    labelText: 'Differentials',
                  ),
                  validator: (String? valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Insert the differentials!';
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
                Text('Title :'),
                Text(titleController.text),
                SizedBox(
                  height: 5,
                ),
                Text('Description :'),
                Text(descricaoController.text),
                SizedBox(
                  height: 5,
                ),
                Text('Created at :'),
                Text(createdDateController.text),
                SizedBox(
                  height: 5,
                ),
                Text('Differentials :'),
                Text(differentialsController.text)
              ],
            ));
  }

  bool dadosValidados() => formKey.currentState!.validate() == true;

  Attraction get newAttraction => Attraction(
        id: widget.actualAttraction?.id ?? null,
        content: descricaoController.text,
        differentials: differentialsController.text,
        title: titleController.text,
      );
}
