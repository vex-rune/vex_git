/// 纯 Dart 实现的行级 diff 算法，用于对比文件变更
class DiffLine {
  final int oldLineNo;
  final int newLineNo;
  final String content;
  final DiffType type;

  const DiffLine({
    required this.oldLineNo,
    required this.newLineNo,
    required this.content,
    required this.type,
  });
}

enum DiffType { context, added, removed }

/// 计算两段文本的行级差异
List<DiffLine> computeDiff(String oldText, String newText) {
  final oldLines = oldText.split('\n');
  final newLines = newText.split('\n');

  // 使用 LCS 算法找到最长公共子序列
  final lcs = _buildLCS(oldLines, newLines);

  final result = <DiffLine>[];
  var oldIdx = 0;
  var newIdx = 0;
  var lcsIdx = 0;
  var oldLineNo = 1;
  var newLineNo = 1;

  while (oldIdx < oldLines.length || newIdx < newLines.length) {
    if (lcsIdx < lcs.length &&
        oldIdx < oldLines.length &&
        newIdx < newLines.length &&
        oldLines[oldIdx] == lcs[lcsIdx] &&
        newLines[newIdx] == lcs[lcsIdx]) {
      // 公共行（上下文）
      result.add(DiffLine(
        oldLineNo: oldLineNo++,
        newLineNo: newLineNo++,
        content: oldLines[oldIdx],
        type: DiffType.context,
      ));
      oldIdx++;
      newIdx++;
      lcsIdx++;
    } else if (oldIdx < oldLines.length &&
        (lcsIdx >= lcs.length || oldLines[oldIdx] != lcs[lcsIdx])) {
      // 被删除的行
      result.add(DiffLine(
        oldLineNo: oldLineNo++,
        newLineNo: 0,
        content: oldLines[oldIdx],
        type: DiffType.removed,
      ));
      oldIdx++;
    } else if (newIdx < newLines.length &&
        (lcsIdx >= lcs.length || newLines[newIdx] != lcs[lcsIdx])) {
      // 新增的行
      result.add(DiffLine(
        oldLineNo: 0,
        newLineNo: newLineNo++,
        content: newLines[newIdx],
        type: DiffType.added,
      ));
      newIdx++;
    } else {
      break;
    }
  }

  return result;
}

/// 构建 LCS（最长公共子序列）
List<String> _buildLCS(List<String> a, List<String> b) {
  final m = a.length;
  final n = b.length;

  // 优化：对大文件限制比较行数
  final maxLines = 2000;
  final effectiveM = m > maxLines ? maxLines : m;
  final effectiveN = n > maxLines ? maxLines : n;

  // dp[i][j] 表示 a[0..i-1] 和 b[0..j-1] 的 LCS 长度
  final dp = List.generate(effectiveM + 1, (_) => List.filled(effectiveN + 1, 0));

  for (var i = 1; i <= effectiveM; i++) {
    for (var j = 1; j <= effectiveN; j++) {
      if (a[i - 1] == b[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
      } else {
        dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
      }
    }
  }

  // 回溯构建 LCS
  final lcs = <String>[];
  var i = effectiveM;
  var j = effectiveN;
  while (i > 0 && j > 0) {
    if (a[i - 1] == b[j - 1]) {
      lcs.add(a[i - 1]);
      i--;
      j--;
    } else if (dp[i - 1][j] > dp[i][j - 1]) {
      i--;
    } else {
      j--;
    }
  }

  return lcs.reversed.toList();
}
