# SAHARA Mobile

## Setup

1. Install Flutter and Android Studio.
2. From the `mobile` directory run:

```bash
flutter create .
flutter pub get
```

`flutter create .` generates the Android/iOS platform folders while preserving the Dart files in `lib/`.

3. Start the backend from `backend/`:

```bash
python -m venv venv
venv\\Scripts\\activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

4. Android emulator uses `http://10.0.2.2:8000` (already configured).

For a physical Android phone, change `mobile/lib/config.dart` to your PC's LAN address, for example `http://192.168.1.10:8000`.

5. Run:

```bash
flutter run
```

## Permissions

Android needs microphone permission for participant voice recording. Add this inside `<manifest>` in `android/app/src/main/AndroidManifest.xml` if Flutter/plugin generation does not already add it:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

For local HTTP development, Android may also require cleartext traffic enabled on the application when using a non-HTTPS LAN URL.
