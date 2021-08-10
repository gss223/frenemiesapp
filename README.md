Original App Design Project
===

# Frenemies

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
This is a friendly competition app where groups can create specific battles amongst themselves. For example, who can drink more water during the week. Images for proof can be submitted to keep players honest.

### Demo

[![IMAGE ALT TEXT](http://img.youtube.com/vi/YOUTUBE_VIDEO_ID_HERE/0.jpg)](https://www.youtube.com/watch?v=UooAGx6csrI "Frenemies Demo")

### App Evaluation
- **Category:** Social
- **Mobile:** Can have more real-time updates and watch some sort of progress bar. The app could also incorporate posting to social media for winning and photo galleries to track progress. Maps could also be a component for certain challenges.
- **Story:** This would be a good way to keep track of friendly competitions and also encourage people to have better habits by doing challenges together.
- **Market:** The market for this app would be any friend group. 
- **Habit:** This is pretty habit-forming because of the need to keep updating your status to stay on top of it
- **Scope:** This app seems in scope in terms of creating an app where "challenges" can be set with a time limit and users can post photos and see overall progress against each other.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [x] User can login
- [x] User can create an account
- [x] User can create a challenge
- [x] User can invite their friends
- [x] User can update their progress on the challenge
- [x] User can customize the numerical amount that it is counting (e.g. liters, miles, days, etc.)
- [x] User can post photos into an internal gallery 
- [x] User can set a time limit on a challenge
- [x] User can see their ranking on a certain challenge
- [x] User can see their ongoing challenges
- [x] User can find challenges
- [x] User can find friends
- [x] User can link to their Facebook and find facebook friends

**Optional Nice-to-have Stories**

- [x] User can watch a progress bar throughout the challenge
- [x] Public and private challenges
- [x] User can post completed challenges to social media
- [ ] User can add in maps for running challenges
- [ ] User can access HealthKit
- [ ] User can see trending challenges
- [ ] Generates photo highlight reel after challenge is over

### 2. Screen Archetypes

* Login Screen
   * User can login
* Registration Screen
   * User can create an account
* Profile Screen
   * User can invite friends
       * linking their account
* Settings Screen
    * User can edit some features
* Creation
   * User can create a challenge
   * User can set a time limit
* Challenge Screen
   * User can see a leaderboard
* Log Screen
    * User can update their progress
    * User can post photos
* Find friends Screen
    * User can invite friends
        * search for friends
* Search Screen
    * User can find challenges
* Stream
   * User can see their ongoing challenges

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home Feed
* Creation
* Search
* Find Friend
* Profile

**Flow Navigation** (Screen to Screen)

* Login Screen
   * Home
* Registration Screen
   * Home
* Settings Screen
   * None
* Creation Screen
   * Home (after done)
* Challenge Screen
    * Home (after done)
* Find Friend Screen
   * Creation Screen (select a group of friends)
* Search Screen
    * Home
* Stream Screen (home)
   * Challenge Screen
* Profile Screen
    * None

## Wireframes
<img src="https://github.com/gss223/frenemiesapp/blob/main/wireframe.jpg" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
### Models
**User**
| Property | Type | Description |
|----------|------|-------------|
| objectId |String|unique id for the user object(default field) |
| username         | String     | username            |
|password|String|password|
|profilePic|File|profile Image for the user|
|friends|String Array|array of objectids for friends|
|likes|String Array|array of objectids for liked challenges|
|completed|String Array|array of objectids for completed challenges|
|won|String Array|array of objectids for won challenges|

**Challenge**
| Property | Type | Description |
|----------|------|-------------|
| objectId |String|unique id for the challenge object(default field) |
|name|String|name of challenge|
|unit|String|unit used in challenge (liters, miles, etc.)|
|timeStart|DateTime|start time of challenge|
|timeEnd|DateTime|end time of challenge|
|createdAt|DateTime|when challenge was created|
|public|Bool|whether the challenge is public or not|
|likeCount|Number|number of likes|
|author|Pointer to user|author of challenge|
|complete|Bool|whether the challenge is done|

**Inbox**
| Property | Type | Description |
|----------|------|-------------|
| objectId |String|unique id (default field) |
|user1|Pointer to user|user that sent request|
|user2|Pointer to user|user that received the request|
|challenge|Pointer to challenge|challenge that was shared (optional)|

**Log**
| Property | Type | Description |
|----------|------|-------------|
| objectId |String|unique id (default field) |
|author|Pointer to user|author of the log|
|challenge|Pointer to challenge|challenge that is being logged to|
|image|File|image being logged|
|units|Number|number of units being logged|

**Participants**
| Property | Type | Description |
|----------|------|-------------|
| objectId |String|unique id (default field) |
|user|Pointer to user|user participating|
|challenge|Pointer to challenge|challenge that they are participating in|

### Networking
* Read/GET
```objectivec=
PFQuery *query = [PFQuery queryWithClassName:@"Challenge"];
[query whereKey:@"name" equalTo:@"water"];
[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
  if (!error) {
    // The find succeeded.
    NSLog(@"Successfully retrieved %d scores.", objects.count);
    // Do something with the found objects
    for (PFObject *object in objects) {
        NSLog(@"%@", object.objectId);
    }
  } else {
    // Log details of the failure
    NSLog(@"Error: %@ %@", error, [error userInfo]);
  }
}];
```
* Create/POST
```objectivec=
PFObject *challenge = [PFObject objectWithClassName:@"Challenge"];
challenge[@"name"] = @"water";
[challenge saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
  if (succeeded) {
    // The object has been saved.
  } else {
    // There was a problem, check error.description
  }
}];
```
* Update/PUT

```objectivec=
PFQuery *query = [PFQuery queryWithClassName:@"Challenge"];

// Retrieve the object by id
[query getObjectInBackgroundWithId:@"someId"
                             block:^(PFObject *challenge, NSError *error) {
    challenge[@"name"] = @"new";
    [challenge saveInBackground];
}];
```


**Screens**
* Login Screen
   * (Read/GET) Query to see if user exists
* Registration Screen
   * (Create/POST) Create a new user
* Profile Screen
   * (Read/GET) Query to see user profile
   * (Update/PUT) Update user profile image
* Creation
   * (Create/POST) Create a new challenge object
   * (Create/POST) Create a new inbox object
   * (Update/PUT) Update user challenges
* Challenge Screen
   * (Read/GET) Query to get challenge object
   * (Read/GET) Query to get participants
   * (Read/GET) Query to get log
   * (Create/POST) Create a new inbox object
* Log Screen
    * (Create/POST) Create a new log object
* Find friends Screen
    * (Create/POST) Create a new inbox object
    * (Read/GET) Query to get user objects
* Search Screen
    * (Read/GET) Query to get challenge object
    * (Update/PUT) Update user challenges
    * (Create/POST) Create a new participant object
* Stream
   * (Read/GET) Query to get challenge object
   * (Read/GET) Query to get user object
    * (Update/PUT) Update user challenges
    * (Create/POST) Create a new participant object
* Inbox
   * (Create/POST) Create a new participant object
   * (Update/PUT) Update user challenges
   * (Update/PUT) Update user friends
- [OPTIONAL: List endpoints if using existing API such as Yelp]
