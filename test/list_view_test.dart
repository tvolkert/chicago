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
import 'package:flutter/widgets.dart' hide ListView, TableCell, TableRow;
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildDummy(
      BuildContext context, int index, bool isSelected, bool isHighlighted, bool isDisabled) {
    return Container();
  }

  Widget wrap(Widget widget) {
    return ScrollPane(
      horizontalScrollBarPolicy: ScrollBarPolicy.stretch,
      verticalScrollBarPolicy: ScrollBarPolicy.stretch,
      view: widget,
    );
  }

  // Regression test for https://github.com/tvolkert/chicago/issues/10
  testWidgets('Can reuse selectionController across render objects', (WidgetTester tester) async {
    final ListViewSelectionController controller = ListViewSelectionController();
    await tester.pumpWidget(
      wrap(
        ListView(
          selectionController: controller,
          itemHeight: 20,
          length: 1,
          itemBuilder: buildDummy,
        ),
      ),
    );
    await tester.pumpWidget(
      Padding(
        padding: EdgeInsets.zero,
        child: wrap(
          ListView(
            selectionController: controller,
            itemHeight: 20,
            length: 1,
            itemBuilder: buildDummy,
          ),
        ),
      ),
    );
    controller.selectedIndex = 0;
  });
}
