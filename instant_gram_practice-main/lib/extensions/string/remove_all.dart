extension RemoveAll on String {
  String removeAll(Iterable<String> values) =>
      values.fold(this, (result, value) => result.replaceAll(value, ''));
}

// extension method trong flutter cho phép thêm function vào trong một class có sẵn mà không cần ké thừa hay sửa đổi class gốc


// Phân tích cú pháp của function removeAll:

// values là một tập hợp các chuỗi(Iterable<String>)
// Ví dụ khi truyền vào: 
// removeAll(['0x', '#']) thì values = ['0x', '#']
// fold là một method duyệt qua từng phần tử và tích lũy kết quả
/** Cấu trúc chuẩn của T fold<T>: 
  T fold<T>(
  T initialValue,
  T Function(T previousValue, E element) combine
)
 */
// this trong đây là chuỗi đang gọi method
// result là kết quả tích lũy được khi loại bỏ dần các kí tự, value là những giá trị cần được loại bỏ và thay thế bằng '' 
