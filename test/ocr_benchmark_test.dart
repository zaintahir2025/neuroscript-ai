// Unit tests for Character Error Rate (CER) and Word Error Rate (WER) metrics.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

/// Computes standard Levenshtein edit distance between two strings.
int editDistance(String s1, String s2) {
  final d = List.generate(s1.length + 1, (i) => List.filled(s2.length + 1, 0));

  for (var i = 0; i <= s1.length; i++) {
    d[i][0] = i;
  }
  for (var j = 0; j <= s2.length; j++) {
    d[0][j] = j;
  }

  for (var i = 1; i <= s1.length; i++) {
    for (var j = 1; j <= s2.length; j++) {
      final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
      d[i][j] = [
        d[i - 1][j] + 1, // deletion
        d[i][j - 1] + 1, // insertion
        d[i - 1][j - 1] + cost, // substitution
      ].reduce(min);
    }
  }

  return d[s1.length][s2.length];
}

/// Computes Character Error Rate (CER) = EditDistance(ref, hyp) / Length(ref)
double calculateCer(String reference, String hypothesis) {
  if (reference.isEmpty) return hypothesis.isEmpty ? 0.0 : 1.0;
  return editDistance(reference, hypothesis) / reference.length;
}

/// Computes Word Error Rate (WER) = WordEditDistance(refWords, hypWords) / Count(refWords)
double calculateWer(String reference, String hypothesis) {
  final refWords = reference.trim().split(RegExp(r'\s+'));
  final hypWords = hypothesis.trim().split(RegExp(r'\s+'));

  if (refWords.isEmpty) return hypWords.isEmpty ? 0.0 : 1.0;

  final d = List.generate(
    refWords.length + 1,
    (i) => List.filled(hypWords.length + 1, 0),
  );

  for (var i = 0; i <= refWords.length; i++) {
    d[i][0] = i;
  }
  for (var j = 0; j <= hypWords.length; j++) {
    d[0][j] = j;
  }

  for (var i = 1; i <= refWords.length; i++) {
    for (var j = 1; j <= hypWords.length; j++) {
      final cost = refWords[i - 1] == hypWords[j - 1] ? 0 : 1;
      d[i][j] = [
        d[i - 1][j] + 1,
        d[i][j - 1] + 1,
        d[i - 1][j - 1] + cost,
      ].reduce(min);
    }
  }

  return d[refWords.length][hypWords.length] / refWords.length;
}

void main() {
  group('OCR Evaluation Metrics Unit Tests (CER & WER)', () {
    test('Identical strings yield exactly 0.0 CER and 0.0 WER', () {
      const text = 'The mitochondria is the powerhouse of the cell.';
      expect(calculateCer(text, text), equals(0.0));
      expect(calculateWer(text, text), equals(0.0));
    });

    test('Single character substitution computes expected CER', () {
      const ref = 'cat';
      const hyp = 'cot'; // 1 substitution out of 3 chars -> 1/3
      expect(calculateCer(ref, hyp), closeTo(1.0 / 3.0, 0.001));
    });

    test('Single character insertion and deletion compute expected CER', () {
      const ref = 'test';
      const hypInsert = 'tests'; // 1 insertion out of 4 -> 0.25
      const hypDelete = 'tes'; // 1 deletion out of 4 -> 0.25
      expect(calculateCer(ref, hypInsert), equals(0.25));
      expect(calculateCer(ref, hypDelete), equals(0.25));
    });

    test('Single word substitution computes expected WER', () {
      const ref = 'red green blue';
      const hyp = 'red yellow blue'; // 1 word substitution out of 3 -> 1/3
      expect(calculateWer(ref, hyp), closeTo(1.0 / 3.0, 0.001));
    });

    test('Single word insertion and deletion compute expected WER', () {
      const ref = 'one two three';
      const hypInsert = 'one two three four'; // 1 insertion out of 3 -> 1/3
      const hypDelete = 'one two'; // 1 deletion out of 3 -> 1/3
      expect(calculateWer(ref, hypInsert), closeTo(1.0 / 3.0, 0.001));
      expect(calculateWer(ref, hypDelete), closeTo(1.0 / 3.0, 0.001));
    });

    test('Empty reference handling edge cases', () {
      expect(calculateCer('', ''), equals(0.0));
      expect(calculateCer('', 'abc'), equals(1.0));
      expect(calculateWer('', ''), equals(0.0));
      expect(calculateWer('', 'word'), equals(1.0));
    });
  });
}
