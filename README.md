# FavFeedr - A YouTube RSS Feed Reader

![photo_2025-12-08_16-42-19](https://github.com/user-attachments/assets/e1f980f2-f8fc-4f04-bbc9-ca571eca32c0){height=420}
![photo_2025-12-08_16-42-28](https://github.com/user-attachments/assets/3eb7d5d5-e360-40fc-90ab-bed4b896f4af){height=420}
![photo_2025-12-08_16-42-24](https://github.com/user-attachments/assets/78f4b3e5-352a-4e71-b3b8-eb2f0f186bd7){height=420}

![photo_2025-12-08_16-42-31](https://github.com/user-attachments/assets/6323d6f2-1bac-44e4-86ea-0f70a77dd088){height=420}

![photo_2025-12-08_16-42-34](https://github.com/user-attachments/assets/c508149a-c3a7-445d-9508-d661f906d289){height=420}

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
-   **Cross-Platform Support:** Fully functional on Linux desktop and Android mobile devices.

## Installation (Linux)

This project is already configured for Linux. To get FavFeedr up and running on your Linux machine, follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your_repo/favfeedr.git
    cd favfeedr
    ```
    (Note: Replace `https://github.com/your_repo/favfeedr.git` with the actual repository URL if this project were hosted on GitHub.)

2.  **Navigate to the Flutter project directory:**
    ```bash
    cd favfeedr_flutter
    ```

3.  **Get Flutter dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Build and Run the application:**
    ```bash
    flutter run -d linux
    ```
    This will launch the application in debug mode. For a release build, use `flutter build linux`.

## Installation (Android)

To get FavFeedr running on your Android device:

1.  **Clone the repository** and **navigate to the Flutter project directory** as described in the Linux installation steps.
2.  **Get Flutter dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Ensure Android Toolchain is set up:** Run `flutter doctor` and resolve any issues under the "Android toolchain" section.
4.  **Build the Release APK:**
    ```bash
    flutter build apk
    ```
    The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.
5.  **Install on Device:** Transfer the `app-release.apk` file to your Android phone and install it manually. Ensure "Install unknown apps" permission is granted for your file manager or browser.

## Usage

1.  **Import Subscriptions (CSV):**
    -   Click the **"Upload subscriptions.csv"** button on the main screen.
    -   Select your `subscriptions.csv` file (exported from [Google Takeout](https://takeout.google.com/)).
    -   A new window will appear, listing all channels found in the CSV. You can search, select/deselect channels, and then click **"Import Selected"**.
2.  **Backup & Restore Subscriptions (JSON):**
    -   Open the menu (hamburger icon) and go to **Settings**.
    -   Tap **"Export Subscriptions (JSON)"** to save your current channels and groups to a JSON file.
    -   Tap **"Import Subscriptions (JSON)"** to load channels and groups from a previously exported JSON file.
3.  **Manage Groups:**
    -   Open the menu (hamburger icon) and go to **Settings**.
    -   Tap **"Manage Groups"**. Here you can add, rename, or delete groups.
4.  **Assign Channels to Groups:**
    -   In **Settings, tap "Manage Subscriptions"**.
    -   Use the dropdown menu next to each channel to assign it to a group.
5.  **Browse Videos:**
    -   On the main screen, channels will be organized by the groups you've assigned.
    -   Click a group name to expand or collapse it. Click a channel name to expand its video list.
    -   The grid view for video posts is optimized for phone screens.
    -   New videos will be marked with a count next to the channel name.
6.  **Watch Videos:**
    -   Click on any video item to open it in your default web browser. The 'new' count for that video's channel will update accordingly.
7.  **Toggle Theme:**
    -   Click the **light/dark mode icon** in the app bar to switch between themes. Your preference will be saved.
8.  **Access Menu (About & Settings):**
    -   Tap the **hamburger icon** in the top-left corner of the app bar to open the navigation drawer. From there, you can access "About" and "Settings" options.

---
**Note:** This `README.md` assumes the user has Flutter SDK installed and configured.
