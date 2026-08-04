# Bản nháp Chính sách quyền riêng tư (Tiếng Việt) — Smart Voice Alarm

**Trạng thái:** BẢN NHÁP — chưa công bố. Chủ ứng dụng phải duyệt nội dung và ngày hiệu lực trước khi đưa lên hosting.

**Ngày hiệu lực:** `[CHỦ ỨNG DỤNG XÁC NHẬN]`

**Ứng dụng:** Smart Voice Alarm  
**Tên nhà phát triển công khai trên Google Play:** Nguyên Đức  
**Liên hệ:** timeforwork789@gmail.com  

Bản nháp dựa trên `docs/privacy_data_audit.md` và hành vi hiện tại của mã nguồn. Đây không phải tư vấn pháp lý.

---

## 1. Chúng tôi là ai

Smart Voice Alarm là ứng dụng giúp bạn đặt báo thức và phát chuỗi giọng nói trên thiết bị.

Trên Google Play, tên nhà phát triển công khai là **Nguyên Đức**.

Mọi câu hỏi về quyền riêng tư, gửi tới: **timeforwork789@gmail.com**.

## 2. Phạm vi

Chính sách này mô tả cách Smart Voice Alarm xử lý thông tin khi bạn dùng ứng dụng Android (và các bản build liên quan của cùng sản phẩm). Dịch vụ cửa hàng (Google Play) có chính sách riêng.

## 3. Thông tin ứng dụng truy cập hoặc xử lý

Tùy cách bạn dùng ứng dụng, Smart Voice Alarm có thể xử lý:

- Lịch báo thức bạn tạo (giờ, lặp lại, nhãn, loại báo thức)
- Nội dung chuỗi giọng nói và giọng TTS hệ thống bạn chọn
- Âm thanh bạn ghi để làm đoạn giọng tùy chỉnh (micro)
- Tùy chọn ứng dụng (giao diện, ngôn ngữ, nhắc nhở)
- Trạng thái quyền thông báo và báo thức chính xác
- Trạng thái dùng thử bảy ngày cục bộ và quyền lợi gói đăng ký năm (xử lý qua Google Play Billing)

Ứng dụng **không** có tài khoản trong app, đăng nhập, hay hồ sơ đám mây.

## 4. Thông tin lưu trên thiết bị

Các dữ liệu sau được lưu cục bộ trên thiết bị (ví dụ cơ sở dữ liệu trên máy, preferences và tệp cục bộ):

- Báo thức và cài đặt liên quan
- Chuỗi giọng nói và bản ghi bạn tạo
- Theme, ngôn ngữ và nhắc nhở
- Trạng thái Premium cục bộ theo API cửa hàng

Xóa dữ liệu ứng dụng hoặc gỡ cài đặt sẽ xóa dữ liệu cục bộ, tùy cách thiết bị và Google Play xử lý lưu trữ và giao dịch mua.

## 5. Thông tin có thể rời khỏi thiết bị

Theo rà soát mã nguồn hiện tại:

- Ứng dụng **không** tích hợp Firebase, SDK phân tích, SDK báo cáo sự cố, SDK quảng cáo, hay máy chủ riêng để tải lên nội dung báo thức.
- Khi mua hoặc khôi phục Premium, Google Play Billing xử lý giao dịch theo chính sách của Google.
- Khi bạn mở Hỗ trợ, ứng dụng email trên thiết bị có thể gửi thư bạn soạn tới timeforwork789@gmail.com. Các trường chẩn đoán có thể điền sẵn (phiên bản, nền tảng) **không** gồm nội dung báo thức hay định danh cá nhân ngoài những gì bạn tự viết.
- Khi bạn mở liên kết (GitHub hoặc trang chính sách/hỗ trợ đã host), trình duyệt hoặc hệ thống sẽ tải trang đó.
- Google Play Billing trả về metadata sản phẩm, trạng thái mua và token giao dịch cần cho xác minh quyền lợi phía client. Mã ứng dụng không nhận dữ liệu thẻ và không ghi log token.

Chính sách này **không** tuyên bố ứng dụng không bao giờ gửi dữ liệu ra ngoài thiết bị. Dịch vụ nền tảng và việc tải font (nếu xảy ra) có thể tạo hoạt động mạng.

## 6. Quyền Android và mục đích

| Quyền / khả năng | Mục đích |
|------------------|----------|
| Thông báo | Hiển thị thông báo báo thức và nhắc nhở |
| Báo thức chính xác | Kích hoạt đúng giờ đã đặt |
| Dịch vụ nền (phát media) | Duy trì phát âm thanh báo thức |
| Khởi động lại thiết bị | Lên lịch lại báo thức sau khi reboot |
| Wake lock / rung / full-screen intent | Tăng độ tin cậy và khả năng chú ý |
| Micro | Ghi âm đoạn giọng tùy chọn |

Bạn có thể từ chối quyền tùy chọn; độ tin cậy báo thức có thể giảm nếu thiếu quyền thông báo hoặc báo thức chính xác.

## 7. Dịch vụ bên thứ ba

Ứng dụng có thể tương tác với:

- **Google Play / Play Billing** — phân phối và mua trong ứng dụng
- **Công cụ TTS trên thiết bị** — đọc nội dung bằng giọng đã cài
- **API thông báo và báo thức của hệ điều hành**
- **GitHub** (nếu bạn mở liên kết kho mã nguồn)

Các dịch vụ này tuân theo điều khoản và chính sách riêng của họ.

## 8. Lưu trữ và xóa

- Dữ liệu cục bộ nằm trên thiết bị cho đến khi bạn xóa (xóa dữ liệu / gỡ app) hoặc chỉnh sửa trong ứng dụng.
- Email gửi tới hỗ trợ được giữ trong phạm vi cần thiết để phản hồi.
- Hồ sơ mua hàng do Google giữ theo chính sách Play.

Không có tài khoản đám mây trong app để xóa. Yêu cầu “xóa tài khoản ứng dụng” không áp dụng khi không tồn tại tài khoản đó.

## 9. Trẻ em

Smart Voice Alarm là tiện ích dành cho đối tượng chung, không hướng tới trẻ em dưới 13 tuổi. Không dùng ứng dụng để gửi thông tin cá nhân của trẻ. Câu trả lời đối tượng mục tiêu và xếp hạng nội dung trên Play do chủ ứng dụng xác nhận.

## 10. Bảo mật

Ứng dụng dùng lưu trữ trên thiết bị do hệ điều hành cung cấp và các API nền tảng thông dụng. Không có phương thức lưu trữ hay truyền tải nào bảo mật tuyệt đối.

## 11. Thay đổi chính sách

Chúng tôi có thể cập nhật Chính sách quyền riêng tư. Khi URL công khai được xuất bản, ngày hiệu lực sẽ được cập nhật. Bạn nên xem bản mới nhất trên trang đã host.

## 12. Liên hệ

Email: **timeforwork789@gmail.com**  
Tên nhà phát triển công khai Android: **Nguyên Đức**

## 13. Ghi chú hosting (không phải phần chính sách công bố)

Kế hoạch dự kiến: kho GitHub Pages riêng (tên đề xuất `smart-voice-alarm-legal`) với:

- `/index.html`
- `/privacy-policy/index.html`
- `/support/index.html`

**URL Chính sách quyền riêng tư công khai:** `https://tom-deptrai.github.io/smart-voice-alarm-legal/privacy-policy/` (HTTPS đang hoạt động)

Kho pháp lý, GitHub Pages và URL trong ứng dụng đã được cấu hình.
