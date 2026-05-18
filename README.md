# מַקְדֵם (Makdem)

A specialized Flutter compass application designed for Judaic prayer, orienting the user towards East (קֶדֶם) rather than North.

## Features

*   **East-Oriented Dial:** The compass rotates so that East naturally points to the top.
*   **Traditional Hebrew Terminology:** Uses ancient directional names along the radial axes (קדם, ים, נגב, צפון).
*   **Shabbat Safety Mode (טכנולוגיה שומרת שבת):** Includes a spinbox counter. The compass dial remains blurred and locked pointing West (ים) until the user explicitly confirms they have seen at least 3 stars.
*   **Offline First:** The app comes pre-bundled with the beautiful "Frank Ruhl Libre" font and all visual assets, ensuring it works flawlessly offline.
*   **Built-in Q&A (שו"ת):** A dedicated screen answering common halachic and technical questions regarding the app's functionality.

## Building

This project uses GitHub Actions to automatically build split architecture APKs.
To build manually:

```bash
flutter pub get
flutter build apk --release --split-per-abi
```

## Attributions and Copyright

*   **Source Code:** Copyright (c) 2026 Alex Bodnaru. Released under the MIT License.
*   **Cover Image:** Provided by [DEZALB via Pixabay](https://pixabay.com/users/dezalb-1045091/) under the [Pixabay Content License](https://pixabay.com/service/license-summary/).
*   **Typography:** Uses the [Frank Ruhl Libre](https://fonts.google.com/specimen/Frank+Ruhl+Libre) font, licensed under the SIL Open Font License (OFL).
*   **Background Music Link:** Links to the beautiful song "כותל המזרח" hosted on YouTube.
