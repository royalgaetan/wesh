# <img src="https://www.royalgaetan.com/assets/wesh%20logo.png" width="100" alt="Wesh">
Create. Celebrate. Share.
<br><br>

# About
[Wesh](https://royalgaetan.com/wesh) transforms how you celebrate life's milestones 🎉. 

From intelligent reminders and instant messaging to captivating stories, Wesh keeps you in touch with what matters most 💌. 

Experience a new way to celebrate and connect!
<br><br><br>

# Features

- **Getting Started**: Easy sign-up and instant homepage access 🚀
- **Events**: Create, edit, view, and add events and reminders 📅
- **Stories**: Share content that lasts 24 hours 📸
- **Forevers**: Save stories permanently ⏳
- **Chats**: Real-time messaging with various media 💬
- **Profile**: Manage events, reminders, and data 🛠️
- **Notifications**: Stay updated with personalized alerts 📲
- **Search**: Find events and people with powerful filters 🔍
- **Share & Forward**: Share and receive content easily 🔄
- **Special Happy Birthday**: Receive special birthday wishes 🎉
- **Help Center**: Get support and answers to issues 🆘

<br><br>
<div style="display: flex; justify-content: space-between;">
  <img src="https://www.royalgaetan.com/assets/wesh%20previews/Story%20v0.2.png" width="150" />
  <img src="https://www.royalgaetan.com/assets/wesh%20previews/Home%20Page%20v0.2.png" width="150" />
  <img src="https://www.royalgaetan.com/assets/wesh%20previews/Special%20Happy%20Birthday%20v0.2.png" width="150" />
</div>
<br><br>

You can find a complete walkthrough here:
🔗 [Wesh.com](https://royalgaetan.com/wesh)
<br><br><br>

# Wesh v0.3 Roadmap 🚀
This roadmap outlines the key features and improvements planned for the upcoming version 0.3 of Wesh. 

Our focus is on enhancing performance, integrating new functionalities, refining user experience, and ensuring overall app stability. 

The high-priority tasks include reducing jank frames, integrating external calendars, improving authentication processes, and adding more interactive features. 

We also aim to improve notifications, optimize search and profile functionalities, and provide better internationalization support. 

Our goal is to create a seamless and engaging experience for all users.
<br><br>

### High Priority 🔥
- **Performance**: Reduce all jank frames (use devTools)<br>

### Features & Integrations 🌟
- **External Calendar Integration**: iCalendar, Google Calendar, Calendly. Visible in CalendarOption Modal: on Logo tap()
- **Calendar Views**: Monthly, Daily, etc. Visible in CalendarOption Modal: on Logo tap()
- **Custom Image/Video Picker**: Implement custom picker<br>

### Major Fixes 🛠️
- **Notifications v2**:
  1. Fix notifications
  2. Fix reminders (trigger, add type: alarm/Notification) with CTA
- **GetX**: Integrate GetX for state management
- **User Notifications**: Notify user on "Follow"
- **Notifications Page**: Add a Notifications Page and its button in homepage: aka Activities Page
- **ML/AI Integration**: Add Event Suggestions or Recommendations via Notification<br>

### Authentication (Auth v2) 🔒
- **Profile Picture Upload**: Compress large images before upload
- **Account Creation**: Option to set birthdays as Private or Public
- **Birthday Field**: Add max date (+13 years old usage limitation)
- **Back Button**: Avoid removing previous data on back navigation
- **Phone OTP**: Add phone OTP verification
- **Forgot Password**: Refine and fix the process
- **Email Token Verification**: Implement pending feature
- **UX Improvements**:
  - Add loader between register pages
  - Transform uppercase to lowercase in register page
  - Add additional ways to update birthday
- **Username Page**: Create new link for Terms & Conditions
- **Settings**:
  - Fix email and password reset
  - Review and test account linking and auth workflows<br>

### General Improvements 🔧
- **Fonts**: Use only 1 or 2 fonts for the app
- **Image Cache & Loader**: Fix issues
- **Internationalization**: Allow users to change Time & Date format in settings
- **Markdown Support**: Accept markdown in text fields, message box, bio box, etc.
- **App Inactivity**: Handle app inactivity or background state<br>

### Background Handler v2 🔄
- **UI & Logic**: Fix file uploads and downloads (including Inbox and Stories)<br>

### Settings Page ⚙️
- **Language & Country**: Add options to change app language and country
- **Themes**: Dark/Light Mode switcher using Providers
- **App Version Trigger**: Notify user about new app versions<br>

### Inbox Features ✉️
- **Emoji Keyboard 2.0**: Introduce enhanced emoji keyboard
- **Messages Pagination**: Implement pagination for messages
- **New Messages Indicator**: Show number of new messages if user is not at the bottom of chat feed
- **Media Message Handling**: Allow re-download of moved or deleted media files
- **Chats Tab**:
  - Add search box to search for chats
  - Allow multiple chat selection for deletion or marking as read
- **Media Preview Page**:
  - Compress media if too large
  - Add media editing features: Crop, Filters, Effects, Trim, Mute/Unmute
- **Draft Feature**: Add draft feature for each chat
- **Custom Birthday Wish**:
  - Add custom GIF/Video/Image/Stickers
  - Attach money or in-app shop product as gifts<br>

### Event Management 🎉
- **Event Types & Categories**: Generate and categorize events with ChatGPT
- **Create Event Page**: 
  - Add remove button for each duration/day added
  - Support markdown in event captions
- **Event Privacy**: Control event visibility
- **Event Metrics**: Display event metrics with charts
- **Event Interactions**: Add like, share, and comment functionalities
- **Event Location API**: Integrate location API and connect maps
- **User Categories Preferences**: Suggest or recommend events based on preferences
- **Global Important Dates**: Schedule important dates for Wesh Official<br>

### Forward Page 📤
- **Loading Time**: Reduce loading time for recent chats list
- **Multi-Person Forwarding**: Allow forwarding to multiple persons at a time<br>

### Forever Feature 🕒
- **Reorder Stories**: Allow drag-and-drop functionality to reorder stories<br>

### Search Page 🔍
- **Suggestions**: Add suggestions/recommendations when empty
- **Search Optimization**: Perform search on server and apply pagination to results<br>

### Profile Page 👤
- **Pagination**: Implement pagination for events list, reminders list, and forevers list
- **Account Information**: Request account information
- **Account Deletion**: Handle cascading deletions<br>

### Permissions ✅
- **Fix Permissions**: Ask only when necessary<br>

### Firebase Integration 🔥
- **Useful Plugins**: Install Performance, Crashlytics, etc.
- **App Check**: Enforce protections and register all apps
- **Firebase Rules**: Adjust Firestore and Storage rules<br>

### Migrations & Adaptations 🔄
- **build.gradle**: Migrate to declarative approach
- **Dynamic Links**: Migrate to themedata and useMaterial3
- **Theme Adaptations**: Adapt Theme.of(context).colorScheme
- **Common Styles**: Establish a common method for getting colors, styles, etc.<br>

### Future Updates 🔮
- **Create Event Page**: Add Live/Offline/Online/File event forms<br>

### Help Center 📚
- **Update**: Refresh the Help Center once finished<br>

### Code Clean-up 🧹
- **Refactoring**: Remake folder structure and file naming
- **Code Documentation**: Add proper code documentation<br>

### Performance & CI/CD 🚀
- **App Size**: Reduce or optimize package usage
- **Setup CI/CD**: Remove all debugPrint()<br>

<br><br>



# Contribute to Wesh

### 🤝 For Contributors
We’d love your help to make Wesh even better! 

If you have a fix for something on our roadmap or an awesome new idea, don’t hesitate to jump in. 

Just submit a pull request to tackle an issue or share your brilliant suggestions. 

Every contribution, big or small, is a step towards improving Wesh and making it a more amazing experience for everyone. 

Come join our community and help us shape the future of Wesh!
<br><br>

### 🌟 For Visitors
Welcome to the Wesh open-source community! Feel free to explore, clone, or copy our code. 

We hope you find it helpful to see how we solve problems and develop new features. 

Your thoughts and feedback are always welcome as we grow and evolve the project. 

Dive in, take a look around, and let’s make Wesh even better together!



Happy coding! 🎉


