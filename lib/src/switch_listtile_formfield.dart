import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class SwitchListTileFormField extends FormField<bool>{
  SwitchListTileFormField({
    Key key,
    ValueNotifier<bool> persister,
    bool initialValue,
    Color activeColor,
    ImageProvider activeThumbImage,
    bool dense,
    ImageProvider inactiveThumbImage,
    bool isThreeLine = false,
    Widget secondary,
    Widget title,
    Widget subtitle,
  }) : super(
    key: key,
    initialValue: persister != null? persister.value : initialValue,
    builder: (FormFieldState<bool> field) {
      return new SwitchListTile(
        value: field.value,
        activeColor: activeColor,
        activeThumbImage: activeThumbImage,
        dense: dense,
        inactiveThumbImage: inactiveThumbImage,
        isThreeLine: isThreeLine,
        secondary: secondary,
        title: title,
        subtitle: subtitle,
        onChanged: (bool value) {
          persister.value = value;
          field.onChanged(value);
        }
      );
    }
  );
}