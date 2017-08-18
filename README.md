# form_fields
### Rick Berger, Aphorica Inc <rickb@aphorica.com>

Set of FormFields corresponding to input fields, with data persister

## Introduction
The Form and FormField classes in Flutter are incomplete.  The only
input field with a corresponding FormField derivative is TextFormField.

Furthermore, a nasty side effect of scrolling or bringing up a soft
keyboard (obscuring a FormField instance) causes the field instance
to be deleted.  The result is simple form manipulations result in
dropped data.

## FormField
This package intends to create FormField-derived classes for all of
the input widgets.  At the moment, only one additional class is
implemented:

 - RadioTileChoiceFormField - for RadioTiles (labelled RadioButtons).

More are planned.

## Data Persistence.
Persisting data during form manipulations is up to the user and is
non-intuitive to implement.  This package adds a
'FormFieldStatePersister' class.  An instance of this class is
instantiated in the class instance that creates the form, and
ValueNotifiers are registered with the class and the FormField.

in the case of the TextFormField class, the TextEditingController
is derived from 'ValueNotifier' and integrates seamlessly with
this library.

## TODOS
An working example for what has been implemented so far (
called rb_tile_formfield_demo) will be provided here on
github as soon as I can get it uploaded.

Beyond that:
 - Obviously add more FormField implementations.
 - More documentation.
 - Fix bugs.


[Flutter Documentation](http://flutter.io/).
