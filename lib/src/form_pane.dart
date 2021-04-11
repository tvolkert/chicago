// Licensed to the Apache Software Foundation (ASF) under one or more
// contributor license agreements.  See the NOTICE file distributed with
// this work for additional information regarding copyright ownership.
// The ASF licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'foundation.dart';

@immutable
class Flag {
  const Flag({
    required this.messageType,
    required this.message,
  });

  final MessageType messageType;
  final String message;
}

@immutable
class FormPaneField {
  const FormPaneField({
    required this.label,
    required this.child,
    this.flag,
  });

  final String label;
  final Widget child;
  final Flag? flag;
}

class FormPane extends StatelessWidget {
  const FormPane({
    Key? key,
    this.horizontalSpacing = 6,
    this.verticalSpacing = 6,
    this.flagImageOffset = 4,
    this.delimiter = ':',
    this.stretch = false,
    this.rightAlignLabels = false,
    required this.children,
  }) : super(key: key);

  final double horizontalSpacing;
  final double verticalSpacing;
  final double flagImageOffset;
  final String delimiter;
  final bool stretch;
  final bool rightAlignLabels;
  final List<FormPaneField> children;

  Widget _newLabel(FormPaneField field) {
    return Text('${field.label}$delimiter');
  }

  Widget _newFlag(FormPaneField field) {
    if (field.flag == null) {
      return const _NoFlag();
    } else {
      return field.flag!.messageType.toSmallImage();
//      return Tooltip(
//        message: field.flag.message,
//        child: field.flag.messageType.toSmallImage(),
//      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _RawForm(
      key: key,
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing,
      flagImageOffset: flagImageOffset,
      stretch: stretch,
      rightAlignLabels: rightAlignLabels,
      children: children.map<_RawFormField>((FormPaneField field) {
        return _RawFormField(
          label: _newLabel(field),
          child: field.child,
          flag: _newFlag(field),
        );
      }).toList(growable: false),
    );
  }
}

class _RawFormField {
  const _RawFormField({
    required this.label,
    required this.child,
    required this.flag,
  });

  final Widget label;
  final Widget child;
  final Widget flag;
}

class _RawForm extends RenderObjectWidget {
  const _RawForm({
    Key? key,
    this.horizontalSpacing = 6,
    this.verticalSpacing = 6,
    this.flagImageOffset = 4,
    this.stretch = false,
    this.rightAlignLabels = false,
    required this.children,
  }) : super(key: key);

  final double horizontalSpacing;
  final double verticalSpacing;
  final double flagImageOffset;
  final bool stretch;
  final bool rightAlignLabels;
  final List<_RawFormField> children;

  @override
  RenderObjectElement createElement() => _FormElement(this);

  @override
  _RenderForm createRenderObject(BuildContext context) {
    return _RenderForm(
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing,
      flagImageOffset: flagImageOffset,
      stretch: stretch,
      rightAlignLabels: rightAlignLabels,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderForm renderObject) {
    renderObject
      ..horizontalSpacing = horizontalSpacing
      ..verticalSpacing = verticalSpacing
      ..flagImageOffset = flagImageOffset
      ..stretch = stretch
      ..rightAlignLabels = rightAlignLabels;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('horizontalSpacing', horizontalSpacing));
    properties.add(DiagnosticsProperty<double>('verticalSpacing', verticalSpacing));
    properties.add(DiagnosticsProperty<double>('flagImageOffset', flagImageOffset));
    properties.add(DiagnosticsProperty<bool>('stretch', stretch));
    properties.add(DiagnosticsProperty<bool>('rightAlignLabels', rightAlignLabels));
  }
}

enum _SlotType {
  label,
  field,
  flag,
}

@immutable
class _FormSlot {
  const _FormSlot.label(this.previous) : type = _SlotType.label;

  const _FormSlot.field(this.previous) : type = _SlotType.field;

  const _FormSlot.flag(this.previous) : type = _SlotType.flag;

  final Element? previous;
  final _SlotType type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _FormSlot && previous == other.previous && type == other.type;
  }

  @override
  int get hashCode => hashValues(previous, type);
}

class _FormRow {
  Element? label;
  Element? field;
  Element? flag;
}

class _FormElement extends RenderObjectElement {
  _FormElement(_RawForm widget) : super(widget);

