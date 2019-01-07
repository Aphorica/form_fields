# form_fields
### Rick Berger, Aphorica Inc <gbergeraph@gmail.com>

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
the input widgets, starting with the \*Tile classes (the labelled
classes):
implemented:

 - RadioTileChoiceFormField - for RadioTiles (labelled RadioButtons).
 - CheckboxTileFormField - for CheckboxTiles
 - SwitchTileFormField - for SwitchTiles
 - TextInputFormField - reimplementation of TextFormField that corrects an update issue

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

## Testing/Demos
Check out the following repos that are combined tests/demos:
<dl>
<dt><a href="https://github.com/rickbsgu/rbtile_formfield_demo" target="_blank">rbtile_formfield_demo</a></dt>
<dd>Demos radiobutton tiles in various configurations.</dd>
<dt><a href="https://github.com/rickbsgu/gen_formfields_demo" target="_blank">gen_formfields_demo</a></dt>
<dd>
Intended to be a more complete demo.  Currently tests _CheckboxTileFormField_ and _SwitchTileFormField_</dd>
</dl>

## TODOS
 - Add more FormField implementations.
 - More documentation.
 - Fix bugs.


[Flutter Documentation](http://flutter.io/).
