import 'dart:collection';
import 'dart:math';
import 'package:urnicar/data/timetable/timetable_scraper.dart';

class TimetableOptimiser {
  static List<List<Lecture>> minimiseOverlap(List<Lecture> rawTimetable) {
    final subjectsMap = <String, List<Lecture>>{};
    final timetable = List<List<Lecture>>.filled(5, []);

    for (final lecture in rawTimetable) {
      if (lecture.type == LectureType.lecture) {
        timetable[lecture.day.value].add(lecture);
        continue;
      }

      if (subjectsMap[lecture.subject.id] == null) {
        subjectsMap[lecture.subject.id] = [];
      }

      subjectsMap[lecture.subject.id]?.add(lecture);
    }


    int bestOverlap = 99999;
    List<List<Lecture>> bestTimetables = [];
    for (final lectures in _allCombinations(subjectsMap.values.toList())) {
      final testTimetable = List<List<Lecture>>.filled(5, []);

      // deep-ish copy (if we were to change data from individual lectures
      // this needs to be changed)
      for (int i = 0; i < 5; i++) {
        testTimetable[i] = List.from(timetable[i]);
      }
      
      for (Lecture lecture in lectures) {
        testTimetable[lecture.day.value] = lectures;
      }

      final int overlap = _getOverlap(testTimetable); 
      if (overlap < bestOverlap) {
        bestOverlap = overlap;
        bestTimetables = [];
        bestTimetables.add([for (var list in testTimetable) ...list]);
        continue;
      }
      if (overlap == bestOverlap) {
        bestTimetables.add([for (var list in testTimetable) ...list]);
      }
    }

    return bestTimetables;
  }

  static List<List<Lecture>> minimiseOverlapAndGap(List<Lecture> rawTimetable) {
    final subjectsMap = <String, List<Lecture>>{};
    final timetable = List<List<Lecture>>.filled(5, []);

    for (final lecture in rawTimetable) {
      if (lecture.type == LectureType.lecture) {
        timetable[lecture.day.value].add(lecture);
        continue;
      }

      if (subjectsMap[lecture.subject.id] == null) {
        subjectsMap[lecture.subject.id] = [];
      }

      subjectsMap[lecture.subject.id]?.add(lecture);
    }


    int bestOverlap = 99999;
    int bestGap = 99999;
    List<List<Lecture>> bestTimetables = [];
    for (final lectures in _allCombinations(subjectsMap.values.toList())) {
      final testTimetable = List<List<Lecture>>.filled(5, []);

      // deep-ish copy (if we were to change data from individual lectures
      // this needs to be changed)
      for (int i = 0; i < 5; i++) {
        testTimetable[i] = List.from(timetable[i]);
      }
      
      for (Lecture lecture in lectures) {
        testTimetable[lecture.day.value] = lectures;
      }

      final (overlap, gap) = _getOverlapAndGap(testTimetable); 
      if (overlap < bestOverlap) {
        bestOverlap = overlap;
        bestGap = gap;
        bestTimetables = [];
        bestTimetables.add([for (var list in testTimetable) ...list]);
        continue;
      }
      if (overlap == bestOverlap) {
        if (gap < bestGap) {
          bestGap = gap;
          bestTimetables = [];
          bestTimetables.add([for (var list in testTimetable) ...list]);
          continue;
        }
        if (gap == bestGap) {
          bestTimetables.add([for (var list in testTimetable) ...list]);
        }
      }
    }

    return bestTimetables;
  }

  static List<List<Lecture>> _allCombinations(List<List<Lecture>> lists) {
    if (lists.isEmpty) return [];

    List<List<Lecture>> result = [[]];

    for (final list in lists) {
      final newResult = <List<Lecture>>[];

      for (final combination in result) {
        for (final item in list) {
          newResult.add([...combination, item]);
        }
      }

      result = newResult;
    }

    return result;
  }

  static int _getOverlap(List<List<Lecture>> timetable) {
    int overlap = 0;

    for (final dayTimetable in timetable) {
      for (int i = 0; i < dayTimetable.length; i++) {
        for (int j = i + 1; j < dayTimetable.length; j++) {
          final a = dayTimetable[i];
          final b = dayTimetable[j];

          overlap += max(0, min(a.time.end, b.time.end) - max(a.time.start, b.time.start));
        }
      }
    }

    return overlap;
  }

  static (int, int) _getOverlapAndGap(List<List<Lecture>> timetable) {
    int overlap = 0;
    int gap = 0;
    bool addAB = true;

    for (final dayTimetable in timetable) {
      final intervals = HashSet<(int, int)>();
      for (final lecture in dayTimetable) {
        int a = lecture.time.start;
        int b = lecture.time.end;
        for (final (c, d) in HashSet<(int, int)>.from(intervals)) {
          if (d < a || b < c) {
            continue;
          }
          if (c <= a && b <= d) {
            addAB = false;
            overlap += lecture.time.duration;
            break;
          }

          max(0, min(b, d) - max(a, c));
          intervals.remove((c, d));
          a = min(a, c);
          b = max(b, d);
        }

        if (addAB) {
          intervals.add((a, b));
        }
      }

      final sorted = intervals.toList();
      sorted.sort((a, b) => a.$1.compareTo(b.$1));
      for (int i = 0; i < sorted.length - 1; i++) {
        gap += sorted[i + 1].$1 - sorted[i].$2;
      }
    }
    return (overlap, gap);
  }

}