# Giải Thích Cơ Chế Định Tuyến (Routing) Trong Flutter & Quét Ảnh Cây Trồng Với Xoay Vòng Gemini API Key

Tài liệu này giải thích chi tiết hai thành phần kỹ thuật quan trọng trong dự án **Plant Notebook**:
1. **Cơ chế định tuyến (Routing)** trong ứng dụng di động Flutter.
2. **Tính năng gọi API Gemini** để quét ảnh và **cơ chế xoay vòng tự động (API Key Rotation)** dưới Backend.

---

## PHẦN 1: CƠ CHẾ ĐỊNH TUYẾN (ROUTING) TRONG FLUTTER

Ứng dụng Flutter sử dụng cơ chế định tuyến động tập trung qua thuộc tính `onGenerateRoute` của `MaterialApp`. Cách tiếp cận này giúp quản lý route rõ ràng, dễ dàng truyền dữ liệu qua lại giữa các màn hình và tích hợp điều hướng từ thông báo đẩy (push notifications).

### 1.1. Cấu trúc thư mục định tuyến
Hệ thống định tuyến được tổ chức trong thư mục `lib/routes/` bao gồm:
*   [route_constant.dart](file:///d:/Mobile/Plant-Notebook/lib/routes/route_constant.dart): Định nghĩa các hằng số chuỗi đại diện cho tên route để tránh lỗi chính tả (hardcode).
*   [route.dart](file:///d:/Mobile/Plant-Notebook/lib/routes/route.dart): Triển khai logic điều hướng và chuyển trang dựa trên tên route nhận được.
*   [view_export.dart](file:///d:/Mobile/Plant-Notebook/lib/routes/view_export.dart): Gom nhóm xuất các widget màn hình (Screens/Views) để import ngắn gọn.

---

### 1.2. Định nghĩa hằng số Route (`route_constant.dart`)
Tất cả các định danh route được lưu trữ dưới dạng hằng số:
```dart
const String splashViewRoute = "splash";
const String onboardingViewRoute = "onboarding";
const String loginViewRoute = "login";
const String registerViewRoute = "register";
const String appViewRoute = "app";
const String homeViewRoute = "home";
const String myGardenViewRoute = "garden";
const String plantDetailViewRoute = "plant_detail";
const String scannerViewRoute = "scanner";
const String libraryViewRoute = "library";
const String profileViewRoute = "profile";
const String storeMapRoute = "store_map";
const String storeDetailRoute = "store_detail";
```

---

### 1.3. Bộ sinh tuyến đường (`route.dart`)
Hàm `generateRoute` đóng vai trò là một bộ điều phối (dispatcher). Nó nhận `RouteSettings` (chứa tên route và tham số đi kèm) và trả về một `Route<dynamic>` (thường là `MaterialPageRoute` để có hiệu ứng chuyển cảnh chuẩn platform):

```dart
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case splashViewRoute:
      return MaterialPageRoute(builder: (context) => const SplashScreen());
    case onboardingViewRoute:
      return MaterialPageRoute(builder: (context) => const OnboardingScreen());
    case loginViewRoute:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
      
    // Trường hợp Route yêu cầu truyền dữ liệu (Arguments)
    case plantDetailViewRoute:
      final profile = settings.arguments;
      if (profile is GardenPlantProfile) {
        return MaterialPageRoute(
          builder: (context) => PlantDetailScreen(profile: profile),
        );
      }
      return MaterialPageRoute(builder: (context) => const MyGardenScreen());
      
    case storeDetailRoute:
      final String storeId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => StoreDetailScreen(storeId: storeId),
      );
      
    default:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
  }
}
```

---

### 1.4. Đăng ký Route vào ứng dụng (`main.dart`)
Hàm định tuyến được liên kết trực tiếp trong Widget `MaterialApp` ở [main.dart](file:///d:/Mobile/Plant-Notebook/lib/main.dart):
```dart
MaterialApp(
  navigatorKey: navigatorKey, // Global key dùng để điều hướng không cần BuildContext (như từ FCM)
  debugShowCheckedModeBanner: false,
  themeMode: profileController.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
  
  onGenerateRoute: router.generateRoute, // Liên kết bộ sinh tuyến đường
  initialRoute: splashViewRoute,        // Tuyến đường khởi chạy đầu tiên
);
```

---

### 1.5. Cách thực hiện chuyển trang trong Source Code
Khi lập trình viên muốn chuyển màn hình, họ gọi các phương thức tĩnh của lớp `Navigator` cùng với hằng số tuyến đường:

1.  **Chuyển sang màn hình mới (Push):**
    ```dart
    Navigator.pushNamed(context, storeDetailRoute, arguments: store.id);
    ```
2.  **Thay thế màn hình hiện tại (Replace - dùng khi Đăng nhập/Đăng xuất thành công):**
    ```dart
    Navigator.pushReplacementNamed(context, loginViewRoute);
    ```
3.  **Xóa sạch Stack điều hướng và chuyển trang (thường dùng khi Reset App):**
    ```dart
    Navigator.pushNamedAndRemoveUntil(context, appViewRoute, (route) => false);
    ```

---
---

## PHẦN 2: TÍNH NĂNG QUÉT ẢNH GEMINI & CƠ CHẾ XOAY VÒNG API KEY

Để hỗ trợ người dùng nhận dạng thực vật và chẩn đoán bệnh trạng miễn phí mà không lo bị quá tải giới hạn lượt gọi (Rate Limit) của gói API Free từ Google, hệ thống triển khai cơ chế **xoay vòng khóa (API Key Rotation)** tự động ở Backend Node.js.

### 2.1. Quy trình gọi API quét ảnh cây trồng
```mermaid
sequenceDiagram
    participant Mobile as Flutter Client
    participant Server as Express Backend
    participant DB as PostgreSQL Database
    participant Gemini as Google Gemini API

    Mobile->>Server: POST /library-plants/scan (Gửi file ảnh)
    Server->>DB: Lấy danh sách API Key khả dụng (isActive=true, isBanned=false)
    DB-->>Server: Trả về danh sách xếp theo lastUsed ASC
    loop Thử từng API Key trong danh sách
        Server->>Gemini: POST generateContent?key=API_KEY (Base64 Image + Prompt)
        alt Gọi thành công
            Gemini-->>Server: Trả về kết quả JSON
            Server->>DB: Cập nhật usedToday + 1, lastUsed = Now
            Server-->>Mobile: HTTP 200 (Trả kết quả phân tích về)
        alt Bị lỗi Rate Limit (429)
            Gemini-->>Server: Lỗi HTTP 429
            Server->>DB: Cập nhật cooldownUntil = Now + 30s
            Note over Server: Chuyển sang thử API Key tiếp theo
        alt Bị lỗi Ban/Khóa Key (403/400)
            Gemini-->>Server: Lỗi HTTP 403 / 400
            Server->>DB: Cập nhật isBanned = true
            Note over Server: Chuyển sang thử API Key tiếp theo
        end
    end
```

---

### 2.2. Cấu trúc lưu trữ API Key trong Database
Thông tin các khóa API được quản lý bằng bảng `GeminiKeys` thông qua model Sequelize [gemini_key.js](file:///d:/Mobile/Plant-Notebook-Backend-/models/gemini_key.js):
*   `apiKey`: Chuỗi khóa API Gemini (Độc nhất - unique).
*   `isActive`: Trạng thái bật/tắt thủ công (Boolean, mặc định `true`).
*   `isBanned`: Đánh dấu khóa đã bị Google khóa vĩnh viễn (Boolean, mặc định `false`).
*   `cooldownUntil`: Thời điểm khóa hết hạn tạm khóa (DateTime, mặc định `null`). Khi gặp lỗi Rate Limit, khóa sẽ bị đưa vào thời gian chờ.
*   `dailyRequestLimit`: Giới hạn yêu cầu tối đa trong ngày (mặc định `1500`).
*   `usedToday`: Số lượt gọi đã thực hiện thành công trong ngày.
*   `lastUsed`: Lần cuối cùng khóa này được sử dụng để gọi API thành công.

---

### 2.3. Thuật toán xoay vòng và xử lý lỗi (`gemini_scanner.service.js`)
Toàn bộ logic xoay vòng nằm trong [gemini_scanner.service.js](file:///d:/Mobile/Plant-Notebook-Backend-/services/client/gemini_scanner.service.js).

#### Bước 1: Lấy danh sách API Key khả dụng và sắp xếp xoay vòng
Hệ thống ưu tiên các key không bị cấm, đang hoạt động và không nằm trong thời gian cooldown. Các key được sắp xếp theo thời gian sử dụng xa nhất (`lastUsed` tăng dần) để đảm bảo chia đều tải trọng (Round-Robin):
```javascript
async _getAvailableKeys() {
  return await GeminiKey.findAll({
    where: {
      isActive: true,
      isBanned: false,
      [Op.or]: [
        { cooldownUntil: null },
        { cooldownUntil: { [Op.lt]: new Date() } } // Thời gian chờ đã trôi qua
      ]
    },
    order: [
      ['lastUsed', 'ASC'], // Xoay vòng công bằng: Key dùng lâu nhất lên đầu
      ['id', 'ASC']
    ]
  });
}
```

#### Bước 2: Van an toàn (Safety Valve)
Trường hợp lượng truy cập dồn dập khiến tất cả các key đều bị đưa vào trạng thái cooldown, hệ thống có một cơ chế tự phục hồi tạm thời nhằm giữ kết nối thông suốt:
```javascript
let availableKeys = await this._getAvailableKeys();

if (availableKeys.length === 0) {
  // Reset trạng thái cooldown của toàn bộ key đang hoạt động để thử vận may lại
  console.log('[GeminiScannerService] All keys in cooldown. Resetting cooldowns...');
  await GeminiKey.update({ cooldownUntil: null }, { where: { isBanned: false, isActive: true } });
  availableKeys = await this._getAvailableKeys();
}

if (availableKeys.length === 0) {
  throw new Error('all_ai_keys_rate_limited'); // Báo lỗi hết tài nguyên
}
```

#### Bước 3: Vòng lặp thử nghiệm và Phân loại lỗi
Hệ thống duyệt qua từng key để gửi yêu cầu phân tích ảnh:
```javascript
for (const keyRecord of availableKeys) {
  try {
    const result = await this._callGeminiAPI(keyRecord.apiKey, base64Image, mimeType);
    
    // GỌI THÀNH CÔNG: Tăng lượt dùng trong ngày và cập nhật thời gian
    await keyRecord.update({
      usedToday: keyRecord.usedToday + 1,
      lastUsed: new Date()
    });
    return result; // Ngắt vòng lặp và trả kết quả ngay lập tức
  } catch (err) {
    lastError = err;
    const errMsg = err.message.toLowerCase();
    
    if (this._isBannedError(errMsg)) {
      // 1. Nếu lỗi 403/400 (Key bị khóa hoặc không hợp lệ): Đánh dấu cấm vĩnh viễn
      console.warn(`Key ID ${keyRecord.id} is permanently banned. Marking in DB.`);
      await keyRecord.update({ isBanned: true });
    } else if (this._isRateLimitError(errMsg)) {
      // 2. Nếu lỗi 429 (Đạt giới hạn lượt gọi/giây): Cooldown tạm thời 30 giây
      console.warn(`Key ID ${keyRecord.id} hit rate limit. Cooling down for 30s.`);
      await keyRecord.update({
        cooldownUntil: new Date(Date.now() + 30 * 1000)
      });
    } else {
      // 3. Lỗi mạng hoặc lỗi kết nối chung: Cooldown tạm thời 10 giây
      console.warn(`Key ID ${keyRecord.id} encountered generic error.`);
      await keyRecord.update({
        cooldownUntil: new Date(Date.now() + 10 * 1000)
      });
    }
  }
}
```

---

### 2.4. Tính năng quản lý từ phía Admin
Bên cạnh cơ chế tự động, quản trị viên có quyền kiểm soát tuyệt đối thông qua bảng điều khiển Web Admin:
1.  **Xem danh sách:** Kiểm tra tham số `usedToday`, `isBanned`, `cooldownUntil` trực quan của từng khóa.
2.  **Thêm/Xóa/Sửa:** Dễ dàng bổ sung key mới hoặc hủy kích hoạt các key bị lỗi.
3.  **Tính năng Ping (Health Check):** Khi Admin nhấn nút "Ping" trên giao diện Admin, backend sẽ chạy hàm `pingKey()` để kiểm tra trạng thái hoạt động thực của API key qua Google API (`countTokens`).
    *   Nếu Ping thành công: Trạng thái key được khôi phục về bình thường (`isBanned = false`, `cooldownUntil = null`).
    *   Nếu Ping thất bại: Tự động phân loại lỗi để đánh dấu ban hoặc cooldown tương thích trên Database mà không cần chờ người dùng di động quét lỗi.
