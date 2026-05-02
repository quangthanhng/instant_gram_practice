import 'package:flutter/foundation.dart' show immutable;

@immutable
class Strings {
  static const appName = 'Instant-gram!';
  static const welcomeToAppName = 'Welcome to ${Strings.appName}';
  static const youHaveNoPost =
      'You have not made a post yet. Press either the video-upload or the photo-upload buttons to the top of the screen in order to upload your first post!';
  static const noPostsAvailable =
      "Nobody seems to have made any posts yet. Why don't you take a first step and upload your first post!";
  static const enterYourSearchTerm =
      'Enter your search term in order to get started. You can search in the description of all posts available in the system';
  static const facebook = ' Facebook ';
  static const facebookSignupUrl = 'https://www.facebook.com';
  static const google = ' Google ';
  static const googleSignupUrl = 'https://www.google.com';
  static const logIntoYourAcccount =
      'Log into your account using onew of the options below';
  static const comments = 'Comments';
  static const writeYourCommentHere = 'Write your comment here...';
  static const checkOutThisPost = 'Check out this post!';
  static const postDetails = 'Post Details';
  static const post = 'post';
  static const createNewPost = 'Create New Post';
  static const pleseWriteyourMessageHere = 'Please write your message here';

  static const noCommentsYet =
      'Nobody has commented on this post yet. You can change that though, and be the first person who comments';
  static const enterYourSearchTermHere = 'Enter your search term here';

  // login view rich text at the bottom
  static const dontHaveAnAccount = "Don't have an account?'\n";
  static const signUpOn = 'Sign Up On';
  static const orCreateAnAccountOn = ' or create an account on';
  const Strings._();
}
