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

import 'dart:ui' show hashValues;

import 'package:flutter/foundation.dart';

@immutable
class IndexedOffset with Diagnosticable {
  const IndexedOffset(this.rowIndex, this.columnIndex);

  final int rowIndex;
  final int columnIndex;

  @override
  int get hashCode => hashValues(rowIndex, columnIndex);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return other is IndexedOffset && other.rowIndex == rowIndex && other.columnIndex == columnIndex;
  }

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('rowIndex', rowIndex));
    properties.add(IntProperty('columnIndex', columnIndex));
  }
}
