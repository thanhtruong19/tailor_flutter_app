# Phạm vi dự án Tailor App

## Mục tiêu

Xây dựng ứng dụng Flutter bán quần áo trong 5 ngày. Ứng dụng kết nối với backend PHP hiện tại qua API để lấy sản phẩm, tạo đơn hàng và cập nhật trạng thái đơn hàng.

## Tính năng phía khách hàng

- Xem danh sách sản phẩm.
- Xem chi tiết sản phẩm.
- Chọn size và số lượng.
- Thêm sản phẩm vào giỏ hàng.
- Xóa sản phẩm khỏi giỏ hàng.
- Tăng hoặc giảm số lượng sản phẩm trong giỏ hàng.
- Xem tổng tiền đơn hàng.
- Nhập thông tin nhận hàng.
- Đặt hàng COD.
- Xem danh sách đơn hàng.
- Xem chi tiết và trạng thái đơn hàng.

## Tính năng phía admin

- Đăng nhập admin.
- Xem danh sách đơn hàng.
- Xem chi tiết đơn hàng.
- Lọc đơn hàng theo trạng thái.
- Duyệt đơn hàng.
- Từ chối đơn hàng.

## Kết nối backend

Ứng dụng Flutter sử dụng API của backend PHP hiện tại để:

- Lấy dữ liệu sản phẩm.
- Tạo đơn hàng mới.
- Lấy danh sách và chi tiết đơn hàng.
- Cập nhật trạng thái đơn hàng.

## Luồng demo chính

Khách chọn sản phẩm → thêm vào giỏ hàng → đặt hàng → admin nhận đơn → admin duyệt hoặc từ chối → khách xem trạng thái mới.

## Ngoài phạm vi bản 5 ngày

- Thanh toán online.
- Tích hợp đơn vị vận chuyển.
- Mã giảm giá.
- Đánh giá sản phẩm.
- Quản lý sản phẩm từ phía admin.

## Nguyên tắc phát triển

- Ưu tiên hoàn thành luồng demo chính trước.
- Không tự ý bổ sung chức năng ngoài phạm vi bản 5 ngày.
- Giao diện chỉ cần rõ ràng, nhất quán và đủ để demo.
- Các chức năng phải sử dụng API PHP hiện tại, không thay đổi backend nếu chưa được yêu cầu.
