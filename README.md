# Project Report: InstantGram - Advanced Instagram Clone in Flutter

InstantGram is a premium, fully-featured social media mobile application designed as a replica of Instagram. It is built using Flutter, leveraging Hooks Riverpod for state management, and powered by Google Firebase as the backend infrastructure.

The project is hosted in a public git repository at the following URL:
https://github.com/quangthanhng/instant_gram_practice

---

## Code Reference Links

To review specific portions of the source code directly on GitHub, utilize the following references:

*   Repository Root: https://github.com/quangthanhng/instant_gram_practice
*   Main Application Entry: https://github.com/quangthanhng/instant_gram_practice/blob/main/lib/main.dart
*   User Interface Layouts: https://github.com/quangthanhng/instant_gram_practice/tree/main/lib/views
*   State Providers and Managers: https://github.com/quangthanhng/instant_gram_practice/tree/main/lib/state
*   Firebase Authentication Service: https://github.com/quangthanhng/instant_gram_practice/blob/main/lib/state/auth/backend/authenticator.dart
*   User Database storage: https://github.com/quangthanhng/instant_gram_practice/blob/main/lib/state/user_info/backend/user_info_storage.dart
*   Post Upload Handler: https://github.com/quangthanhng/instant_gram_practice/blob/main/lib/state/image_upload/notifiers/image_upload_notifier.dart

---

## Front-End (FE) Architecture Analysis

The frontend of InstantGram is structured using clean architecture principles, ensuring a separation of concerns between UI presentation and state management.

### 1. State Management with Riverpod and Flutter Hooks
State is managed declaratively by combining hooks_riverpod and flutter_hooks. This combination reduces boilerplate and automatically handles the lifecycle of controllers (such as text input controllers, animations, and focus nodes).

Key Providers in the System:
*   `isLoggedInProvider`: Monitors current Firebase Auth states and returns a boolean value indicating if a session is active.
*   `userIdProvider`: Exposes the active user ID string from authenticated sessions.
*   `allPostsProvider`: A StreamProvider retrieving all posts from the Cloud Firestore posts collection sorted chronologically by creation date.
*   `userPostsProvider`: A StreamProvider querying and monitoring only the posts created by the active user.
*   `postLikeCountProvider`: Exposes the integer count of likes mapped to a specific post document.
*   `hasLikedPostProvider`: Monitors if the active user ID exists in the likes collection for a specific post.
*   `postCommentProvider`: Exposes the real-time stream of comments added to a target post.
*   `thubmnailProvider`: A FutureProvider taking media paths and generating aspect ratios and memory-rendered preview images (generating thumbnails for video paths using VideoThumbnail SDK).
*   `postsBySearchTermProvider`: Queries post message fields using search tags or keyword matching.

### 2. User Interface Views
The UI is categorized into dedicated view modules located in `lib/views/`:
*   `login/`: Houses the login screens which allow users to sign in with Google or Facebook accounts. It interacts with the Authenticator backend and handles authentication errors.
*   `main/`: Contains the overall main view layout with a bottom navigation bar.
*   `tabs/`: Subdivided into specific sub-views representing the bottom tabs:
    *   **Home Tab:** A stream of all posts on the network. Includes pull-to-refresh to pull the latest content.
    *   **Search Tab:** Standard search bar which updates the search query state, showing search results in a staggered grid.
    *   **User Profile Tab:** Displays posts specific to the current user, post metrics, and allows updating the user profile details.
*   `create_new_post/`: Features a media picker interface. Displays a thumbnail preview of selected media, calculates the aspect ratio, and provides toggles for custom post settings.
*   `post_comments/`: Shows a real-time list of comments and handles comment inputs.
*   `components/`: Reusable widgets like post card items, dialog boxes, custom avatar views, heart like animations, and shimmer skeletons.

---

## System Flow In-Depth Analysis

### 1. User Authentication Flow
The system processes login using the following sequence:
1.  **Platform Integration:** In `authenticator.dart`, OAuth protocols authenticate credentials through the FacebookAuth and GoogleSignIn plugins.
2.  **Firebase Sign-in:** The OAuth token (e.g., ID token for Google) is exchanged for a Firebase credential.
3.  **Account Collision Handling:** If an email is already registered under Google and the user logs in with Facebook using the same email, the authenticator handles the exception by linking the Facebook credential to the existing Google account.
4.  **Database Synchronization:** Upon successful login, the authenticator triggers `UserInfoStorage`. If the user does not exist in the Firestore `users` collection, a new user profile document containing the display name, email, and UID is created. If the user already exists, their profile information is updated to match their latest Google or Facebook profile state.

