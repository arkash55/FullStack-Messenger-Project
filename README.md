# FullStack-Messenger-Project

A full stack real time messenger clone. Frontend is written in swift, and the backend is written in javascript. 

The Frontend...
- MVC design pattern.
- UI designed using a combination of programatic code and storyboard.
- UI designed for text, photo and video messages.
- Used protocols and delegates to pass information between view controllers.
- Used notifications and observers to notify the app for changes in state (e.g logged_in, logged_out)
- Vigorous error handling system
- TypeAliases, Structs and Enums used to keep code more maintainable and DRY.
- Deletion and Sorting algorithms used to show appropriate data. (Linear deletion and quicksort)
- Used Cocoapods and SwiftPackageManager to access different utilities such as Amplify and SDWebImage.


The Backend...
- REST API created with express js
- Websockets implemented via socket io
- Authentication implmented using json-web-tokens. ("npm jsonwebtoken")
- Implemented Email verification on registration (needs to fixed after google made changes in SMTP and third party app rules.)
- Implemented hashing and salting algorithms to store sensitive data with the aid of an cryptography package. ("npm crypto-js")
- Used postgresql with the Sequelize ORM to store and manage relation data.
- Used AWS S3 to store images and videos. Implemented S3 in the frontend to reduce request times and server stress.
- Used redis to cache frequently called data, reducing database queries and increasing request speeds by up to 10 times.


Things I can add/improve on...
- Add additional "prior-update_time" column to conversation table in the database. This will allow for deletion via binary search improving
  the time complexity to O(log2N) from 0(N).
  (Alternatively, I could use a binary search tree to store conversations, this will allow for binary search without needing to add a extra
  colomn in my dataabase.)
- Push Notifications
- 2FA Authentication
