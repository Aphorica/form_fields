import 'dart:math' as Math;

import 'package:flutter/material.dart';

enum YesNoChoice { yes, no, unknown }

typedef void OnRadioTileChoiceChanged<T>(T value);

enum ChoiceLayoutDir { row, column }

/// Defines 'Choice' items that are added to the field and define the
/// RadioTile characteristics.
///
class ChoiceDescriptorItem<T> {
  String _label;
  String get label => _label;
  CrossAxisAlignment _align;
  CrossAxisAlignment get align => _align;
  T _value;
  T get value => _value;

  ChoiceDescriptorItem({String label, T value,
                        CrossAxisAlignment align=CrossAxisAlignment.center}) :
      _label=label, _align=align, _value=value {
      if (_label == null) throw('label argument is required');
      if (_value == null) throw('value argument is required');
  }
}

/// A FormField containing a set of RadioTiles.  A gray rounded rectangular
/// background is drawn by default with a title.  You can prevent it from
/// drawing by setting 'showBackground' to false in the constructor arguments.
///
/// You can also
///
/// An enum specifies which
/// RadioTile is active.  A very simple schematic usage is as follows:
///
///   enum Background { bg_black, bg_white }
///
///   class ImageData {
///     Background: background = Background.bg_white
///     .... (other stuff)
///   }
///
///   class BackgroundChooser {
//
///     ImageData imageData = new ImageData;
///
///     FormFieldStatePersister persister = new FormFieldStatePersister();
///     persister.addSimplePersister('Background', Background.bg_black, update);
///
///     void update() { setState((){}); }
///
///     Widget build(BuildContext context) {
///       Form theForm = new Form(
///         child: new Row(
///           children: [
///             new RadioTileChoiceFormField<Background>(
///               title: 'Background Color',
///               persister: persister['Background'].persister,
///               choiceDescriptors: <ChoiceDescriptorItem>[
///                  new ChoiceDescriptorItem(
///                    label: 'Black',
///                    value: Background.bg_black
///                  ),
///                  new ChoiceDescriptorItem(
///                    label: 'White',
///                    value: Background.bg_white
///                  )
///                ]
///              );
///            ]
///          );
///        )
///      }
///
///       // (create the parent widgets as normal and add theForm
///       //  to the proper parent.)
///
///      // (this would be triggered by a button)
///      void resetFields() {
///         // (reset the model)
///        persister.resetToInitialValues();
///        update();
///      }
///    }
///
/// This would create a form with a single field, containing two radio tiles,
/// one for bg_black and one for bg_white.  Initially, it is set to bg_white.
///
/// Note that if there is no button for a corresponding value and that is
/// the initial value (such as Background.none) no buttons will be set.  In that
/// case, you may want to set a validator to insure the value is not equal to
/// the invalid value, so the field can display an error.
///
/// If there is a button for every possible value, no validator is required.
///
/// 'layoutDirection' defaults to Row, however you can specify Column if you
/// wish. If you specify 'itemsPerRow' as less than the number of available
/// items, the result will be multiple rows each containing up to 'itemsPerRow'
///
class RadioTileChoiceFormField<T> extends FormField<T> {
  final ValueNotifier<T> _persister;

  RadioTileChoiceFormField({
    Key key,
    ValueNotifier<T> persister,   // see FormFieldStatePersister for further information
    T initialValue,
    FormFieldSetter<T> onSaved,
    FormFieldValidator<T> validator,
    ChoiceLayoutDir layoutDir = ChoiceLayoutDir.row,
    List<ChoiceDescriptorItem> choiceDescriptors,
    String label,
    bool showBackground = true,
    EdgeInsets backgroundPadding,
    BoxDecoration backgroundDecoration,
    int itemsPerRow = 10000
  }) : _persister = persister, super (
    key: key,
    initialValue: persister != null? persister.value : initialValue,
    onSaved: onSaved,
    validator: validator == null? (T value) => null : validator, // usually good
    builder: (FormFieldState<T> field) {
      Flex radioList = _createRadioList<T>(itemsPerRow, field, layoutDir,
                                          choiceDescriptors );

      if (showBackground) {
        Widget ctnr = _createChoiceContainer( field.context, label,
                                      backgroundPadding, backgroundDecoration,
                                      radioList );
        return ctnr;
      }

      return radioList;
    }
  );

