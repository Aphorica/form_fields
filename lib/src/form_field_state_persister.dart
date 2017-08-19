import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Reset function signature
///
typedef void StatePersisterReset(String name, ValueNotifier<dynamic> persister, dynamic initialValue);
typedef String StatePersisterToString(String name, ValueNotifier<dynamic> persister);


// internal item class
class FieldStatePersisterItem<T> {
  String _name;
  T _initialValue;
  ValueNotifier<T> _persister;
  ValueNotifier<T> get persister => _persister;
  StatePersisterReset _reset;
  StatePersisterToString _toString;

  FieldStatePersisterItem (this._name, this._initialValue, this._persister,
                           this._reset, this._toString);

  void resetToInitialValue() {
    _reset(_name, _persister, _initialValue);
  }

  @override
  String toString() {
    return _toString(_name, _persister);
  }
}

///
/// Formfields have a nasty habit of getting reset to their initial values
/// when the form is scrolled or the keyboard obscures the form.  A method
/// needs to be implemented to perserve the state of the field data while
/// the form is being manipulated.
///
/// This maintains a Collection of ValueNotifiers used in FormFields
/// to maintain the state of formfield data during manipulations.
///
/// ### To use:
///  - Instantiate this class above the Form - in whatever class instantiates
///    the form works, but you can instantiate it higher, if you want.
///
///  - Add persisters for each Formfield via the addSimplePersister function.
///
/// At this point, you don't have to carry a reference to the ValueNotifier,
/// anymore.  If you need it (to insert into a Formfield for instance),
/// just retrieve it using the '[].persister' operator.
///
/// ### Notes:
///  - The derived Formfield needs to be able to accept a persister
///    (ValueNotifier - derived) and use it to reinstate/save values.
///
///  - TextEditingController is derived from ValueNotifier.
///
///  - You can provide your own 'toString' function, if you have
///    special considerations going to string.  The default functionality
///    strips '.' from enumerator types, and replaces '_' with ' ' for
///    a cleartext representation.
///
class FormFieldStatePersister {
  Map<String, FieldStatePersisterItem<dynamic>> _persisterList =
                                   <String, FieldStatePersisterItem<dynamic>>{};

  void _defaultPersisterReset(String name, ValueNotifier<dynamic> persister,
    dynamic initialValue) {
    persister.value = initialValue;
  }

  void _textPersisterReset(String name, ValueNotifier<dynamic> persister, dynamic initialValue) {
    (persister as TextEditingController).value =
    new TextEditingValue(text: initialValue); }

  String _defaultPersisterToString(String name, ValueNotifier<dynamic> persister) {
      String str = persister.value.toString();
      if (str.contains('.'))
        str = str.split('.')[1];  // handle enums

      return str.replaceAll(new RegExp('_'), ' ');
  }

  String _textPersisterToString(String name, ValueNotifier<dynamic> persister) =>
      (persister as TextEditingController).value.text;

    /// Add a persister (ValueNotifier - bare or derived instance)
  ///
  /// ### Notes:
  ///  - 'cb' is the callback to invoke when the value changes.  Typically, this
  ///    is a function in the instantiating code that minimally calls
  ///    setState((){})
  ///
  ///  - 'reset' is a function to reset the persister to its initial value.
  ///
  ///    - For underived or ValueNotifier fields whose value can be set directly,
  ///      a default function is provided to do that.
  ///
  ///    - TextEditingController requires a special procedure to set a value.
  ///      A default function is provided for this, as well.
  ///
  ///    - For the most part, you don't need to worry about this.  If, however,
  ///      you derive a specialized persister that requires a specific procedure
  ///      to set the value, you will need to provide this function.
  ///
  void addSimplePersister(String name, dynamic initialValue,
                    Function cb,
                    [StatePersisterToString toString,
                     StatePersisterReset reset])
  {
    ValueNotifier persister = initialValue.runtimeType == String?
      new TextEditingController() : new ValueNotifier<dynamic>(initialValue);

    if (reset == null) {
      reset = persister.runtimeType == TextEditingController?
      _textPersisterReset : _defaultPersisterReset;
    }

    if (toString == null) {
      toString = persister.runtimeType == TextEditingController?
        _textPersisterToString : _defaultPersisterToString;
    }

    FieldStatePersisterItem item =
      new FieldStatePersisterItem<dynamic>(name, initialValue, persister, reset, toString);

    item.resetToInitialValue();

    persister.addListener(cb);
    _persisterList[name] = item;
  }

  /// Fetch a persister item
  ///
  FieldStatePersisterItem operator [](String key) => _persisterList[key];

  /// Resets the persisters to the provided initial values.
  ///
  /// Note this will not reset any internal representation (model) of the
  /// values.
  ///
  void resetToInitialValues() {
    for(String key in _persisterList.keys) {
      _persisterList[key].resetToInitialValue();
    }
  }
}