
## 🎯 Key Components

### NoteModel
- Represents individual notes with id, title, content, and modification time
- Handles note serialization and data management

### NoteData (ChangeNotifier)
- Manages note CRUD operations
- Handles theme settings (dark/light mode)
- Integrates with Hive database for persistence

### HomeView
- Main screen displaying notes timeline
- Search functionality
- Note creation and navigation

### EditScreen
- Rich text editor for creating/editing notes
- PDF export capabilities
- Screenshot functionality

## 🎨 Features in Detail

### Theme Management
- System theme detection
- Manual dark/light mode toggle
- Persistent theme preferences

### Note Management
- Create new notes
- Edit existing notes
- Delete notes
- Search through notes
- Date-based organization

### Sharing Options
- Export notes as PDF
- Take screenshots of notes
- Share via system share sheet

## 🔧 Configuration

The app uses Hive for local storage with the following boxes:
- `note_database`: Stores notes and app settings

## 📦 Dependencies

Key dependencies include:
- `hooks_riverpod`: State management
- `hive_flutter`: Local database
- `super_editor`: Rich text editing
- `date_picker_timeline`: Date selection
- `pdf`: PDF generation
- `share_plus`: Note sharing
- `screenshot`: Screenshot capture

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All the package maintainers for their excellent work
- The open-source community for inspiration and support

---

**Note**: This is a personal note-taking application designed for local use. All data is stored locally on your device for privacy and security.