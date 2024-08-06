# ![Wesh](https://us-ms.gr-cdn.com/getresponse-tubnk/photos/e1dbc88f-6474-4403-b1b3-1f354b55a199.png)

Create. Celebrate. Share.
<br><br>


# About
🔗 [Wesh.com](https://wesh.royalgaetan.com)

Wesh transforms how you celebrate life's milestones 🎉

From intelligent reminders and instant messaging to captivating stories 💟, Wesh keeps you in touch with what matters most 🫶

Make every occasion memorable and stay effortlessly connected with those who matter ⭐
<br><br><br>


# Features

- **Onboarding**: 
  - **Welcome Screen**: This is the first page you land on after you sign up
  - ![Video Preview](https://us-ms.gr-cdn.com/getresponse-tubnk/photos/71ad93cc-8833-469b-b99c-374e87060417.png)

- **Events**:
  - **Manage Events**: Create, edit, view, and add reminders to events of all sorts
  - ![Video Preview](https://us-ms.gr-cdn.com/getresponse-tubnk/photos/71ad93cc-8833-469b-b99c-374e87060417.png)

- **Stories**:
  - **Ephemeral Content**: Stories are content that stay on your profile for 24 hours. Share instant moments effortlessly
  - ![Video Preview](https://us-ms.gr-cdn.com/getresponse-tubnk/photos/71ad93cc-8833-469b-b99c-374e87060417.png)

- **Forevers**:
  - **Permanent Stories**: Save your stories forever, even after their 24-hour expiration
  - ![Video Preview](https://us-ms.gr-cdn.com/getresponse-tubnk/photos/71ad93cc-8833-469b-b99c-374e87060417.png)

- **Chats**:
  - **Real-Time Messaging**: Send real-time messages to your friends and followers, including videos, images, voice messages, money, gifts, etc.
  - ![Video Preview](https://us-ms.gr-cdn.com/getresponse-tubnk/photos/71ad93cc-8833-469b-b99c-374e87060417.png)

- **Profile**:
  - **Manage Your Data**: Control your events, reminders, followers, and personal data in one place
  - ![Video Preview](https://us-ms.gr-cdn.com/getresponse-tubnk/photos/71ad93cc-8833-469b-b99c-374e87060417.png)

- **Search**:
  - **Find What’s Happening**: Search for events and people, applying powerful filters to find anything and anyone
  - ![Video Preview](https://us-ms.gr-cdn.com/getresponse-tubnk/photos/71ad93cc-8833-469b-b99c-374e87060417.png)

- **Share & Forward**:
  - **Content Sharing**: Share interesting content from the internet with your followers. And vice-versa: share useful content with people outside of Wesh
  - ![Video Preview](https://us-ms.gr-cdn.com/getresponse-tubnk/photos/71ad93cc-8833-469b-b99c-374e87060417.png)

- **Special Happy Birthday**:
  - **Birthday Wishes**: Wesh takes events seriously and ensures you receive a special wish on your day :)
  - ![Video Preview](https://us-ms.gr-cdn.com/getresponse-tubnk/photos/71ad93cc-8833-469b-b99c-374e87060417.png)

- **Help Center**:
  - **Support and Answers**: Get answers and support. The Help Center will assist you with any issues
  - ![Video Preview](https://us-ms.gr-cdn.com/getresponse-tubnk/photos/71ad93cc-8833-469b-b99c-374e87060417.png)


<br>
You can find a complete walkthrough here:<br>
🔗 [Wesh.com](https://wesh.royalgaetan.com)

<br><br>

## Tech Stack & Behind the Scenes

### 🛠️ How is Wesh Built?
Wesh is crafted with a blend of cutting-edge technologies. For the mobile experience on both Android and iOS, we use **Flutter**, providing a smooth and responsive interface. 

On the backend, we rely on **Firebase** to handle data storage, authentication, and real-time updates. 

Developing the first version of Wesh took a dedicated three months of full-time effort, and we’re excited to continue evolving it!
<br><br>

### 🚀 What Problems Are We Solving?
In today’s fast-paced world, it's easy to forget important moments or events that could make a big difference in our lives. 

Wesh addresses this by keeping you connected with the events and people that matter most. 

Our goal is to help you cherish those moments and stay engaged with your loved ones in a dynamic, social-like environment.
<br><br>

### 🔍 What Challenges Did We Face?
Building a social media app from scratch is no small feat. We faced numerous challenges, including managing time and resources effectively, defining our target audience, and developing a cohesive app architecture. 

Initially, we underestimated some features, which turned out to be more complex and time-consuming than anticipated. Despite these hurdles, the journey has been incredibly rewarding.
<br><br>

### 📚 What Did We Learn?
The process of developing Wesh has taught us that **great things take time and dedication**. 

We’ve gained valuable insights into design, user experience, project architecture, and clean coding practices. 

Additionally, we’ve deepened our understanding of algorithms and the inner workings of both Android and iOS platforms. 

Not to mention, we've learned how to effectively market and present our app to the world.
<br><br><br>

# Wesh v0.3 Roadmap 🚀

This roadmap outlines the key features and improvements planned for the upcoming version 0.3 of Wesh. 

Our focus is on enhancing performance, integrating new functionalities, refining user experience, and ensuring overall app stability. 

The high-priority tasks include reducing jank frames, integrating external calendars, improving authentication processes, and adding more interactive features. 

We also aim to improve notifications 🔔, optimize search 🔍 and profile functionalities 👤, and provide better internationalization support 🏳️

⭐ Our goal is to create a seamless and engaging experience for all users.
<br><br>

### High Priority 🔥
- **Performance**: Reduce all jank frames (use devTools)


### Features & Integrations 🌟
- **External Calendar Integration**: iCalendar, Google Calendar, Calendly. Visible in CalendarOption Modal: on Logo tap()
- **Calendar Views**: Monthly, Daily, etc. Visible in CalendarOption Modal: on Logo tap()
- **Custom Image/Video Picker**: Implement custom picker


### Major Fixes 🛠️
- **Notifications v2**:
  1. Fix notifications
  2. Fix reminders (trigger, add type: alarm/Notification) with CTA
- **GetX**: Integrate GetX for state management
- **User Notifications**: Notify user on "Follow"
- **Notifications Page**: Add a Notifications Page and its button in homepage: aka Activities Page
- **ML/AI Integration**: Add Event Suggestions or Recommendations via Notification


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
  - Review and test account linking and auth workflows


### General Improvements 🔧
- **Fonts**: Use only 1 or 2 fonts for the app
- **Image Cache & Loader**: Fix issues
- **Internationalization**: Allow users to change Time & Date format in settings
- **Markdown Support**: Accept markdown in text fields, message box, bio box, etc.
- **App Inactivity**: Handle app inactivity or background state


### Background Handler v2 🔄
- **UI & Logic**: Fix file uploads and downloads (including Inbox and Stories)


### Settings Page ⚙️
- **Language & Country**: Add options to change app language and country
- **Themes**: Dark/Light Mode switcher using Providers
- **App Version Trigger**: Notify user about new app versions


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
  - Attach money or in-app shop product as gifts


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
- **Global Important Dates**: Schedule important dates for Wesh Official


### Forward Page 📤
- **Loading Time**: Reduce loading time for recent chats list
- **Multi-Person Forwarding**: Allow forwarding to multiple persons at a time


### Forever Feature 🕒
- **Reorder Stories**: Allow drag-and-drop functionality to reorder stories


### Search Page 🔍
- **Suggestions**: Add suggestions/recommendations when empty
- **Search Optimization**: Perform search on server and apply pagination to results


### Profile Page 👤
- **Pagination**: Implement pagination for events list, reminders list, and forevers list
- **Account Information**: Request account information
- **Account Deletion**: Handle cascading deletions


### Permissions ✅
- **Fix Permissions**: Ask only when necessary


### Firebase Integration 🔥
- **Useful Plugins**: Install Performance, Crashlytics, etc.
- **App Check**: Enforce protections and register all apps
- **Firebase Rules**: Adjust Firestore and Storage rules


### Migrations & Adaptations 🔄
- **build.gradle**: Migrate to declarative approach
- **Dynamic Links**: Migrate to themedata and useMaterial3
- **Theme Adaptations**: Adapt Theme.of(context).colorScheme
- **Common Styles**: Establish a common method for getting colors, styles, etc.


### Future Updates 🔮
- **Create Event Page**: Add Live/Offline/Online/File event forms


### Help Center 📚
- **Update**: Refresh the Help Center once finished


### Code Clean-up 🧹
- **Refactoring**: Remake folder structure and file naming
- **Code Documentation**: Add proper code documentation


### Performance & CI/CD 🚀
- **App Size**: Reduce or optimize package usage
- **Setup CI/CD**: Remove all debugPrint() and Setup CodeMagic


<br><br>

# Contribute to Wesh

### 🤝 For Contributors

We’d love your help to make Wesh even better! If you have a fix for something on our roadmap or an awesome new idea, don’t hesitate to jump in. 

Just submit a pull request to tackle an issue or share your brilliant suggestions. 

Every contribution, big or small, is a step towards improving Wesh and making it a more amazing experience for everyone. 

Come join our community and help us shape the future of Wesh!

<br>

### 🌟 For Visitors

Feel free to explore, clone, or copy Wesh's code: it's open-source and FREE!!!

We hope you find it helpful to see how we solve problems and develop new features. 

Your thoughts and feedback are always welcome as we grow and evolve the project. 

Dive in, take a look around, and let’s make Wesh even better together! 🫶🔥

<br><br>