### 2. Post Creation and Upload Flow
The media uploading pipeline consists of several sequential operations:
1.  **Local Picking:** The creator selects a photo or video using `image_picker`.
2.  **Thumbnail Generation:** The picked file is passed to `thubmnailProvider`. For videos, `VideoThumbnail` extracts frames from the binary stream. The aspect ratio is measured.
3.  **Cloud Storage Upload:** Both the original media and the thumbnail are uploaded as distinct files to Firebase Cloud Storage. A unique UUID is generated to identify each asset.
4.  **Firestore Document Persistence:** The upload notifier writes a new document to the `posts` collection in Cloud Firestore, linking the Cloud Storage file URLs, aspect ratio, post caption text, creator's user ID, and settings map.

### 3. Interaction and Synchronization Flow
Likes and comments are updated in real-time via reactive listeners:
*   **Likes Engine:** Clicking the heart icon on a post card triggers `LikeDislikePostProvider`. This provider writes a document in the Firestore `likes` collection mapping `user_id` to `post_id`. The UI listens to this query snapshot, automatically updating the like counts and heart icon state.
*   **Comments Engine:** Submitting a comment calls `SendCommentNotifier`. It writes a new document under the Firestore `comments` collection. The stream provider `postCommentProvider` monitors this sub-collection and updates the post details view in real-time.

---

## Back-End (BE) Database and Storage Schema

### 1. Cloud Firestore Collections Layout

#### `users` Collection
*   `uid` (String): Unique identifier matching the authenticated user ID.
*   `display_name` (String): The username displayed across posts and comments.
*   `email` (String): Verified email address.

#### `posts` Collection
*   `uid` (String): The creator's user ID.
*   `message` (String): Caption associated with the post.
*   `created_at` (Timestamp): Creation date and time.
*   `file_url` (String): Storage download link to the original image or video file.
*   `thumbnail_url` (String): Storage download link to the generated media thumbnail.
*   `file_type` (String): Denotes file type (image or video).
*   `aspect_ratio` (Double): Aspect ratio used to maintain layout stability.
*   `post_settings` (Map): Map configuring user interactions:
    *   `allow_likes` (Boolean)
    *   `allow_comments` (Boolean)
*   `thumbnail_storage_id` (String): Target storage file ID for the thumbnail.
*   `original_file_storage_id` (String): Target storage file ID for the source file.

#### `comments` Collection
*   `comment` (String): The textual comment body.
*   `created_at` (Timestamp): Creation timestamp.
*   `user_id` (String): Sender's user ID.
*   `post_id` (String): The target post ID.

#### `likes` Collection
*   `post_id` (String): Reference post ID.
*   `user_id` (String): Liking user's ID.
*   `created_at` (Timestamp): Timestamp when liked.

### 2. Cloud Storage Directory Layout
*   `/thumbnails/`: Stores compressed image and video preview thumbnails to reduce client data consumption.
*   `/images/`: Stores original user-uploaded photos.
*   `/videos/`: Stores original user-uploaded videos.

---

## Local Setup and Running Guide

To run this project locally, execute the following steps:

### 1. Prerequisite Installations
*   Ensure Flutter SDK is installed (version 3.11.4 or higher recommended).
*   Ensure CocoaPods is installed if building for iOS.
*   Configure the Android SDK and have an active Android Emulator or physical device connected in developer mode.

### 2. Download Dependencies
In the root directory of the project, execute the following command to download all required packages listed in `pubspec.yaml`:
```bash
flutter pub get
```

### 3. Configure Firebase Connection
Ensure you have the Firebase CLI tools installed. Authenticate and link the project using:
```bash
firebase login
flutterfire configure
```
This generates the `lib/firebase_options.dart` file automatically, establishing target configurations for Android and iOS.

### 4. Build and Run
To launch the application in debug mode on your connected emulator or device, run:
```bash
flutter run
```

---

## Production Build (Android APK)

The production release package (APK) has been compiled successfully for installation and manual testing.

*   **Build Output Path:** `build/app/outputs/flutter-apk/app-release.apk`
*   **Compiled File Size:** 62.8 MB
*   **Target SDK Level:** Compatible with Android devices running Android 5.0 (API Level 21) or newer.

### Build Implementation Details
During the build process, a compilation compatibility parameter was appended to the gradle options (`kotlin.jvm.target.validation.mode=IGNORE` inside `android/gradle.properties`). This overrides strict target checks and resolves mismatch issues between modern Kotlin versions and legacy plugin configurations (specifically `flutter_facebook_auth`), producing a stable release APK.

### Rebuilding the Release APK
To compile the application code again from source, run:
```bash
flutter build apk --release
```
