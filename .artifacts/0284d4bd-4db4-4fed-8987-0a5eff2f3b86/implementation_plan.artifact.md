# Auth va Local Storage Topshiriq Rejasi

Ushbu reja JWT autentifikatsiya oqimini yakunlash va lokal xotira bilan ishlash qismini amalga oshirishga qaratilgan.

## Proposed Changes

### [Auth Feature]
Hozirda tarqoq holda turgan auth mantiqini yagona joyga jamlaymiz va Cubit bilan bog'laymiz.

#### [NEW] [auth_repository.dart](file:///C:/Users/imvco/StudioProjects/PocketTrack/lib/features/auth/domain/repositories/auth_repository.dart)
Auth operatsiyalari uchun interfeys.
#### [NEW] [auth_repository_impl.dart](file:///C:/Users/imvco/StudioProjects/PocketTrack/lib/features/auth/data/repositories/auth_repository_impl.dart)
AuthRepository interfeysining realizatsiyasi.
#### [NEW] [auth_cubit.dart](file:///C:/Users/imvco/StudioProjects/PocketTrack/lib/features/auth/presentation/cubit/auth_cubit.dart)
Autentifikatsiya holatini boshqarish (Login, Logout, AuthCheck).
#### [MODIFY] [login_page.dart](file:///C:/Users/imvco/StudioProjects/PocketTrack/lib/features/auth/presentation/pages/login_page.dart)
Cubit bilan bog'lash va loading/error holatlarini ko'rsatish.

### [Local Storage Feature (Task 02)]
Hive yordamida kichik CRUD feature yaratamiz.

#### [NEW] [expense_model.dart](file:///C:/Users/imvco/StudioProjects/PocketTrack/lib/features/expense/domain/entities/expense.dart)
Xarajatlar modeli (Freezed).
#### [NEW] [expense_cubit.dart](file:///C:/Users/imvco/StudioProjects/PocketTrack/lib/features/expense/application/expense_cubit.dart)
Lokal CRUD operatsiyalari uchun Cubit.

## Verification Plan
- Login jarayonini DummyJSON orqali tekshirish.
- Token muddati tugaganda (expiresInMins: 1) avtomatik refresh bo'lishini loglarda ko'rish.
- Ilovani o'chirib yoqqanda login holati saqlanishini tekshirish.
- Lokal qo'shilgan ma'lumotlar Hive bazasida saqlanishini tekshirish.
