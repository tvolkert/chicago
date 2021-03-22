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

import 'package:chicago/chicago.dart';
import 'package:flutter/widgets.dart' hide TableCell, TableRow;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WidgetSurveyor returns correct unconstrained measurements', (WidgetTester tester) async {
    const WidgetSurveyor surveyor = WidgetSurveyor();
    final Size size = surveyor.measureWidget(SizedBox(width: 100, height: 200));
    expect(size, const Size(100, 200));
  });

  testWidgets('WidgetSurveyor returns correct constrained measurements', (WidgetTester tester) async {
    const WidgetSurveyor surveyor = WidgetSurveyor();
    final Size size = surveyor.measureWidget(
      SizedBox(width: 100, height: 200),
      constraints: BoxConstraints(maxWidth: 80, maxHeight: 180),
    );
    expect(size, const Size(80, 180));
  });

  testWidgets('WidgetSurveyor disposes of the widget tree', (WidgetTester tester) async {
    const WidgetSurveyor surveyor = WidgetSurveyor();
    final List<WidgetState> states = <WidgetState>[];
    surveyor.measureWidget(SizedBox(child: TestStates(states: states)));
    expect(states, [WidgetState.initialized, WidgetState.disposed]);
  });

  testWidgets('WidgetSurveyor does not pollute widget binding global keys', (WidgetTester tester) async {
    final int initialCount = WidgetsBinding.instance!.buildOwner!.globalKeyCount;
    const WidgetSurveyor surveyor = WidgetSurveyor();
    surveyor.measureWidget(TestGlobalKeyPollution(
      key: GlobalKey(),
      expectedGlobalKeyCountInBinding: initialCount,
      expectedGlobalKeyCountInContextDuringInit: 2,
      expectedGlobalKeyCountInContextDuringDispose: 1,
    ));
    expect(WidgetsBinding.instance!.buildOwner!.globalKeyCount, initialCount);
  });
}

enum WidgetState {
  initialized,
  disposed,
}

class TestStates extends StatefulWidget {
  const TestStates({required this.states});

  final List<WidgetState> states;

  @override
  TestStatesState createState() => TestStatesState();
}

class TestStatesState extends State<TestStates> {
  @override
  void initState() {
    super.initState();
    widget.states.add(WidgetState.initialized);
  }

  @override
  void dispose() {
    widget.states.add(WidgetState.disposed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container();
}

class TestGlobalKeyPollution extends StatefulWidget {
  const TestGlobalKeyPollution({
    Key? key,
    required this.expectedGlobalKeyCountInBinding,
    required this.expectedGlobalKeyCountInContextDuringInit,
    required this.expectedGlobalKeyCountInContextDuringDispose,
  }) : super(key: key);

  final int expectedGlobalKeyCountInBinding;
  final int expectedGlobalKeyCountInContextDuringInit;
  final int expectedGlobalKeyCountInContextDuringDispose;

  @override
  TestGlobalKeyPollutionState createState() => TestGlobalKeyPollutionState();
}

class TestGlobalKeyPollutionState extends State<TestGlobalKeyPollution> {
  @override
  void initState() {
    super.initState();
    expect(WidgetsBinding.instance!.buildOwner!.globalKeyCount, widget.expectedGlobalKeyCountInBinding);
    expect(context.owner!.globalKeyCount, widget.expectedGlobalKeyCountInContextDuringInit);
  }

  @override
  void dispose() {
    expect(WidgetsBinding.instance!.buildOwner!.globalKeyCount, widget.expectedGlobalKeyCountInBinding);
    expect(context.owner!.globalKeyCount, widget.expectedGlobalKeyCountInContextDuringDispose);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container();
}
