# FavFeedr - A YouTube RSS Feed Watcher

<img src="https://github.com/user-attachments/assets/e1f980f2-f8fc-4f04-bbc9-ca571eca32c0" alt="About App" style="width:30%; height:auto;">

<img src="https://github.com/user-attachments/assets/3eb7d5d5-e360-40fc-90ab-bed4b896f4af" alt="Main Light mode" style="width:30%; height:auto;">

<img src="https://github.com/user-attachments/assets/78f4b3e5-352a-4e71-b3b8-eb2f0f186bd7" alt="Main dark mode" style="width:30%; height:auto;">

<img src="https://github.com/user-attachments/assets/6323d6f2-1bac-44e4-86ea-0f70a77dd088" alt="Settings window" style="width:30%; height:auto;">

<img src="https://github.com/user-attachments/assets/c508149a-c3a7-445d-9508-d661f906d289" alt="main app window" style="width:30%; height:auto;">

FavFeedr is a modern, cross-platform desktop application built with Flutter, designed to help you stay updated with the latest videos from your favorite YouTube channels. It fetches video updates directly from YouTube's RSS feeds, providing a clean and efficient way to consume content.

## Features

-   **Clean & Intuitive UI:** A redesigned user interface inspired by modern mobile apps, optimized for a smooth desktop experience.
-   **Selective Subscription Import:** Easily import your YouTube channel subscriptions from a `subscriptions.csv` file (obtained via Google Takeout). The app allows you to preview and select specific channels to import from your CSV.
-   **Group & Folder Management:** Organize your subscribed channels into custom groups or folders for better navigation on the main screen.
-   **Backup & Restore:** Export and import your subscribed channels and their assigned groups to/from JSON files for easy migration or backup.
-   **Channel-Specific Video Lists:** Browse videos grouped by channel, with each channel's feed in a collapsible section for easy navigation.
-   **Search Functionality:** Quickly find specific channels within the import selection screen using a built-in search bar.
-   **Light & Dark Mode:** Switch between beautiful light and dark themes, with your preference saved automatically.
-   **Subscription Management:** View and remove individual channel subscriptions directly from the app.
-   **Optimized Performance:** Fetches and processes channel feeds concurrently to ensure a responsive user experience, even with many subscriptions.
-   **Cross-Platform Support:** Fully functional on Linux desktop, macOS desktop, and Android mobile devices.

## Installation (Linux)

This project is already configured for Linux. To get FavFeedr up and running on your Linux machine, follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your_repo/favfeedr.git
    cd favfeedr
    ```
    (Replace the URL with the actual repository URL.)

2.  **Navigate to the Flutter project directory:**
    ```bash
    cd favfeedr_flutter
    ```

3.  **Get Flutter dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Build and run the application:**
    ```bash
    flutter run -d linux
    ```
    For a release build, use:
    ```bash
    flutter build linux
    ```

## Installation (macOS)

FavFeedr can also be built and run natively on macOS using Flutter.

### Prerequisites

- **macOS 12 or later (recommended)**
- **Flutter SDK** installed and added to your PATH
- **Xcode** installed from the Mac App Store
- Xcode command line tools:
  ```bash
  xcode-select --install
  ```

Verify your setup:
```bash
flutter doctor
```
Ensure there are no issues under **macOS** and **Xcode**.

### Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your_repo/favfeedr.git
   cd favfeedr/favfeedr_flutter
   ```

2. **Enable macOS desktop support (if not already enabled):**
   ```bash
   flutter config --enable-macos-desktop
   ```

3. **Get Flutter dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the app on macOS:**
   ```bash
   flutter run -d macos
   ```

5. **Build a release app (optional):**
   ```bash
   flutter build macos
   ```

The compiled macOS app will be available under:
```
build/macos/Build/Products/Release/
```

## Installation (Android)

To get FavFeedr running on your Android device:

1.  **Clone the repository** and **navigate to the Flutter project directory** as described above.
2.  **Get Flutter dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Ensure Android toolchain is set up:**
    ```bash
    flutter doctor
    ```
    Resolve any issues under **Android toolchain**.
4.  **Build the release APK:**
    ```bash
    flutter build apk
    ```
    The APK will be generated at:
    ```
    build/app/outputs/flutter-apk/app-release.apk
    ```
5.  **Install on device:** Transfer the APK to your Android phone and install it manually. Ensure **Install unknown apps** permission is enabled.

## Usage

1.  **Import Subscriptions (CSV):**
    -   Click **"Upload subscriptions.csv"** on the main screen.
    -   Select your CSV file exported from Google Takeout.
    -   Preview, search, and select channels, then click **"Import Selected"**.

2.  **Backup & Restore (JSON):**
    -   Open the menu → **Settings**.
    -   Use **Export** or **Import Subscriptions (JSON)**.

3.  **Manage Groups:**
    -   Menu → **Settings** → **Manage Groups**.

4.  **Assign Channels to Groups:**
    -   Settings → **Manage Subscriptions**.
    -   Use the dropdown next to each channel.

5.  **Browse & Watch Videos:**
    -   Expand groups and channels to view videos.
    -   Click a video to open it in your default browser.

6.  **Toggle Theme:**
    -   Use the light/dark icon in the app bar.

7.  **About & Settings:**
    -   Access via the hamburger menu.

---
**Note:** This project assumes the Flutter SDK is installed and properly configured on your system.

