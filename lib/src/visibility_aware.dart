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

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

// TODO: eliminate the need for a tree walk when visibility changes
mixin VisibilityAwareMixin on RenderBox {
  Set<int> _hiddenAncestors = <int>{};
  bool _isVisible = true;
  bool get isVisible => _isVisible && _hiddenAncestors.isEmpty;
  set isVisible(bool value) {
    if (value != _isVisible) {
      bool wasVisible = isVisible;
      _isVisible = value;
      visitChildren(_setHiddenAncestorsField(value, depth));
      if (isVisible != wasVisible) {
        handleIsVisibleChanged();
      }
    }
  }

  static void setChildVisible(RenderObject child, bool isVisible) {
    if (child is VisibilityAwareMixin) {
      child.isVisible = isVisible;
    } else {
      child.visitChildren(_setHiddenAncestorsField(isVisible, child.depth));
    }
  }

  static RenderObjectVisitor _setHiddenAncestorsField(bool isVisible, int depth) {
    return isVisible ? _unhideDescendants(depth) : _hideDescendants(depth);
  }

  static RenderObjectVisitor _hideDescendants(int depth) {
    void visitor(RenderObject child) {
      if (child is VisibilityAwareMixin) {
        bool childWasVisible = child.isVisible;
        child._hiddenAncestors.add(depth);
        if (child.isVisible != childWasVisible) {
          child.handleIsVisibleChanged();
        }
      }
      child.visitChildren(visitor);
    };
    return visitor;
  }

  static RenderObjectVisitor _unhideDescendants(int depth) {
    void visitor(RenderObject child) {
      if (child is VisibilityAwareMixin) {
        bool childWasVisible = child.isVisible;
        child._hiddenAncestors.remove(depth);
        if (child.isVisible != childWasVisible) {
          child.handleIsVisibleChanged();
        }
      }
      child.visitChildren(visitor);
    };
    return visitor;
  }

  @protected
  void handleIsVisibleChanged() {}
}
