# SPENDO
> **Personal Finance Tracker** — แอปบันทึกรายรับ-รายจ่ายและติดตามการเงินส่วนบุคคล
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.10.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Version](https://img.shields.io/badge/version-2.0.0%2B1-informational)](https://github.com/TuTahStartsCoding/spendo_app)
**SPENDO** เป็นโปรเจกต์รายวิชาพัฒนาแอปพลิเคชันในระดับมัธยมศึกษาปีที่ 5 ภาคเรียนที่ 1 โดยมีแนวคิดจากปัญหาใกล้ตัว คือการติดตามว่าในแต่ละวันมีรายรับและรายจ่ายอะไรบ้าง และต้องการให้ผู้ใช้สามารถมองเห็นภาพรวมของการเงินของตนเองได้ง่ายขึ้น
โปรเจกต์นี้ถูกพัฒนาขึ้นเพื่อการเรียนรู้ โดยปัจจุบันเน้นการทำงานแบบ **Local-first / Local-only** และยังไม่ได้เชื่อมต่อระบบ Cloud หรือบริการ Backend ภายนอก
> **Project status:** Functional prototype / School project
>
> ฟีเจอร์และแพลตฟอร์มบางส่วนยังไม่ได้ผ่านการทดสอบอย่างเป็นทางการทุกสภาพแวดล้อม
---
##  Overview
SPENDO ช่วยให้ผู้ใช้สามารถจัดการข้อมูลทางการเงินพื้นฐานได้ในแอปเดียว เช่น
- บันทึกรายรับและรายจ่ายในชีวิตประจำวัน
- แก้ไขหรือลบรายการทางการเงิน
- จัดหมวดหมู่รายการ
- ตั้งงบประมาณ
- ดูยอดคงเหลือและสรุปการเงิน
- ดูรายการและรายงานตามช่วงวันที่
- แยกข้อมูลตามผู้ใช้ภายในเครื่องด้วยหมายเลขโทรศัพท์ที่ใช้เข้าสู่ระบบ
### เป้าหมายของโปรเจกต์
1. ฝึกกระบวนการพัฒนาแอปพลิเคชันด้วย Flutter และ Dart
2. ฝึกออกแบบ UI สำหรับแอปพลิเคชันที่ใช้งานจริงในชีวิตประจำวัน
3. ฝึกจัดการ State และข้อมูลภายในแอป
4. ฝึกออกแบบโครงสร้างข้อมูลและการจัดเก็บข้อมูลแบบ Local Database
5. สร้างผลงานที่สามารถนำไปใช้ประกอบ Portfolio ได้
---
##  Features
### Implemented
| Feature | Status | Description |
|---|:---:|---|
| Login |  | กรอกหมายเลขโทรศัพท์ 10 หลักเพื่อเข้าสู่แอป โดยไม่มี OTP หรือระบบยืนยันตัวตนภายนอก |
| Dashboard |  | แสดงยอดคงเหลือ รายรับ/รายจ่ายของเดือน และข้อมูลรายการล่าสุด |
| Income |  | เพิ่มรายการรายรับ |
| Expense |  | เพิ่มรายการรายจ่าย |
| Edit Transaction |  | แก้ไขรายการที่บันทึกไว้ |
| Delete Transaction |  | ลบรายการทางการเงิน |
| Categories |  | จัดหมวดหมู่รายรับ/รายจ่าย |
| Budget |  | สร้างและติดตามงบประมาณ |
| Financial Reports |  | ดูสรุปรายการทางการเงินและเลือกช่วงวันที่สำหรับรายงาน |
| Local Data Storage |  | จัดเก็บข้อมูลภายในอุปกรณ์ด้วย Hive |
### Planned / Future Improvements
ฟีเจอร์ต่อไปนี้ยังไม่ได้รวมเป็นความสามารถหลักของเวอร์ชันปัจจุบัน แต่เป็นแนวทางที่สามารถพัฒนาต่อได้:
-  Dark Mode
-  Export Data
-  Settings
-  Optional Cloud Sync / Backup
-  PWA deployment and browser testing
> รายการ Planned เป็นแนวทางพัฒนาต่อ ไม่ได้หมายความว่าฟีเจอร์เหล่านี้พร้อมใช้งานในเวอร์ชันปัจจุบัน
---
##  Screenshots
สามารถเพิ่มภาพหน้าจอของแอปได้ใน `docs/screenshots/` และแก้ไขส่วนนี้เมื่อมีภาพพร้อมใช้งาน
ตัวอย่างโครงสร้าง:
```text
spendo_app/
└── docs/
    └── screenshots/
        ├── login.png
        ├── dashboard.png
        ├── income.png
        ├── expense.png
        ├── budget.png
        └── report.png
```
ตัวอย่างการเพิ่มภาพใน README:
```md
![Login](docs/screenshots/login.png)
![Dashboard](docs/screenshots/dashboard.png)
![Budget](docs/screenshots/budget.png)
![Report](docs/screenshots/report.png)
```
---
##  Tech Stack
| Technology | Usage |
|---|---|
| **Flutter** | Cross-platform application framework |
| **Dart** | Programming language |
| **Provider** | State management |
| **Hive** | Local NoSQL database |
| **Hive Flutter** | Hive integration with Flutter |
| **Google Fonts** | Typography |
| **Intl** | Date and number formatting |
| **UUID** | Unique transaction/category/budget identifiers |
| **Shared Preferences** | Lightweight local settings/state |
| **Cupertino Icons** | Icon set |
### Development dependencies
- `flutter_test` — testing framework
- `hive_generator` — Hive adapter generation
- `build_runner` — code generation
- `flutter_lints` — Dart/Flutter lint rules
> หมายเหตุ: โปรเจกต์มี dependency สำหรับ chart rendering (`fl_chart`) และมี widget ที่เกี่ยวข้องใน source code แต่ความสามารถด้านกราฟยังไม่ถือเป็นฟีเจอร์หลักที่ประกาศไว้ใน README เวอร์ชันนี้
---
##  Architecture
SPENDO ใช้โครงสร้าง Flutter แบบแยกความรับผิดชอบตามหน้าที่ โดยแบ่งส่วนหลักออกเป็น Model, Provider, Service, Screen และ Widget
```text
┌───────────────────────────────┐
│            Screens            │
│ Login / Dashboard / Income    │
│ Expense / Budget / Report     │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│          AppProvider           │
│     State + Business Logic     │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│        DatabaseService         │
│   Data access / user context   │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│             Hive              │
│ Local Transactions / Category  │
│ Budget / Settings             │
└───────────────────────────────┘
```
### Main layers
#### `models/`
ประกาศโครงสร้างข้อมูลที่ใช้ในแอป เช่น
- `Transaction`
- `Category`
- `Budget`
- `TransactionType`
Model ที่ใช้กับ Hive จะมี generated adapter สำหรับการ serialize/deserialize ข้อมูล
#### `providers/`
จัดการ application state ผ่าน `Provider` / `ChangeNotifier` โดย `AppProvider` เป็นจุดกลางสำหรับโหลดและอัปเดตข้อมูลที่หน้าจอต่าง ๆ ใช้งานร่วมกัน
#### `services/`
`DatabaseService` ทำหน้าที่เป็นชั้นกลางสำหรับติดต่อกับ Hive และจัดการกล่องข้อมูล (boxes) เช่น transactions, categories, budgets และ settings
#### `screens/`
ประกอบด้วยหน้าหลักของแอป:
```text
screens/
├── login_screen.dart
├── dashboard_screen.dart
├── income_screen.dart
├── expense_screen.dart
├── budget_screen.dart
└── report_screen.dart
```
#### `widgets/`
เก็บ reusable UI components เช่น summary card, transaction item, buttons และ widgets ที่เกี่ยวข้องกับรายงาน
---
##  Data Storage
ปัจจุบัน SPENDO ใช้ **Hive** เป็นฐานข้อมูลแบบ Local Database
ข้อมูลหลักที่จัดเก็บ ได้แก่:
```text
Hive
├── Transactions
├── Categories
├── Budgets
└── Settings
```
### User data separation
แอปมีแนวคิดในการแยกข้อมูลตามหมายเลขโทรศัพท์ของผู้ใช้ภายในเครื่อง เช่น transaction/category/budget boxes ที่มี user identifier ประกอบ
อย่างไรก็ตาม ระบบ Login ในเวอร์ชันปัจจุบัน **ไม่ใช่ระบบ Authentication จริง** เพราะไม่ได้ตรวจสอบ OTP, password หรือ identity กับ server
ดังนั้นไม่ควรถือว่า Login ปัจจุบันเป็นระบบรักษาความปลอดภัยสำหรับข้อมูลที่มีความอ่อนไหวสูง
---
##  Login Flow
```text
User enters phone number
          │
          ▼
Validate 10-digit number
          │
          ▼
Store current user locally
          │
          ▼
Load user's local data
          │
          ▼
Dashboard
```
ข้อกำหนดของหมายเลขโทรศัพท์ในปัจจุบัน:
- ต้องมี 10 หลัก
- ต้องขึ้นต้นด้วย `0`
- ไม่มี OTP
- ไม่มี Password
- ไม่มี Backend Authentication
---
##  Project Structure
```text
spendo_app/
├── android/                  # Android platform configuration
├── ios/                      # iOS platform configuration
├── linux/                    # Linux platform configuration
├── macos/                    # macOS platform configuration
├── web/                      # Web platform configuration
├── windows/                  # Windows platform configuration
├── assets/
│   └── fonts/                # Application fonts
│
├── lib/
│   ├── models/               # Data models + Hive adapters
│   │   ├── budget.dart
│   │   ├── category.dart
│   │   └── transaction.dart
│   │
│   ├── providers/            # Application state management
│   │   └── app_provider.dart
│   │
│   ├── screens/              # Application screens
│   │   ├── login_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── income_screen.dart
│   │   ├── expense_screen.dart
│   │   ├── budget_screen.dart
│   │   └── report_screen.dart
│   │
│   ├── services/             # Data/service layer
│   │   └── database_service.dart
│   │
│   ├── utils/                # Constants and helper functions
│   │   ├── constants.dart
│   │   └── helpers.dart
│   │
│   ├── widgets/              # Reusable UI components
│   │   ├── custom_button.dart
│   │   ├── pie_chart_widget.dart
│   │   ├── summary_card.dart
│   │   └── transaction_item.dart
│   │
│   └── main.dart              # Application entry point
│
├── test/                      # Flutter tests
├── pubspec.yaml               # Dependencies and project metadata
├── analysis_options.yaml      # Dart analyzer configuration
└── README.md
```
> `.dart_tool/`, build outputs และไฟล์ที่สร้างขึ้นระหว่าง development ไม่ควรนำมาเก็บใน repository โดยไม่จำเป็น
---
##  Getting Started
### Requirements
ติดตั้งเครื่องมือเหล่านี้ก่อน:
- [Flutter SDK](https://flutter.dev/)
- Dart SDK ที่มากับ Flutter
- Git
- IDE เช่น VS Code หรือ Android Studio
เวอร์ชันที่ระบุในโปรเจกต์:
```text
Flutter >= 3.10.0
Dart >= 3.0.0 < 4.0.0
```
### 1. Clone repository
```bash
git clone https://github.com/TuTahStartsCoding/spendo_app.git
cd spendo_app
```
### 2. Install dependencies
```bash
flutter pub get
```
### 3. Generate Hive code (เมื่อจำเป็น)
หากมีการแก้ไข model ที่ใช้ Hive annotations ให้สร้าง generated files ใหม่ด้วย:
```bash
dart run build_runner build --delete-conflicting-outputs
```
### 4. Check Flutter environment
```bash
flutter doctor
```
### 5. Run the application
ดูอุปกรณ์ที่ Flutter ตรวจพบ:
```bash
flutter devices
```
จากนั้นรัน:
```bash
flutter run
```
หรือระบุ device/platform ที่ต้องการ เช่น:
```bash
flutter run -d chrome
```
> โปรเจกต์มีโครงสร้างสำหรับ Android, iOS, Web, Windows, macOS และ Linux แต่ ณ เวลาที่จัดทำ README นี้ยังไม่ได้ยืนยันการทดสอบครบทุก platform
---
##  PWA / Web
มีการเตรียม Flutter Web project ไว้แล้ว และมีแนวคิดที่จะนำ SPENDO ไปใช้งานในรูปแบบ **Progressive Web App (PWA)**
อย่างไรก็ตาม PWA ยังไม่ควรถูกระบุว่าเป็นความสามารถที่ production-ready เนื่องจากยังไม่ได้ผ่านการทดสอบและตรวจสอบ deployment อย่างเป็นทางการ
เมื่อพร้อมพัฒนาต่อ สามารถพิจารณาเรื่องต่อไปนี้:
- Web App Manifest
- Service Worker / offline caching
- Installability
- Responsive layout
- Browser storage behavior
- PWA icons และ splash screen
- HTTPS deployment
- Offline/online data synchronization
---
##  Testing
โปรเจกต์มีโครงสร้าง `test/` และ dependency `flutter_test` แต่ยังไม่ได้กำหนดชุด automated tests ที่ครอบคลุมฟีเจอร์ทั้งหมด
ก่อนนำไปใช้งานจริง ควรเพิ่มอย่างน้อย:
- Unit tests สำหรับการคำนวณรายรับ/รายจ่าย
- Unit tests สำหรับ budget calculations
- Tests สำหรับ `AppProvider`
- Tests สำหรับ `DatabaseService`
- Widget tests สำหรับหน้าหลัก
- Integration tests สำหรับ login → dashboard → transaction flow
- Web/PWA testing ใน browser ที่รองรับ
รัน test ด้วย:
```bash
flutter test
```
ตรวจ static analysis ด้วย:
```bash
flutter analyze
```
---
##  Current Limitations
SPENDO เป็นโปรเจกต์เพื่อการเรียนรู้จึงมีข้อจำกัดบางประการ:
1. Login เป็น local flow ไม่ใช่ server-side authentication
2. ข้อมูลถูกจัดเก็บภายในอุปกรณ์เป็นหลัก
3. ยังไม่มี Cloud Sync
4. ยังไม่มีระบบ Backup/Restore แบบ Cloud
5. ยังไม่ได้ทดสอบทุก platform อย่างเป็นทางการ
6. PWA ยังอยู่ในระดับแนวทาง/การเตรียมโครงการ ไม่ใช่ deployment ที่รับรองแล้ว
7. ยังไม่มีระบบ Export Data ในเวอร์ชันปัจจุบัน
8. Dark Mode และ Settings ยังเป็นงานที่วางแผนไว้
9. ไม่ควรใช้แอปเวอร์ชันนี้เป็นระบบบัญชีหรือระบบการเงินที่ต้องการความถูกต้อง/ความปลอดภัยระดับ production
---
##  Future Development
แนวทางพัฒนาต่อที่ตั้งใจไว้ ได้แก่:
### User Experience
- Dark Mode
- Settings screen
- ปรับปรุง responsive UI
- ปรับปรุง accessibility
### Data Management
- Export Data
- Backup / Restore
- Optional Cloud Sync
### Platform
- ทดสอบ Flutter Web
- ปรับปรุง PWA support
- ทดสอบการทำงานบนอุปกรณ์และ browser ที่หลากหลาย
> โปรเจกต์นี้เป็น school project ดังนั้นการพัฒนาต่อในอนาคตอาจขึ้นอยู่กับเวลาและความสนใจหลังจบรายวิชา
---
##  Learning Outcomes
โปรเจกต์ SPENDO ถูกพัฒนาขึ้นเพื่อฝึกทักษะด้าน Software Development โดยเฉพาะ:
- Flutter application development
- Dart programming
- UI/UX implementation
- State management ด้วย Provider
- Local database ด้วย Hive
- CRUD operations
- Data modeling
- Date and currency formatting
- Reusable widgets
- Project structure และ separation of concerns
- Git และ GitHub workflow
---
##  Contributing
เนื่องจาก SPENDO เป็นโปรเจกต์สำหรับการเรียนและ Portfolio repository นี้ไม่ได้เปิดรับ contribution อย่างเป็นทางการในขณะนี้
อย่างไรก็ตาม หากต้องการทดลองพัฒนาต่อ สามารถ fork repository และสร้าง branch ของตัวเองได้
ตัวอย่าง workflow:
```bash
git checkout -b feature/your-feature
# make changes
git add .
git commit -m "feat: add your feature"
git push origin feature/your-feature
```
จากนั้นสามารถเปิด Pull Request เพื่อเสนอการเปลี่ยนแปลงได้
---
##  License
**License ยังไม่ได้กำหนดในขณะนี้**
โปรเจกต์นี้จัดทำขึ้นเพื่อการศึกษาและ Portfolio หากมีการกำหนด License ในอนาคต ควรเพิ่มไฟล์ `LICENSE` และแก้ไขส่วนนี้ให้ตรงกับเงื่อนไขการใช้งานจริง
---
##  Repository
**GitHub:** https://github.com/TuTahStartsCoding/spendo_app/
---
##  Project Context
**Project:** SPENDO
**Type:** School Project
**Course context:** รายวิชาพัฒนาแอปพลิเคชัน
**Education level:** มัธยมศึกษาปีที่ 5
**Semester:** ภาคเรียนที่ 1
**Primary purpose:** บันทึกรายรับ-รายจ่ายและช่วยติดตามการเงินส่วนบุคคล
---
<p align="center">
  Made for learning, practice, and portfolio development with Flutter.
</p>
