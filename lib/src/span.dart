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
import 'dart:ui' show hashValues;

import 'foundation.dart';

/// Class representing a range of integer values. The range includes all
/// values in the interval `[start, end]`. Values may be negative, and the
/// value of [start] may be less than, equal to, or greater than the value
/// of [end].
class Span {
  const Span(this.start, this.end);

  const Span.single(this.start)
      : end = start;

  Span.normalized(int start, int end)
      : this.start = math.min(start, end),
        this.end = math.max(start, end);

  final int start;
  final int end;

  Span copyWith({int? start, int? end}) {
    return Span(
      start ?? this.start,
      end ?? this.end,
    );
  }

  int get length => (end - start).abs() + 1;

  bool contains(Span span) {
    final Span normalizedSpan = span.normalize();
    if (start < end) {
      return start <= normalizedSpan.start && end >= normalizedSpan.end;
    } else {
      return end <= normalizedSpan.start && start >= normalizedSpan.end;
    }
  }

  bool intersects(Span span) {
    final Span normalizedSpan = span.normalize();
    if (start < end) {
      return start <= normalizedSpan.end && end >= normalizedSpan.start;
    } else {
      return end <= normalizedSpan.end && start >= normalizedSpan.start;
    }
  }

  Span? intersect(Span span) {
    return intersects(span) ? Span(math.max(start, span.start), math.min(end, span.end)) : null;
  }

  Span union(Span span) {
    return Span(math.min(start, span.start), math.max(end, span.end));
  }

  /// Returns a span with the same range as this span but in which [start] is
  /// guaranteed to be less than or equal to [end].
  Span normalize() => Span(math.min(start, end), math.max(start, end));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Span && other.start == start && other.end == end;
  }

  @override
  int get hashCode => hashValues(start, end);

  @override
  String toString() => '$runtimeType(start=$start,end=$end)';
}

class ListSelection {
  List<Span> _ranges = <Span>[];

  /// Comparator that determines the index of the first intersecting range.
  int _compareStart(Span a, Span b) => a.end - b.start;

  /// Comparator that determines the index of the last intersecting range.
  int _compareEnd(Span a, Span b) => a.start - b.end;

  /// Comparator that determines if two ranges intersect.
  int _compareIntersection(Span a, Span b) => (a.start > b.end) ? 1 : (b.start > a.end) ? -1 : 0;

  /// Adds a range to this list, merging and removing intersecting ranges as
  /// needed.
  List<Span> addRange(int start, int end) {
    List<Span> addedRanges = <Span>[];

    Span range = Span.normalized(start, end);
    assert(range.start >= 0);

    int n = _ranges.length;

    if (n == 0) {
      // The selection is currently empty; append the new range
      // and add it to the added range list
      _ranges.add(range);
      addedRanges.add(range);
    } else {
      // Locate the lower bound of the intersection
      int i = binarySearch<Span>(_ranges, range, compare: _compareStart);
      if (i < 0) {
        i = -(i + 1);
      }

      // Merge the selection with the previous range, if necessary
      if (i > 0) {
        Span previousRange = _ranges[i - 1];
        if (range.start == previousRange.end + 1) {
          i--;
        }
      }

      if (i == n) {
        // The new range starts after the last existing selection
        // ends; append it and add it to the added range list
        _ranges.add(range);
        addedRanges.add(range);
      } else {
        // Locate the upper bound of the intersection
        int j = binarySearch(_ranges, range, compare: _compareEnd);
        if (j < 0) {
          j = -(j + 1);
        } else {
          j++;
        }

        // Merge the selection with the next range, if necessary
        if (j < n) {
          Span nextRange = _ranges[j];
          if (range.end == nextRange.start - 1) {
            j++;
          }
        }

        if (i == j) {
          _ranges.insert(i, range);
          addedRanges.add(range);
        } else {
          // Create a new range representing the union of the intersecting ranges
          Span lowerRange = _ranges[i];
          Span upperRange = _ranges[j - 1];

          range = Span(math.min(range.start, lowerRange.start), math.max(range.end, upperRange.end));

          // Add the gaps to the added list
          if (range.start < lowerRange.start) {
            addedRanges.add(Span(range.start, lowerRange.start - 1));
          }

          for (int k = i; k < j - 1; k++) {
            Span selectedRange = _ranges[k];
            Span nextSelectedRange = _ranges[k + 1];
            addedRanges.add(Span(selectedRange.end + 1, nextSelectedRange.start - 1));
          }

          if (range.end > upperRange.end) {
            addedRanges.add(Span(upperRange.end + 1, range.end));
          }

          // Remove all redundant ranges
          _ranges[i] = range;

          if (i < j) {
            _ranges.removeRange(i + 1, j);
          }
        }
      }
    }

    return addedRanges;
  }

