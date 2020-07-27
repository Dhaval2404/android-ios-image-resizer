import 'dart:async';
import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../FilePickerListener.dart';

enum _DragState {
  dragging,
  notDragging,
}

class DropZone extends StatefulWidget {
  final FilePickerListener listener;

  DropZone({this.listener});

  @override
  State<StatefulWidget> createState() {
    return _DropZoneState();
  }
}

class _DropZoneState extends State<DropZone> {
  StreamSubscription<MouseEvent> _onDragOverSubscription;
  StreamSubscription<MouseEvent> _onDropSubscription;

  final StreamController<Point<double>> _pointStreamController =
      new StreamController<Point<double>>.broadcast();
  final StreamController<_DragState> _dragStateStreamController =
      new StreamController<_DragState>.broadcast();

  @override
  void dispose() {
    this._onDropSubscription.cancel();
    this._onDragOverSubscription.cancel();
    this._pointStreamController.close();
    this._dragStateStreamController.close();
    super.dispose();
  }

  List<File> _files = <File>[];

  void _onDrop(MouseEvent value) {
    value.stopPropagation();
    value.preventDefault();
    _pointStreamController.sink.add(null);
    _addFiles(value.dataTransfer.files);
  }

  void _addFiles(List<File> newFiles) {
    if (widget.listener != null) {
      widget.listener.onFilePicked(newFiles);
    }
    this.setState(() {
      this._files = this._files..addAll(newFiles);

      /// TODO
      print(this._files.map((file) => file.name).toString());
    });
  }

  void _onDragOver(MouseEvent value) {
    value.stopPropagation();
    value.preventDefault();
    this
        ._pointStreamController
        .sink
        .add(Point<double>(value.layer.x.toDouble(), value.layer.y.toDouble()));
    this._dragStateStreamController.sink.add(_DragState.dragging);
  }

  @override
  void initState() {
    super.initState();
    this._onDropSubscription = document.body.onDrop.listen(_onDrop);
    this._onDragOverSubscription = document.body.onDragOver.listen(_onDragOver);
  }

  Widget _fileDrop(BuildContext context) {
    // styling
    return Container(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Drag & Drop your image here",
                style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.grey[500]),
              ),
              SizedBox(height: 24),
              Text(
                  "Create Android & iOS drawable/assets image online.\nUpload your maximum resolution image in PNG or JPG format and you will get zip file with resized image in it.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(color: Colors.grey[800]))
            ],
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _fileDrop(context);
  }
}
