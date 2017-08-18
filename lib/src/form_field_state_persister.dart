import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Reset function signature
///
typedef void StatePersisterReset(String name, ValueNotifier<dynamic> persister, dynamic initialValue);


// internal item class
class FieldStatePersisterItem<T> {
  T initialValue;
  ValueNotifier<T> persister;
  StatePersisterReset reset;

  FieldStatePersisterItem (this.initialValue, this.persister, this.reset);

  void resetToInitialValue(String key) {
    reset(key, persister, initialValue);
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
///  - Add ValueNotifiers for each Formfield via the addPersister function.
///
/// At this point, you don't have to carry a reference to the ValueNotifier,
/// anymore.  If you need it (to insert into a Formfield for instance),
/// just retrieve it using the '[]' operator.
///
/// ### Notes:
///  - The derived Formfield needs to be able to accept the persister
///    (ValueNotifier - derived) and use it to reinstate/save values.
///
///  - TextEditingController is derived from ValueNotifier.
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
        new TextEditingValue(text: initialValue);
  }

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
  void addPersister(String name, dynamic initialValue, ValueNotifier<dynamic> persister,
                    Function cb,
                    [StatePersisterReset reset = null])
  {
    if (reset == null) {
      reset = persister.runtimeType == TextEditingController?
                _textPersisterReset : _defaultPersisterReset;
    }

    FieldStatePersisterItem item = new FieldStatePersisterItem<dynamic>(initialValue, persister, reset);
    if (!persister.runtimeType.toString().startsWith('ValueNotifier'))
      item.resetToInitialValue(name);
                // regular value notifiers are created with initial values
                // assume anything else (TextEditingController, custom) need
                // to be initialized

    persister.addListener(cb);
    _persisterList[name] = item;
  }

  /// Fetch a persister (ValueNotifier - derived instance)
  ///
  ValueNotifier operator [](String key) => _persisterList[key].persister;

  /// Resets the persisters to the provided initial values.
  ///
  /// Note this will not reset any internal representation (model) of the
  /// values.
  ///
  void resetToInitialValues() {
    for(String key in _persisterList.keys) {
      _persisterList[key].resetToInitialValue(key);
    }
  }
}