  late List<_FormRow> _rows;

  @override
  _RawForm get widget => super.widget as _RawForm;

  @override
  _RenderForm get renderObject => super.renderObject as _RenderForm;

  @override
  void visitChildren(ElementVisitor visitor) {
    for (_FormRow row in _rows) {
      visitor(row.label!);
      visitor(row.field!);
      visitor(row.flag!);
    }
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _FormRow previous = _FormRow();
    _rows = List<_FormRow>.generate(widget.children.length, (int index) {
      final _RawFormField field = widget.children[index];
      _FormRow row = _FormRow();
      row.label = updateChild(null, field.label, _FormSlot.label(previous.label));
      row.field = updateChild(null, field.child, _FormSlot.field(previous.field));
      row.flag = updateChild(null, field.flag, _FormSlot.flag(previous.flag));
      previous = row;
      return row;
    }, growable: false);
  }

  @override
  void update(_RawForm newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    List<_FormRow> newRows = <_FormRow>[];
    _FormRow previous = _FormRow();
    int i = 0;
    for (_RawFormField field in newWidget.children) {
      final _FormRow row = i < _rows.length ? _rows[i] : _FormRow();
      newRows.add(row);
      row.label = updateChild(row.label, field.label, _FormSlot.label(previous.label));
      row.field = updateChild(row.field, field.child, _FormSlot.field(previous.field));
      row.flag = updateChild(row.flag, field.flag, _FormSlot.flag(previous.flag));
      previous = row;
      i++;
    }
    for (; i < _rows.length; i++) {
      final _FormRow row = _rows[i];
      row.label = updateChild(row.label, null, null);
      row.field = updateChild(row.field, null, null);
      row.flag = updateChild(row.flag, null, null);
    }
    _rows = newRows.toList(growable: false);
  }

  @override
  void insertRenderObjectChild(RenderBox child, _FormSlot slot) {
    switch (slot.type) {
      case _SlotType.label:
        renderObject.insertLabel(child, after: slot.previous?.renderObject as RenderBox?);
        break;
      case _SlotType.field:
        renderObject.insertField(child, after: slot.previous?.renderObject as RenderBox?);
        break;
      case _SlotType.flag:
        renderObject.insertFlag(child, after: slot.previous?.renderObject as RenderBox?);
        break;
    }
  }

  @override
  void moveRenderObjectChild(RenderBox child, _FormSlot oldSlot, _FormSlot newSlot) {
    assert(oldSlot.type == newSlot.type);
    assert(child.parent == renderObject);
    switch (oldSlot.type) {
      case _SlotType.label:
        renderObject.moveLabel(child, after: newSlot.previous?.renderObject as RenderBox?);
        break;
      case _SlotType.field:
        renderObject.moveField(child, after: newSlot.previous?.renderObject as RenderBox?);
        break;
      case _SlotType.flag:
        renderObject.moveFlag(child, after: newSlot.previous?.renderObject as RenderBox?);
        break;
    }
  }

  @override
  void removeRenderObjectChild(RenderBox child, _FormSlot slot) {
    assert(child.parent == renderObject);
    switch (slot.type) {
      case _SlotType.label:
        renderObject.removeLabel(child);
        break;
      case _SlotType.field:
        renderObject.removeField(child);
        break;
      case _SlotType.flag:
        renderObject.removeFlag(child);
        break;
    }
  }

  @override
  void forgetChild(Element child) {
    print('TODO: forgetChild()');
    super.forgetChild(child);
  }
}

class FormParentData extends ContainerBoxParentData<RenderBox> {}

class _ChildList {
  int _childCount = 0;
  RenderBox? firstChild;
  RenderBox? lastChild;

  static bool _debugUltimatePreviousSiblingOf(RenderBox child, {required RenderBox? equals}) {
    ContainerParentDataMixin<RenderBox> childParentData =
        child.parentData as ContainerParentDataMixin<RenderBox>;
    while (childParentData.previousSibling != null) {
      assert(childParentData.previousSibling != child);
      child = childParentData.previousSibling!;
      childParentData = child.parentData as ContainerParentDataMixin<RenderBox>;
    }
    return child == equals;
  }

