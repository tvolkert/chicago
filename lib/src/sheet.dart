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

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'push_button.dart';
import 'foundation.dart';

class Sheet extends StatelessWidget {
  const Sheet({
    Key? key,
    required this.content,
    this.padding = const EdgeInsets.all(8),
  }) : super(key: key);

  final Widget content;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: const Color(0xebf6f4ed),
      elevation: 4,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border.fromBorderSide(BorderSide(color: const Color(0xff999999))),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xffdedcd5)),
              ),
            ),
            child: Padding(
              padding: padding,
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  static Future<T?> open<T>({
    required BuildContext context,
    required Widget content,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8),
    Color barrierColor = const Color(0x80000000),
    bool barrierDismissible = false,
  }) {
    return DialogTracker<T>().open(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      child: Sheet(
        padding: padding,
        content: content,
      ),
    );
  }
}

class Prompt extends StatelessWidget {
  const Prompt({
    Key? key,
    required this.messageType,
    required this.message,
    required this.body,
    this.options = const <String>[],
    this.selectedOption,
  }) : super(key: key);

  final MessageType messageType;
  final String message;
  final Widget body;
  final List<String> options;
  final int? selectedOption;

  void _setSelectedOption(BuildContext context, int index) {
    Navigator.of(context)!.pop<int>(index);
  }

  @override
  Widget build(BuildContext context) {
    return Sheet(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
              border: Border.all(
                color: const Color(0xff999999),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(13),
              child: SizedBox(
                width: 280,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    messageType.toImage(),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 11),
                              child: body,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(options.length, (int index) {
                return Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: CommandPushButton(
                    onPressed: () => _setSelectedOption(context, index),
                    label: options[index],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  static Future<int> open({
    required BuildContext context,
    required MessageType messageType,
    required String message,
    required Widget body,
    List<String> options = const <String>[],
    int? selectedOption,
  }) async {
    final int? result = await DialogTracker<int>().open(
      context: context,
      barrierDismissible: false,
      child: Prompt(
        messageType: messageType,
        message: message,
        body: body,
        options: options,
        selectedOption: selectedOption,
      ),
    );
    return result!;
  }
}

/// Tracks the open/close animation of a dialog, allowing callers to open a
/// dialog and get notified when the dialog fully closes (closing animation
/// completes) rather than simply when the modal route is popped (closing
/// animation starts)
@visibleForTesting
class DialogTracker<T> {
  final Completer<T?> _completer = Completer<T?>();

  Animation<double>? _animation;
  bool _isDialogClosing = false;
  _AsyncResult<T>? _result;

  Future<T?> open({
    required BuildContext context,
    bool barrierDismissible = true,
    String barrierLabel = 'Dismiss',
    Color barrierColor = const Color(0x80000000),
    required Widget child,
  }) {
    final ThemeData theme = Theme.of(context);
    showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return Theme(
          data: theme,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        assert(_animation == null || _animation == animation);
        if (_animation == null) {
          _animation = animation;
          animation.addStatusListener(_handleAnimationStatusUpdate);
        }
        return Align(
          alignment: Alignment.topCenter,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, -1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        );
      },
    ).then((T? value) {
      _result = _AsyncResult<T>.value(value);
    }).catchError((dynamic error, StackTrace stack) {
      _result = _AsyncResult<T>.error(error, stack);
    });
    return _completer.future;
  }

  void _handleAnimationStatusUpdate(AnimationStatus status) {
    if (!_isDialogClosing && status == AnimationStatus.reverse) {
      _isDialogClosing = true;
    }
    if (_isDialogClosing && status == AnimationStatus.dismissed) {
      assert(_result != null);
      assert(!_completer.isCompleted);
      _isDialogClosing = false;
      _animation!.removeStatusListener(_handleAnimationStatusUpdate);
      _animation = null;
      _result!.complete(_completer);
    }
  }
}

class _AsyncResult<T> {
  const _AsyncResult.value(this.value)
      : error = null,
        stack = null;

  const _AsyncResult.error(Object this.error, StackTrace this.stack) : value = null;

  final T? value;
  final Object? error;
  final StackTrace? stack;

  void complete(Completer<T?> completer) {
    if (error != null) {
      completer.completeError(error!, stack);
    } else {
      completer.complete(value);
    }
  }
}
