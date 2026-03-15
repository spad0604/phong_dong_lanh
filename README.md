# phong_dong_lanh

Web Flutter (Material 3) giám sát 4 kho lạnh theo thời gian thực:

- Nhiệt độ + độ ẩm realtime (Firebase Realtime Database)
- Vẽ biểu đồ (gần đây)
- Set ngưỡng nhiệt độ/độ ẩm
- Mở/đóng cửa kho
- Tự động bật quạt/điều hòa khi vượt ngưỡng (MVP: chạy trên web client)
- Thủ công bật/tắt quạt/điều hòa (khi tắt chế độ tự động)
- Ghi nhận nhập kho bằng QR/RFID (MVP: nhập mã)

## Chạy Web

1) Cài Flutter SDK.

2) Cài dependencies:

```bash
flutter pub get
```

3) Chạy web:

```bash
flutter run -d chrome
```

## Firebase Realtime Database

### Cấu hình

- Web config hiện được khai báo trong [lib/firebase_options.dart](lib/firebase_options.dart).
- Database URL dùng: `https://phong-dong-lanh-default-rtdb.firebaseio.com`

### Schema đề xuất

App dùng node gốc `warehouses/{warehouseId}`. `warehouseId` hiện dùng: `kho_1`, `kho_2`, `kho_3`, `kho_4`.

Ví dụ cấu trúc dữ liệu:

```json
{
	"warehouses": {
		"kho_1": {
			"sensors": {
				"temperatureC": 6.5,
				"humidityPct": 63.2,
				"updatedAtMs": 1700000000000
			},
			"thresholds": {
				"tempMaxC": 10,
				"humidityMaxPct": 75
			},
			"state": {
				"doorOpen": false,
				"fanOn": false,
				"acOn": false,
				"autoMode": true
			},
			"inventory": {
				"count": 12,
				"lastScan": {
					"type": "QR",
					"code": "ABC-123",
					"ts": 1700000000000
				}
			},
			"telemetryHistory": {
				"-Nv...": { "ts": 1700000000000, "t": 6.5, "h": 63.2 },
				"-Nw...": { "ts": 1700000005000, "t": 6.6, "h": 63.0 }
			}
		}
	}
}
```

### Gợi ý rules (dev)

Khi demo nội bộ, có thể mở đọc/ghi để test nhanh. Khi triển khai thật, nên thêm Auth và rules theo user/role.

## Supabase (lưu trữ lâu dài)

Repo đã tích hợp Supabase để lưu lâu dài (Postgres) cho:

- `telemetry_readings`: lịch sử nhiệt độ/độ ẩm
- `inventory_events`: log quét QR/RFID

Khuyến nghị:

- KHÔNG dùng trực tiếp Postgres connection string trong Flutter/Web.
- KHÔNG commit password/connection string vào repo.
- Dùng `--dart-define` để inject biến môi trường: `SUPABASE_URL`, `SUPABASE_ANON_KEY`.

### Tạo schema

Chạy SQL trong Supabase SQL editor: [supabase_schema.sql](supabase_schema.sql)

Nếu bật RLS, bạn cần tạo policy cho phép insert/upsert từ client (hoặc tắt RLS khi demo).

### Chạy web kèm Supabase

```bash
flutter run -d chrome \
	--dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
	--dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

## Seed data giả (demo)

### Seed Firebase RTDB (để xem dashboard + biểu đồ)

Script này dùng RTDB REST API. Nếu RTDB rules đang khóa, bạn cần mở quyền (demo) hoặc thêm auth token.

```bash
dart run tool/seed_rtdb.dart --points 60
```

### Seed Supabase (lưu lâu dài)

Trước tiên chạy schema: [supabase_schema.sql](supabase_schema.sql)

```bash
dart run tool/seed_supabase.dart \
	--url YOUR_SUPABASE_URL \
	--key YOUR_SUPABASE_ANON_OR_SERVICE_ROLE_KEY \
	--points 60
```

## Kiến trúc code

- Data layer: [lib/data/warehouse_repository.dart](lib/data/warehouse_repository.dart) + models trong `lib/data/models/`
- UI: dashboard trong `lib/features/dashboard/`

## Ghi chú quan trọng

Chế độ tự động hiện được chạy bằng web client (MVP). Với sản phẩm thật, nên chuyển logic auto-control sang thiết bị (ESP32/PLC) hoặc Cloud Functions để tránh nhiều web client cùng lúc ghi trạng thái quạt/điều hòa.