  List<Span> removeRange(int start, int end) {
    List<Span> removedRanges = <Span>[];

    Span range = Span.normalized(start, end);
    assert(range.start >= 0);

    int n = _ranges.length;

    if (n > 0) {
      // Locate the lower bound of the intersection
      int i = binarySearch<Span>(_ranges, range, compare: _compareStart);
      if (i < 0) {
        i = -(i + 1);
      }

      if (i < n) {
        Span lowerRange = _ranges[i];

        if (lowerRange.start < range.start && lowerRange.end > range.end) {
          // Removing the range will split the intersecting selection
          // into two ranges
          _ranges[i] = Span(lowerRange.start, range.start - 1);
          _ranges.insert(i + 1, Span(range.end + 1, lowerRange.end));
          removedRanges.add(range);
        } else {
          Span? leadingRemovedRange;
          if (range.start > lowerRange.start) {
            // Remove the tail of this range
            _ranges[i] = Span(lowerRange.start, range.start - 1);
            leadingRemovedRange = Span(range.start, lowerRange.end);
            i++;
          }

          // Locate the upper bound of the intersection
          int j = binarySearch<Span>(_ranges, range, compare: _compareEnd);
          if (j < 0) {
            j = -(j + 1);
          } else {
            j++;
          }

          if (j > 0) {
            Span upperRange = _ranges[j - 1];

            Span? trailingRemovedRange;
            if (range.end < upperRange.end) {
              // Remove the head of this range
              _ranges[j - 1] = Span(range.end + 1, upperRange.end);
              trailingRemovedRange = Span(upperRange.start, range.end);
              j--;
            }

            // Remove all cleared ranges
            List<Span> clearedRanges = _ranges.sublist(i, j);
            _ranges.removeRange(i, j);

            // Construct the removed range list
            if (leadingRemovedRange != null) {
              removedRanges.add(leadingRemovedRange);
            }

            for (int k = 0, c = clearedRanges.length; k < c; k++) {
              removedRanges.add(clearedRanges[k]);
            }

            if (trailingRemovedRange != null) {
              removedRanges.add(trailingRemovedRange);
            }
          }
        }
      }
    }

    return removedRanges;
  }

  void clear() => _ranges.clear();

  Span operator [](int index) => _ranges[index];

  int get length => _ranges.length;

  bool get isEmpty => length == 0;

  bool get isNotEmpty => length > 0;

  Span get first => _ranges.first;

  Span get last => _ranges.last;

  Iterable<Span> get data => _ranges;

  int indexOf(Span span) {
    final int i = binarySearch<Span>(_ranges, span, compare: _compareIntersection);
    if (i >= 0) {
      return span == _ranges[i] ? i : -1;
    }
    return -1;
  }

  bool containsIndex(int index) {
    final Span span = Span.single(index);
    final int i = binarySearch(_ranges, span, compare: _compareIntersection);
    return (i >= 0);
  }

  /// Inserts an index into the span sequence (e.g. when items are inserted into the model data).
  void insertIndex(int index) {
    // Get the insertion point for the range corresponding to the given index
    Span range = Span.single(index);
    int i = binarySearch(_ranges, range, compare: _compareIntersection);

    if (i < 0) {
      // The inserted index does not intersect with a selected range
      i = -(i + 1);
    } else {
      // The inserted index intersects with a currently selected range
      Span selectedRange = _ranges[i];

      // If the inserted index falls within the current range, increment
      // the endpoint only
      if (selectedRange.start < index) {
        _ranges[i] = Span(selectedRange.start, selectedRange.end + 1);

        // Start incrementing range bounds beginning at the next range
        i++;
      }
    }

    // Increment any subsequent selection indexes
    int n = _ranges.length;
    while (i < n) {
      Span selectedRange = _ranges[i];
      _ranges[i] = Span(selectedRange.start + 1, selectedRange.end + 1);
      i++;
    }
  }

  /// Removes a range of indexes from the span sequence (e.g. when items are removed from the model data).
  void removeIndexes(int index, int count) {
    // Clear any selections in the given range
    removeRange(index, (index + count) - 1);

    // Decrement any subsequent selection indexes
    final Span range = Span.single(index);
    int i = binarySearch(_ranges, range, compare: _compareIntersection);
    assert(i < 0, 'i should be negative, since index should no longer be selected');

    i = -(i + 1);

    // Determine the number of ranges to modify
    int n = _ranges.length;
    while (i < n) {
      Span selectedRange = _ranges[i];
      _ranges[i] = Span(selectedRange.start - count, selectedRange.end - count);
      i++;
    }
  }
}
