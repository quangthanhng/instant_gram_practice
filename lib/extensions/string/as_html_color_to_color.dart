// convert #0x????? or #????? to Color
import 'package:flutter/material.dart';
import 'package:instagram_clone_qthanh/extensions/string/remove_all.dart';

extension AsHtmlColorToColor on String {
  Color htmlColorToColor() =>
      Color(int.parse(removeAll(['0x', '#']).padLeft(8, 'ff'), radix: 16));
}
// padLeft là một function cho phép thêm vào chuỗi truyền vào cho đủ 8 số bằng cách thêm ff vào bên trái cho đủ số lượng 
// radix là một hệ số của hàm int.parse cho phép thông báo rằng đối tượng cần chuyển là một hệ số thập lục phân 
// radix là 2: nhị phân (binary)
// radix là 8: bát phân (octal)
// radix là 10: Thập phân (decimal)
// radix là 16: Thập lục phân (hex)