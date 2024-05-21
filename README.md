
# AvailAlert

AvailAlert is a mobile application developed using Flutter, Firestore, and Firebase Messaging. This app allows users to check the real-time availability of other users and set alerts to get notified whenever there is a change in their availability status.

## Table of Contents
- [Introduction](#introduction)
- [App Features](#app-features)
- [Installation](#installation)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Introduction

AvailAlert is designed to help users stay updated with the availability status of others in real time. Whether you want to know when a friend, family member, or colleague becomes available, AvailAlert provides a seamless way to track and get notified of changes in their status.

## App Features

- **Real-Time Availability Check:** View the current availability status of other users in real time.
- **Set Alerts:** Set alerts for specific users to receive notifications when their availability status changes.
- **Firebase Integration:** Utilizes Firestore for real-time data updates and Firebase Messaging for push notifications.
- **User-Friendly Interface:** Simple and intuitive design for an enhanced user experience.

## Installation

To install AvailAlert on your Android or iOS device, follow these steps:

1. **Clone the Repository:**
	```bash
    git clone https://github.com/meetbutani/AvailAlert.git
	```

2. **Navigate to the Project Directory:**
	```bash
	cd AvailAlert
	```

3. **Install Dependencies:**
	```bash
    flutter pub get
	```

4. **Set Up Firebase:**
   - Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   - Add an Android and/or iOS app to your Firebase project.
   - Download the `google-services.json` file for Android and/or `GoogleService-Info.plist` file for iOS.
   - Place the `google-services.json` file in the `android/app` directory.
   - Place the `GoogleService-Info.plist` file in the `ios/Runner` directory.
   - Follow the Firebase setup instructions for both [Android](https://firebase.google.com/docs/android/setup) and [iOS](https://firebase.google.com/docs/ios/setup).

5. **Run the App:**
   Connect your Android or iOS device, or start an emulator.
	```bash
	flutter run
	```

## Contributing

We welcome contributions from the community to improve AvailAlert. To contribute, follow these steps:

1. **Fork the Repository:** Click the `Fork` button on the top right corner of the repository page.
2. **Create a Branch:**
	```bash
    git checkout -b feature/your-feature-name
	```
3. **Make Your Changes:** Implement your feature or bug fix.
4. **Commit Your Changes:**
	```bash
    git commit -m "Description of your changes"
	```
5. **Push to Your Branch:**
	```bash
    git push origin feature/your-feature-name
	```
6. **Create a Pull Request:** Go to the repository on GitHub and open a pull request.

## License

AvailAlert is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contact

For any inquiries, issues, or suggestions, please contact us at:

- Email: meet.butani2702@gmail.com
- GitHub Issues: [AvailAlert Issues](https://github.com/meetbutani/AvailAlert/issues)

Thank you for using AvailAlert! We hope it helps you stay connected by keeping you informed of others' availability in real time.