  void valueChanged(T value) {
    if (_persister != null) {
    _persister.value = value;
    }
  }

  static Flex _createRadioList<T>(int itemsPerRow, FormFieldState<T> field,
                                 ChoiceLayoutDir layoutDir,
                                 List<ChoiceDescriptorItem> choiceDescriptors) {
      Flex radioList;

      if (Form.of(field.context).widget.autovalidate) {
        field.validate();
      }

      if (itemsPerRow < choiceDescriptors.length || field.hasError) {
              // multi-row

        List<Row> rows = <Row>[];
        if (field.hasError)
          rows.add( new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [new Text('  Error: ' + field.errorText,
                style: Theme.of(field.context).textTheme.caption
                  .copyWith(color:Colors.red[800]))]
            )
          );
        rows.addAll(_makeRows(Math.min(itemsPerRow, choiceDescriptors.length),
                              field, choiceDescriptors));

        radioList = new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows
        );

      } else {
              // single-row
        List<Widget> children = _makeChildren(
          layoutDir, field, choiceDescriptors);
        radioList = layoutDir == ChoiceLayoutDir.row ?
          new Row(crossAxisAlignment: CrossAxisAlignment.center,
                  children: children) :
          new Column(crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisSize: MainAxisSize.min,
                     children: children);
      }

      return radioList;
    }

  static List<Row> _makeRows<T>(
    int itemsPerRow,
    FormFieldState<T> field,
    List<ChoiceDescriptorItem> choiceDescriptors)
  {
    List<Row> rows = <Row>[];

    for (int startIX = 0; startIX < choiceDescriptors.length; startIX += itemsPerRow) {
      rows.add(
        new Row(children: _makeChildren(ChoiceLayoutDir.row,
          field,
          choiceDescriptors.sublist(startIX, startIX + itemsPerRow)
          )
        )
      );
    }

    return rows;
  }

  static List<Widget> _makeChildren<T>(ChoiceLayoutDir layoutDir,
    FormFieldState<T> field,
    List<ChoiceDescriptorItem> choiceDescriptors)
  {
    List<Widget> children = <Widget>[];
    for (ChoiceDescriptorItem item in choiceDescriptors) {
      RadioListTile tile = new RadioListTile<T>(
        title: new Text(item.label),
        value: item.value,
        groupValue: field.value,
        onChanged: (T value) {
          (field.widget as RadioTileChoiceFormField).valueChanged(value);
          field.onChanged(value);
        }
      );

      children.add(layoutDir == ChoiceLayoutDir.row?
                     _createColumnWrapper(tile):
                     new Row(
                             crossAxisAlignment: item.align,
                             children: [_createColumnWrapper(tile)])
                   );
    }

    return children;
  }

  static Widget _createColumnWrapper(Widget widget) {
     return new Flexible(
       child: new Column(
         children: <Widget>[widget]
       )
     );
  }

  static Container _createChoiceContainer(BuildContext context, String label,
                                         EdgeInsets backgroundPadding,
                                         BoxDecoration backgroundDecoration,
                                         Widget radioList)
  {
    List<Widget> children = <Widget>[];
    if (label != null && label.isNotEmpty) {
      children.add(new Text(
          label, style: Theme.of(context).textTheme.body1.copyWith(
          color:Colors.black87).apply(fontSizeFactor: 1.3)));
      children.add( new Divider(color: Colors.black38));
    }

    children.add(radioList);

    return new Container(
      margin: backgroundPadding != null? backgroundPadding : EdgeInsets.zero,
      padding: new EdgeInsets.only(top: 8.0),
      decoration: backgroundDecoration != null? backgroundDecoration :
                    new BoxDecoration(
                        color: Colors.black12,
                        borderRadius: new BorderRadius.all(new Radius.circular(10.0))
                    ),
      child: new Column(children: children));
  }
}