  static bool _debugUltimateNextSiblingOf(RenderBox child, {required RenderBox? equals}) {
    ContainerParentDataMixin<RenderBox> childParentData =
        child.parentData as ContainerParentDataMixin<RenderBox>;
    while (childParentData.nextSibling != null) {
      assert(childParentData.nextSibling != child);
      child = childParentData.nextSibling!;
      childParentData = child.parentData as ContainerParentDataMixin<RenderBox>;
    }
    return child == equals;
  }

  void insert(RenderBox child, {RenderBox? after}) {
    final FormParentData childParentData = child.parentData as FormParentData;
    assert(childParentData.nextSibling == null);
    assert(childParentData.previousSibling == null);
    _childCount += 1;
    assert(_childCount > 0);
    if (after == null) {
      // insert at the start (_firstChild)
      childParentData.nextSibling = firstChild;
      if (firstChild != null) {
        final FormParentData firstChildParentData = firstChild!.parentData as FormParentData;
        firstChildParentData.previousSibling = child;
      }
      firstChild = child;
      lastChild ??= child;
    } else {
      assert(firstChild != null);
      assert(lastChild != null);
      assert(_debugUltimatePreviousSiblingOf(after, equals: firstChild));
      assert(_debugUltimateNextSiblingOf(after, equals: lastChild));
      final FormParentData afterParentData = after.parentData as FormParentData;
      if (afterParentData.nextSibling == null) {
        // insert at the end (_lastChild); we'll end up with two or more children
        assert(after == lastChild);
        childParentData.previousSibling = after;
        afterParentData.nextSibling = child;
        lastChild = child;
      } else {
        // insert in the middle; we'll end up with three or more children
        // set up links from child to siblings
        childParentData.nextSibling = afterParentData.nextSibling;
        childParentData.previousSibling = after;
        // set up links from siblings to child
        final FormParentData childPreviousSiblingParentData =
            childParentData.previousSibling!.parentData as FormParentData;
        final FormParentData childNextSiblingParentData =
            childParentData.nextSibling!.parentData as FormParentData;
        childPreviousSiblingParentData.nextSibling = child;
        childNextSiblingParentData.previousSibling = child;
        assert(afterParentData.nextSibling == child);
      }
    }
  }

  void remove(RenderBox child) {
    final FormParentData childParentData = child.parentData! as FormParentData;
    assert(_debugUltimatePreviousSiblingOf(child, equals: firstChild));
    assert(_debugUltimateNextSiblingOf(child, equals: lastChild));
    assert(_childCount >= 0);
    if (childParentData.previousSibling == null) {
      assert(firstChild == child);
      firstChild = childParentData.nextSibling;
    } else {
      final FormParentData childPreviousSiblingParentData =
          childParentData.previousSibling!.parentData! as FormParentData;
      childPreviousSiblingParentData.nextSibling = childParentData.nextSibling;
    }
    if (childParentData.nextSibling == null) {
      assert(lastChild == child);
      lastChild = childParentData.previousSibling;
    } else {
      final FormParentData childNextSiblingParentData =
          childParentData.nextSibling!.parentData! as FormParentData;
      childNextSiblingParentData.previousSibling = childParentData.previousSibling;
    }
    childParentData.previousSibling = null;
    childParentData.nextSibling = null;
    _childCount -= 1;
  }
}

typedef FormRenderObjectVisitor = void Function(RenderBox label, RenderBox field, RenderBox flag);

class _RenderForm extends RenderBox {
  _RenderForm({
    required double horizontalSpacing,
    required double verticalSpacing,
    required double flagImageOffset,
    required bool stretch,
    required bool rightAlignLabels,
  }) {
    this.horizontalSpacing = horizontalSpacing;
    this.verticalSpacing = verticalSpacing;
    this.flagImageOffset = flagImageOffset;
    this.stretch = stretch;
    this.rightAlignLabels = rightAlignLabels;
  }

  static const double _flagImageSize = 16;

  double? _horizontalSpacing;
  double get horizontalSpacing => _horizontalSpacing!;
  set horizontalSpacing(double value) {
    if (value == _horizontalSpacing) return;
    _horizontalSpacing = value;
    markNeedsLayout();
  }

  double? _verticalSpacing;
  double get verticalSpacing => _verticalSpacing!;
  set verticalSpacing(double value) {
    if (value == _verticalSpacing) return;
    _verticalSpacing = value;
    markNeedsLayout();
  }

