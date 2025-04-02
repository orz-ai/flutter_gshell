

# GShell

A modern, cross-platform SSH terminal management application built with Flutter.

![GShell Screenshot](screenshots/main.png)

## Features

- **Intuitive Interface**: Clean, modern UI with Material Design 3
- **Session Management**: Organize SSH connections with groups and folders
- **Multi-tab Terminal**: Work with multiple sessions in a single window
- **Authentication Options**: Support for password and SSH key authentication
- **SFTP File Transfer**: Built-in file management capabilities
- **Theme Customization**: Multiple terminal themes and appearance settings
- **Cross-Platform**: Available on Windows, macOS, Linux, Android, and iOS

## Installation

### Prerequisites

- Flutter SDK (2.10.0 or higher)
- Dart SDK (2.16.0 or higher)
- Platform-specific development tools

### Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/orz-ai/flutter_gshell.git
   cd flutter_gshell
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Building for Production

### Desktop

```bash
flutter build windows
flutter build macos
flutter build linux
```

### Mobile

```bash
flutter build apk --release
flutter build ios --release
```

## Project Structure

```
lib/
├── app/                  # Application code
│   ├── core/             # Core utilities and theme
│   ├── data/             # Data models and services
│   ├── modules/          # Feature modules
│   └── routes/           # App routes
├── main.dart             # Entry point
```

## Dependencies

- [GetX](https://pub.dev/packages/get) - State management and routing
- [dartssh2](https://pub.dev/packages/dartssh2) - SSH implementation
- [xterm](https://pub.dev/packages/xterm) - Terminal emulation
- [shared_preferences](https://pub.dev/packages/shared_preferences) - Local storage

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Material Design](https://material.io/design)
- All the contributors who have helped shape GShell

---

## Contact

Project Link: [https://github.com/orz-ai/flutter_gshell](https://github.com/orz-ai/flutter_gshell)