  double? _flagImageOffset;
  double get flagImageOffset => _flagImageOffset!;
  set flagImageOffset(double value) {
    if (value == _flagImageOffset) return;
    _flagImageOffset = value;
    markNeedsLayout();
  }

  bool? _stretch;
  bool get stretch => _stretch!;
  set stretch(bool value) {
    if (value == _stretch) return;
    _stretch = value;
    markNeedsLayout();
  }

  bool? _rightAlignLabels;
  bool get rightAlignLabels => _rightAlignLabels!;
  set rightAlignLabels(bool value) {
    if (value == _rightAlignLabels) return;
    _rightAlignLabels = value;
    markNeedsLayout();
  }

  final Map<_SlotType, _ChildList> _children = <_SlotType, _ChildList>{
    _SlotType.label: _ChildList(),
    _SlotType.field: _ChildList(),
    _SlotType.flag: _ChildList(),
  };

  void _insertChild(RenderBox child, {RenderBox? after, required _SlotType type}) {
    final _ChildList children = _children[type]!;
    assert(child != this, 'A RenderObject cannot be inserted into itself.');
    assert(after != this,
        'A RenderObject cannot simultaneously be both the parent and the sibling of another RenderObject.');
    assert(child != after, 'A RenderObject cannot be inserted after itself.');
    assert(child != children.firstChild);
    assert(child != children.lastChild);
    adoptChild(child);
    children.insert(child, after: after);
  }

  void insertLabel(RenderBox label, {RenderBox? after}) {
    _insertChild(label, after: after, type: _SlotType.label);
  }

  void insertField(RenderBox child, {RenderBox? after}) {
    _insertChild(child, after: after, type: _SlotType.field);
  }

  void insertFlag(RenderBox child, {RenderBox? after}) {
    _insertChild(child, after: after, type: _SlotType.flag);
  }

  void _moveChild(RenderBox child, {RenderBox? after, required _SlotType type}) {
    assert(child != this);
    assert(after != this);
    assert(child != after);
    assert(child.parent == this);
    final FormParentData childParentData = child.parentData! as FormParentData;
    if (childParentData.previousSibling == after) {
      return;
    }
    final _ChildList children = _children[type]!;
    children.remove(child);
    children.insert(child, after: after);
    markNeedsLayout();
  }

  void moveLabel(RenderBox label, {RenderBox? after}) {
    _moveChild(label, after: after, type: _SlotType.label);
  }

  void moveField(RenderBox child, {RenderBox? after}) {
    _moveChild(child, after: after, type: _SlotType.field);
  }

  void moveFlag(RenderBox child, {RenderBox? after}) {
    _moveChild(child, after: after, type: _SlotType.flag);
  }

  void _removeChild(RenderBox child, {required _SlotType type}) {
    final _ChildList children = _children[type]!;
    children.remove(child);
    dropChild(child);
  }

  void removeLabel(RenderBox label) {
    _removeChild(label, type: _SlotType.label);
  }

  void removeField(RenderBox field) {
    _removeChild(field, type: _SlotType.field);
  }

  void removeFlag(RenderBox flag) {
    _removeChild(flag, type: _SlotType.flag);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FormParentData) {
      child.parentData = FormParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    visitChildren((RenderObject child) {
      child.attach(owner);
    });
  }

  @override
  void detach() {
    super.detach();
    visitChildren((RenderObject child) {
      child.detach();
    });
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    visitRows((RenderBox label, RenderBox field, RenderBox flag) {
      visitor(label);
      visitor(field);
      visitor(flag);
    });
  }

  void visitRows(FormRenderObjectVisitor visitor, {bool until()?}) {
    RenderBox? label = _children[_SlotType.label]!.firstChild;
    RenderBox? field = _children[_SlotType.field]!.firstChild;
    RenderBox? flag = _children[_SlotType.flag]!.firstChild;
    while (field != null) {
      assert(label != null);
      assert(flag != null);
      visitor(label!, field, flag!);
      if (until != null && until()) {
        return;
      }
      final FormParentData labelParentData = label.parentData as FormParentData;
      final FormParentData fieldParentData = field.parentData as FormParentData;
      final FormParentData flagParentData = flag.parentData as FormParentData;
      label = labelParentData.nextSibling;
      field = fieldParentData.nextSibling;
      flag = flagParentData.nextSibling;
    }
    assert(label == null);
    assert(flag == null);
  }

  void visitChildrenOfType(_SlotType type, RenderObjectVisitor visitor) {
    RenderBox? child = _children[type]!.firstChild;
    while (child != null) {
      visitor(child);
      final FormParentData childParentData = child.parentData as FormParentData;
      child = childParentData.nextSibling;
    }
  }

  @override
  void redepthChildren() {
    visitChildren((RenderObject child) {
      redepthChild(child);
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    bool isHit = false;
    visitRows((RenderBox label, RenderBox field, RenderBox flag) {
      for (RenderBox child in [field, label, flag]) {
        final FormParentData childParentData = child.parentData as FormParentData;
        isHit = result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - childParentData.offset);
            return child.hitTest(result, position: transformed);
          },
        );
        if (isHit) {
          return;
        }
      }
    }, until: () => isHit);
    return isHit;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) => computeMinIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) {
    return 0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  @override
  void performLayout() {
    // Determine the maximum label width
    double maxLabelWidth = 0;
    visitChildrenOfType(_SlotType.label, (RenderObject child) {
      child.layout(const BoxConstraints(), parentUsesSize: true);
      maxLabelWidth = math.max(maxLabelWidth, (child as RenderBox).size.width);
    });

    BoxConstraints fieldConstraints = constraints.deflate(
      EdgeInsets.only(left: maxLabelWidth + horizontalSpacing + flagImageOffset + _flagImageSize),
    );
    if (stretch) {
      fieldConstraints = fieldConstraints.tighten(width: fieldConstraints.maxWidth);
    }

    double rowY = 0;
    double maxFieldWidth = 0;
    visitRows((RenderBox label, RenderBox field, RenderBox flag) {
      final FormParentData labelParentData = label.parentData as FormParentData;
      final FormParentData childParentData = field.parentData as FormParentData;
      final FormParentData flagParentData = flag.parentData as FormParentData;

      final double labelAscent = label.getDistanceToBaseline(TextBaseline.alphabetic)!;
      final double labelDescent = label.size.height - labelAscent;
      field.layout(fieldConstraints, parentUsesSize: true);
      final double fieldAscent = field.getDistanceToBaseline(TextBaseline.alphabetic)!;
      final double fieldDescent = field.size.height - fieldAscent;

      final double baseline = math.max(labelAscent, fieldAscent);
      final double rowHeight =
          math.max(baseline + math.max(labelDescent, fieldDescent), _flagImageSize);

      // Align the label and field to baseline
      double labelX = rightAlignLabels ? maxLabelWidth - label.size.width : 0;
      double labelY = rowY + (baseline - labelAscent);
      labelParentData.offset = Offset(labelX, labelY);
      double fieldX = maxLabelWidth + horizontalSpacing;
      double fieldY = rowY + (baseline - fieldAscent);
      childParentData.offset = Offset(fieldX, fieldY);

      // Vertically center the flag on the label
      flag.layout(BoxConstraints.tight(Size.square(_flagImageSize)));
      double flagY = labelY + (label.size.height - _flagImageSize) / 2;
      flagParentData.offset = Offset(fieldX + field.size.width + flagImageOffset, flagY);

      rowY += rowHeight + verticalSpacing;
      maxFieldWidth = math.max(maxFieldWidth, field.size.width);
    });

    size = constraints.constrainDimensions(
      maxLabelWidth + horizontalSpacing + maxFieldWidth + flagImageOffset + _flagImageSize,
      rowY - verticalSpacing,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    visitChildren((RenderObject child) {
      final FormParentData childParentData = child.parentData as FormParentData;
      context.paintChild(child, childParentData.offset + offset);
    });
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> result = <DiagnosticsNode>[];
    void add(RenderBox child, String name) {
      result.add(child.toDiagnosticsNode(name: name));
    }

    int i = 0;
    visitRows((RenderBox label, RenderBox field, RenderBox flag) {
      add(label, 'label_$i');
      add(field, 'field_$i');
      add(flag, 'flag_$i');
      i++;
    });
    return result;
  }
}

class _NoFlag extends LeafRenderObjectWidget {
  const _NoFlag({Key? key}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderNoFlag();
}

class _RenderNoFlag extends RenderBox {
  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.smallest;
  }
}
