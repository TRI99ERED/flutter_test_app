import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'locales/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Test App'**
  String get appTitle;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @systemLabel.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLabel;

  /// No description provided for @lightLabel.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightLabel;

  /// No description provided for @darkLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkLabel;

  /// No description provided for @unknownChatterLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownChatterLabel;

  /// No description provided for @unknownChattersLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownChattersLabel;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingLabel;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @userNotFoundLabel.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFoundLabel;

  /// No description provided for @failedToLoadUnreadCountMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load unread count'**
  String get failedToLoadUnreadCountMessage;

  /// No description provided for @failedToLoadUnreadCountsMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load unread counts'**
  String get failedToLoadUnreadCountsMessage;

  /// No description provided for @failedToLoadChatDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chat data'**
  String get failedToLoadChatDataMessage;

  /// No description provided for @saveMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Save message'**
  String get saveMessageLabel;

  /// No description provided for @messageSavedLabel.
  ///
  /// In en, this message translates to:
  /// **'Message saved'**
  String get messageSavedLabel;

  /// No description provided for @failedToLoadCHatMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chat'**
  String get failedToLoadCHatMessage;

  /// No description provided for @enterConfirmationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter confirmation code'**
  String get enterConfirmationCodeLabel;

  /// No description provided for @yourEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'your email'**
  String get yourEmailLabel;

  /// No description provided for @codeSentLabel.
  ///
  /// In en, this message translates to:
  /// **'A 4-digit code was sent to'**
  String get codeSentLabel;

  /// No description provided for @resendCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCodeLabel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @resetPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordLabel;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddressLabel;

  /// No description provided for @sendPasswordResetEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Send Password Reset Email'**
  String get sendPasswordResetEmailLabel;

  /// No description provided for @backToLoginLabel.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLoginLabel;

  /// No description provided for @chatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// No description provided for @friendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsTitle;

  /// No description provided for @projectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @userNotAuthorizedMessage.
  ///
  /// In en, this message translates to:
  /// **'User not authorized'**
  String get userNotAuthorizedMessage;

  /// No description provided for @errorLoadingChatsMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading chats'**
  String get errorLoadingChatsMessage;

  /// No description provided for @nothingHereForNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Nothing here. For now'**
  String get nothingHereForNowLabel;

  /// No description provided for @thisIsWhereYourChatsGoLabel.
  ///
  /// In en, this message translates to:
  /// **'This is where your chats go.'**
  String get thisIsWhereYourChatsGoLabel;

  /// No description provided for @startAChatLabel.
  ///
  /// In en, this message translates to:
  /// **'Start a chat'**
  String get startAChatLabel;

  /// No description provided for @noChatsFoundLabel.
  ///
  /// In en, this message translates to:
  /// **'No chats found.'**
  String get noChatsFoundLabel;

  /// No description provided for @tryAdjustingYourSearchQueryLabel.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search query.'**
  String get tryAdjustingYourSearchQueryLabel;

  /// No description provided for @noMessagesYetLabel.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYetLabel;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @editLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editLabel;

  /// No description provided for @incomingTitle.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get incomingTitle;

  /// No description provided for @outgoingTitle.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get outgoingTitle;

  /// No description provided for @invalidSectionIndexMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid section index'**
  String get invalidSectionIndexMessage;

  /// No description provided for @errorLoadingFriendsMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading friends'**
  String get errorLoadingFriendsMessage;

  /// No description provided for @errorLoadingIncomingRequestsMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading incoming requests'**
  String get errorLoadingIncomingRequestsMessage;

  /// No description provided for @errorLoadingOutgoingRequestsMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading outgoing requests'**
  String get errorLoadingOutgoingRequestsMessage;

  /// No description provided for @thisIsWhereYourFriendsWillAppearLabel.
  ///
  /// In en, this message translates to:
  /// **'This is where your friends will appear.'**
  String get thisIsWhereYourFriendsWillAppearLabel;

  /// No description provided for @thisIsWhereYourIncomingRequestsWillAppearLabel.
  ///
  /// In en, this message translates to:
  /// **'This is where your incoming requests will appear.'**
  String get thisIsWhereYourIncomingRequestsWillAppearLabel;

  /// No description provided for @thisIsWhereYourOutgoingRequestsWillAppearLabel.
  ///
  /// In en, this message translates to:
  /// **'This is where your outgoing requests will appear.'**
  String get thisIsWhereYourOutgoingRequestsWillAppearLabel;

  /// No description provided for @sendFriendRequestLabel.
  ///
  /// In en, this message translates to:
  /// **'Send friend request'**
  String get sendFriendRequestLabel;

  /// No description provided for @noFriendsFoundLabel.
  ///
  /// In en, this message translates to:
  /// **'No friends found.'**
  String get noFriendsFoundLabel;

  /// No description provided for @noIncomingRequestsFoundLabel.
  ///
  /// In en, this message translates to:
  /// **'No incoming requests found.'**
  String get noIncomingRequestsFoundLabel;

  /// No description provided for @noOutgoingRequestsFoundLabel.
  ///
  /// In en, this message translates to:
  /// **'No outgoing requests found.'**
  String get noOutgoingRequestsFoundLabel;

  /// No description provided for @errorLoadingFriend.
  ///
  /// In en, this message translates to:
  /// **'Error loading a friend'**
  String get errorLoadingFriend;

  /// No description provided for @errorLoadingIncomingRequest.
  ///
  /// In en, this message translates to:
  /// **'Error loading an incoming request'**
  String get errorLoadingIncomingRequest;

  /// No description provided for @errorLoadingOutgoingRequest.
  ///
  /// In en, this message translates to:
  /// **'Error loading an outgoing request'**
  String get errorLoadingOutgoingRequest;

  /// No description provided for @declineLabel.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineLabel;

  /// No description provided for @removeLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeLabel;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageLabel;

  /// No description provided for @acceptLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptLabel;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @toDoLabel.
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get toDoLabel;

  /// No description provided for @inProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressLabel;

  /// No description provided for @finishedLabel.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finishedLabel;

  /// No description provided for @lastUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'LAST UPDATED'**
  String get lastUpdatedLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get nameLabel;

  /// No description provided for @createdAtLabel.
  ///
  /// In en, this message translates to:
  /// **'CREATED AT'**
  String get createdAtLabel;

  /// No description provided for @creatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creatorTitle;

  /// No description provided for @errorLoadingToDoProjectsMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading to-do projects'**
  String get errorLoadingToDoProjectsMessage;

  /// No description provided for @errorLoadingInProgressProjectsMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading in-progress projects'**
  String get errorLoadingInProgressProjectsMessage;

  /// No description provided for @errorLoadingFinishedProjectsMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading finished projects'**
  String get errorLoadingFinishedProjectsMessage;

  /// No description provided for @thisIsWhereYoullfindYourToDoProjectsLabel.
  ///
  /// In en, this message translates to:
  /// **'This is where you\'ll find your to-do projects.'**
  String get thisIsWhereYoullfindYourToDoProjectsLabel;

  /// No description provided for @thisIsWhereYoullfindYourInProgressProjectsLabel.
  ///
  /// In en, this message translates to:
  /// **'This is where you\'ll find your in-progress projects.'**
  String get thisIsWhereYoullfindYourInProgressProjectsLabel;

  /// No description provided for @thisIsWhereYoullfindYourFinishedProjectsLabel.
  ///
  /// In en, this message translates to:
  /// **'This is where you\'ll find your finished projects.'**
  String get thisIsWhereYoullfindYourFinishedProjectsLabel;

  /// No description provided for @startAProjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Start a project'**
  String get startAProjectLabel;

  /// No description provided for @noDescriptionProvidedLabel.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get noDescriptionProvidedLabel;

  /// No description provided for @savedMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Messages'**
  String get savedMessagesTitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @logOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutLabel;

  /// No description provided for @areYouSureYouWantToLogOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out? You\'ll need to login again to use the app.'**
  String get areYouSureYouWantToLogOutLabel;

  /// No description provided for @userInterfaceLabel.
  ///
  /// In en, this message translates to:
  /// **'User Interface'**
  String get userInterfaceLabel;

  /// No description provided for @userExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'User Experience'**
  String get userExperienceLabel;

  /// No description provided for @userResearchLabel.
  ///
  /// In en, this message translates to:
  /// **'User Research'**
  String get userResearchLabel;

  /// No description provided for @uxWritingLabel.
  ///
  /// In en, this message translates to:
  /// **'UX Writing'**
  String get uxWritingLabel;

  /// No description provided for @userTestingLabel.
  ///
  /// In en, this message translates to:
  /// **'User Testing'**
  String get userTestingLabel;

  /// No description provided for @serviceDesignLabel.
  ///
  /// In en, this message translates to:
  /// **'Service Design'**
  String get serviceDesignLabel;

  /// No description provided for @strategyLabel.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get strategyLabel;

  /// No description provided for @designSystemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Design Systems'**
  String get designSystemsLabel;

  /// No description provided for @prototypingLabel.
  ///
  /// In en, this message translates to:
  /// **'Prototyping'**
  String get prototypingLabel;

  /// No description provided for @accessibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibilityLabel;

  /// No description provided for @collaborationLabel.
  ///
  /// In en, this message translates to:
  /// **'Collaboration'**
  String get collaborationLabel;

  /// No description provided for @projectManagementLabel.
  ///
  /// In en, this message translates to:
  /// **'Project Management'**
  String get projectManagementLabel;

  /// No description provided for @innovationLabel.
  ///
  /// In en, this message translates to:
  /// **'Innovation'**
  String get innovationLabel;

  /// No description provided for @entrepreneurshipLabel.
  ///
  /// In en, this message translates to:
  /// **'Entrepreneurship'**
  String get entrepreneurshipLabel;

  /// No description provided for @marketingLabel.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get marketingLabel;

  /// No description provided for @personalizeYourExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Personalize your experience'**
  String get personalizeYourExperienceLabel;

  /// No description provided for @chooseYourInterestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose your interests.'**
  String get chooseYourInterestsLabel;

  /// No description provided for @nextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextLabel;

  /// No description provided for @welcomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @forgotPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordLabel;

  /// No description provided for @loginLabel.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLabel;

  /// No description provided for @notAMemberLabel.
  ///
  /// In en, this message translates to:
  /// **'Not a member?'**
  String get notAMemberLabel;

  /// No description provided for @registerNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get registerNowLabel;

  /// No description provided for @orContinueWithLabel.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWithLabel;

  /// No description provided for @googleSignInIsNotAvailableOnWebLabel.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In is not available on web'**
  String get googleSignInIsNotAvailableOnWebLabel;

  /// No description provided for @appleSignInNotImplementedLabel.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-In is not implemented'**
  String get appleSignInNotImplementedLabel;

  /// No description provided for @facebookSignInNotImplementedLabel.
  ///
  /// In en, this message translates to:
  /// **'Facebook Sign-In is not implemented'**
  String get facebookSignInNotImplementedLabel;

  /// No description provided for @enablePushNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable push notifications'**
  String get enablePushNotificationsLabel;

  /// No description provided for @enableFriendRequestNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable friend request notifications'**
  String get enableFriendRequestNotificationsLabel;

  /// No description provided for @enableProjectInviteNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable project invite notifications'**
  String get enableProjectInviteNotificationsLabel;

  /// No description provided for @enableMessageNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable message notifications'**
  String get enableMessageNotificationsLabel;

  /// No description provided for @systemNotificationsSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'System notifications settings'**
  String get systemNotificationsSettingsLabel;

  /// No description provided for @createAPrototypeInJustAFewMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Create a prototype in just a few minutes'**
  String get createAPrototypeInJustAFewMinutesLabel;

  /// No description provided for @collaborateWithYourTeamSeamlesslyLabel.
  ///
  /// In en, this message translates to:
  /// **'Collaborate with your team seamlessly'**
  String get collaborateWithYourTeamSeamlesslyLabel;

  /// No description provided for @launchYourProjectWithConfidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Launch your project with confidence'**
  String get launchYourProjectWithConfidenceLabel;

  /// No description provided for @enjoyThesePreMadeComponentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Enjoy these pre-made components and worry only about creating the best product ever.'**
  String get enjoyThesePreMadeComponentsLabel;

  /// No description provided for @workTogetherWithYourTeamLabel.
  ///
  /// In en, this message translates to:
  /// **'Work together with your team in real-time, from anywhere in the world.'**
  String get workTogetherWithYourTeamLabel;

  /// No description provided for @launchYourProjectWithConfidenceAndEaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Launch your project with confidence and ease, knowing that you\'ve tested it with real users and iterated based on their feedback.'**
  String get launchYourProjectWithConfidenceAndEaseLabel;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// No description provided for @yourProjectIsFinishedLabel.
  ///
  /// In en, this message translates to:
  /// **'Your project is finished.'**
  String get yourProjectIsFinishedLabel;

  /// No description provided for @howWouldYouRateThePrototypingKitLabel.
  ///
  /// In en, this message translates to:
  /// **'How would you rate the prototyping kit?'**
  String get howWouldYouRateThePrototypingKitLabel;

  /// No description provided for @whatDidYouLikeAboutItLabel.
  ///
  /// In en, this message translates to:
  /// **'What did you like about it?'**
  String get whatDidYouLikeAboutItLabel;

  /// No description provided for @easyToUseLabel.
  ///
  /// In en, this message translates to:
  /// **'EASY TO USE'**
  String get easyToUseLabel;

  /// No description provided for @completeLabel.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE'**
  String get completeLabel;

  /// No description provided for @helpfulLabel.
  ///
  /// In en, this message translates to:
  /// **'HELPFUL'**
  String get helpfulLabel;

  /// No description provided for @convenientLabel.
  ///
  /// In en, this message translates to:
  /// **'CONVENIENT'**
  String get convenientLabel;

  /// No description provided for @looksGoodLabel.
  ///
  /// In en, this message translates to:
  /// **'LOOKS GOOD'**
  String get looksGoodLabel;

  /// No description provided for @whatCouldBeImprovedLabel.
  ///
  /// In en, this message translates to:
  /// **'What could be improved?'**
  String get whatCouldBeImprovedLabel;

  /// No description provided for @couldHaveMoreComponentsLabel.
  ///
  /// In en, this message translates to:
  /// **'COULD HAVE MORE COMPONENTS'**
  String get couldHaveMoreComponentsLabel;

  /// No description provided for @complexLabel.
  ///
  /// In en, this message translates to:
  /// **'COMPLEX'**
  String get complexLabel;

  /// No description provided for @notInteractiveLabel.
  ///
  /// In en, this message translates to:
  /// **'NOT INTERACTIVE'**
  String get notInteractiveLabel;

  /// No description provided for @onlyEnglishLabel.
  ///
  /// In en, this message translates to:
  /// **'ONLY ENGLISH'**
  String get onlyEnglishLabel;

  /// No description provided for @anythingElseLabel.
  ///
  /// In en, this message translates to:
  /// **'Anything else?'**
  String get anythingElseLabel;

  /// No description provided for @tellUsEverythingLabel.
  ///
  /// In en, this message translates to:
  /// **'Tell us everything.'**
  String get tellUsEverythingLabel;

  /// No description provided for @submitLabel.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitLabel;

  /// No description provided for @feedbackSubmittedLabel.
  ///
  /// In en, this message translates to:
  /// **'Feedback submitted!'**
  String get feedbackSubmittedLabel;

  /// No description provided for @projectNotFoundLabel.
  ///
  /// In en, this message translates to:
  /// **'Project not found'**
  String get projectNotFoundLabel;

  /// No description provided for @errorLoadingProjectMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading project'**
  String get errorLoadingProjectMessage;

  /// No description provided for @projectWithIdNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Project with id {projectId} not found'**
  String projectWithIdNotFoundMessage(Object projectId);

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @deadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadlineLabel;

  /// No description provided for @projectCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Project completed! Please provide your feedback.'**
  String get projectCompletedLabel;

  /// No description provided for @provideFeedbackLabel.
  ///
  /// In en, this message translates to:
  /// **'Provide Feedback'**
  String get provideFeedbackLabel;

  /// No description provided for @createdByUnknownLabel.
  ///
  /// In en, this message translates to:
  /// **'Created by unknown'**
  String get createdByUnknownLabel;

  /// No description provided for @createdByLabel.
  ///
  /// In en, this message translates to:
  /// **'Created by {creatorHandle}'**
  String createdByLabel(Object creatorHandle);

  /// No description provided for @atLabel.
  ///
  /// In en, this message translates to:
  /// **'at {time}'**
  String atLabel(Object time);

  /// No description provided for @lastUpdatedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Last updated at {time}'**
  String lastUpdatedAtLabel(Object time);

  /// No description provided for @participantsLabel.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participantsLabel;

  /// No description provided for @chatLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatLabel;

  /// No description provided for @createChatLabel.
  ///
  /// In en, this message translates to:
  /// **'Create Chat'**
  String get createChatLabel;

  /// No description provided for @noOtherParticipantsMessage.
  ///
  /// In en, this message translates to:
  /// **'No other participants found for project.'**
  String get noOtherParticipantsMessage;

  /// No description provided for @noGroupChatFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No group chat found for this project. Please ask the project owner to create one.'**
  String get noGroupChatFoundMessage;

  /// No description provided for @projectTitle.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get projectTitle;

  /// No description provided for @errorLoadingParticipantsMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading participants'**
  String get errorLoadingParticipantsMessage;

  /// No description provided for @noParticipantsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No participants found.'**
  String get noParticipantsFoundMessage;

  /// No description provided for @signUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Sign up!'**
  String get signUpLabel;

  /// No description provided for @createAnAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Create an account to get started'**
  String get createAnAccountLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @pleaseConfirmYourPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmYourPasswordMessage;

  /// No description provided for @passwordsDoNotMatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatchMessage;

  /// No description provided for @passwordMustBeAtLeast8CharactersMessage.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMustBeAtLeast8CharactersMessage;

  /// No description provided for @passwordMustContainAtLeastOneUppercaseLetterMessage.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordMustContainAtLeastOneUppercaseLetterMessage;

  /// No description provided for @passwordMustContainAtLeastOneLowercaseLetterMessage.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter'**
  String get passwordMustContainAtLeastOneLowercaseLetterMessage;

  /// No description provided for @passwordMustContainAtLeastOneNumberMessage.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get passwordMustContainAtLeastOneNumberMessage;

  /// No description provided for @iveReadAndAgreeWithTermsAndConditionsLabel.
  ///
  /// In en, this message translates to:
  /// **'I\'ve read and agree with the Terms and Conditions and the Privacy Policy.'**
  String get iveReadAndAgreeWithTermsAndConditionsLabel;

  /// No description provided for @registerLabel.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerLabel;

  /// No description provided for @alreadyHaveAnAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccountLabel;

  /// No description provided for @failedToLoadSavedMessagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Failed to load saved messages'**
  String get failedToLoadSavedMessagesLabel;

  /// No description provided for @noSavedMessagesLabel.
  ///
  /// In en, this message translates to:
  /// **'No saved messages'**
  String get noSavedMessagesLabel;

  /// No description provided for @yourSavedMessagesWillAppearHereLabel.
  ///
  /// In en, this message translates to:
  /// **'Your saved messages will appear here.'**
  String get yourSavedMessagesWillAppearHereLabel;

  /// No description provided for @goToDirectChatLabel.
  ///
  /// In en, this message translates to:
  /// **'Go to direct chat'**
  String get goToDirectChatLabel;

  /// No description provided for @goToGroupChatLabel.
  ///
  /// In en, this message translates to:
  /// **'Go to group chat'**
  String get goToGroupChatLabel;

  /// No description provided for @deleteSavedMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete saved message'**
  String get deleteSavedMessageLabel;

  /// No description provided for @janLabel.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get janLabel;

  /// No description provided for @febLabel.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get febLabel;

  /// No description provided for @marLabel.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get marLabel;

  /// No description provided for @aprLabel.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get aprLabel;

  /// No description provided for @mayLabel.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get mayLabel;

  /// No description provided for @junLabel.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get junLabel;

  /// No description provided for @julLabel.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get julLabel;

  /// No description provided for @augLabel.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get augLabel;

  /// No description provided for @sepLabel.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sepLabel;

  /// No description provided for @octLabel.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get octLabel;

  /// No description provided for @novLabel.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get novLabel;

  /// No description provided for @decLabel.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get decLabel;

  /// No description provided for @moLabel.
  ///
  /// In en, this message translates to:
  /// **'MO'**
  String get moLabel;

  /// No description provided for @tuLabel.
  ///
  /// In en, this message translates to:
  /// **'TU'**
  String get tuLabel;

  /// No description provided for @weLabel.
  ///
  /// In en, this message translates to:
  /// **'WE'**
  String get weLabel;

  /// No description provided for @thLabel.
  ///
  /// In en, this message translates to:
  /// **'TH'**
  String get thLabel;

  /// No description provided for @frLabel.
  ///
  /// In en, this message translates to:
  /// **'FR'**
  String get frLabel;

  /// No description provided for @saLabel.
  ///
  /// In en, this message translates to:
  /// **'SA'**
  String get saLabel;

  /// No description provided for @suLabel.
  ///
  /// In en, this message translates to:
  /// **'SU'**
  String get suLabel;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTitle;

  /// No description provided for @clearAllLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllLabel;

  /// No description provided for @applyFiltersLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFiltersLabel;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @recentSearchesLabel.
  ///
  /// In en, this message translates to:
  /// **'RECENT SEARCHES'**
  String get recentSearchesLabel;

  /// No description provided for @noRecentSearchesFoundLabel.
  ///
  /// In en, this message translates to:
  /// **'No recent searches found'**
  String get noRecentSearchesFoundLabel;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTitle;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @sortOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get sortOrderLabel;

  /// No description provided for @descendingLabel.
  ///
  /// In en, this message translates to:
  /// **'DESCENDING'**
  String get descendingLabel;

  /// No description provided for @ascendingLabel.
  ///
  /// In en, this message translates to:
  /// **'ASCENDING'**
  String get ascendingLabel;

  /// No description provided for @sortByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortByLabel;

  /// No description provided for @applySortLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply Sort'**
  String get applySortLabel;

  /// No description provided for @emailIsRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequiredMessage;

  /// No description provided for @invalidEmailFormatMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormatMessage;

  /// No description provided for @numberIsRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Number is required'**
  String get numberIsRequiredMessage;

  /// No description provided for @mustBeAValidNumberMessage.
  ///
  /// In en, this message translates to:
  /// **'Must be a valid number'**
  String get mustBeAValidNumberMessage;

  /// No description provided for @mustBeAValidDecimalMessage.
  ///
  /// In en, this message translates to:
  /// **'Must be a valid decimal'**
  String get mustBeAValidDecimalMessage;

  /// No description provided for @phoneNumberIsRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberIsRequiredMessage;

  /// No description provided for @phoneNumberMustBeAtLeast10DigitsMessage.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least 10 digits'**
  String get phoneNumberMustBeAtLeast10DigitsMessage;

  /// No description provided for @invalidPhoneNumberFormatMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number format'**
  String get invalidPhoneNumberFormatMessage;

  /// No description provided for @urlIsRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'URL is required'**
  String get urlIsRequiredMessage;

  /// No description provided for @urlMustStartWithHttpMessage.
  ///
  /// In en, this message translates to:
  /// **'URL must start with http:// or https://'**
  String get urlMustStartWithHttpMessage;

  /// No description provided for @thisFieldIsRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get thisFieldIsRequiredMessage;

  /// No description provided for @nameIsRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequiredMessage;

  /// No description provided for @nameMustBeAtLeast2CharactersMessage.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMustBeAtLeast2CharactersMessage;

  /// No description provided for @nameMustContainLettersSpacesHyphensNumbersAndPeriodsMessage.
  ///
  /// In en, this message translates to:
  /// **'Name must contain only letters, spaces, hyphens, numbers and periods'**
  String get nameMustContainLettersSpacesHyphensNumbersAndPeriodsMessage;

  /// No description provided for @addressIsRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressIsRequiredMessage;

  /// No description provided for @addressMustBeAtLeast5CharactersMessage.
  ///
  /// In en, this message translates to:
  /// **'Address must be at least 5 characters'**
  String get addressMustBeAtLeast5CharactersMessage;

  /// No description provided for @dateTimeIsRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Date/time is required'**
  String get dateTimeIsRequiredMessage;

  /// No description provided for @passwordIsRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordIsRequiredMessage;

  /// No description provided for @createAChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a chat'**
  String get createAChatTitle;

  /// No description provided for @editChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit chat'**
  String get editChatTitle;

  /// No description provided for @addAParticipantLabel.
  ///
  /// In en, this message translates to:
  /// **'Add a participant'**
  String get addAParticipantLabel;

  /// No description provided for @chatNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat name'**
  String get chatNameLabel;

  /// No description provided for @enterChatNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter chat name'**
  String get enterChatNameLabel;

  /// No description provided for @pickAnAvatarLabel.
  ///
  /// In en, this message translates to:
  /// **'Pick an avatar'**
  String get pickAnAvatarLabel;

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @createAProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a Project'**
  String get createAProjectTitle;

  /// No description provided for @editProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Project'**
  String get editProjectTitle;

  /// No description provided for @projectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectNameLabel;

  /// No description provided for @enterProjectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter project name'**
  String get enterProjectNameLabel;

  /// No description provided for @enterProjectDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter project description'**
  String get enterProjectDescriptionLabel;

  /// No description provided for @setDeadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Set Deadline'**
  String get setDeadlineLabel;

  /// No description provided for @selectAFriendLabel.
  ///
  /// In en, this message translates to:
  /// **'Select a friend'**
  String get selectAFriendLabel;

  /// No description provided for @selectAUserLabel.
  ///
  /// In en, this message translates to:
  /// **'Select a user'**
  String get selectAUserLabel;

  /// No description provided for @usersLabel.
  ///
  /// In en, this message translates to:
  /// **'users'**
  String get usersLabel;

  /// No description provided for @noFriendsMatchYourSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'No friends match your search'**
  String get noFriendsMatchYourSearchLabel;

  /// No description provided for @noUsersMatchYourSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'No users match your search'**
  String get noUsersMatchYourSearchLabel;

  /// No description provided for @userProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfileTitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @handleLabel.
  ///
  /// In en, this message translates to:
  /// **'Handle'**
  String get handleLabel;

  /// No description provided for @enterYourNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourNameLabel;

  /// No description provided for @errorLoadingUsersMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading users'**
  String get errorLoadingUsersMessage;

  /// No description provided for @enterYourHandleLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter your handle'**
  String get enterYourHandleLabel;

  /// No description provided for @handleCannotContainSpacesMessage.
  ///
  /// In en, this message translates to:
  /// **'Handle cannot contain spaces'**
  String get handleCannotContainSpacesMessage;

  /// No description provided for @handleCanOnlyContainLettersNumbersAndUnderscoresMessage.
  ///
  /// In en, this message translates to:
  /// **'Handle can only contain letters, numbers and underscores'**
  String get handleCanOnlyContainLettersNumbersAndUnderscoresMessage;

  /// No description provided for @handleIsAlreadyTakenMessage.
  ///
  /// In en, this message translates to:
  /// **'Handle is already taken'**
  String get handleIsAlreadyTakenMessage;

  /// No description provided for @englishLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLabel;

  /// No description provided for @ukrainianLabel.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get ukrainianLabel;

  /// No description provided for @copyMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy message'**
  String get copyMessageLabel;

  /// No description provided for @messageCopiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get messageCopiedLabel;

  /// No description provided for @dateSeparatorLabel.
  ///
  /// In en, this message translates to:
  /// **'{month} {day}, {year}'**
  String dateSeparatorLabel(Object day, Object month, Object year);

  /// No description provided for @ofJanuaryLabel.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get ofJanuaryLabel;

  /// No description provided for @ofFebruaryLabel.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get ofFebruaryLabel;

  /// No description provided for @ofMarchLabel.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get ofMarchLabel;

  /// No description provided for @ofAprilLabel.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get ofAprilLabel;

  /// No description provided for @ofMayLabel.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get ofMayLabel;

  /// No description provided for @ofJuneLabel.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get ofJuneLabel;

  /// No description provided for @ofJulyLabel.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get ofJulyLabel;

  /// No description provided for @ofAugustLabel.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get ofAugustLabel;

  /// No description provided for @ofSeptemberLabel.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get ofSeptemberLabel;

  /// No description provided for @ofOctoberLabel.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get ofOctoberLabel;

  /// No description provided for @ofNovemberLabel.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get ofNovemberLabel;

  /// No description provided for @ofDecemberLabel.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get ofDecemberLabel;

  /// No description provided for @deleteChatLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete chat?'**
  String get deleteChatLabel;

  /// No description provided for @deleteChatConfirmationLabel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this chat? This action cannot be undone.'**
  String get deleteChatConfirmationLabel;

  /// No description provided for @removeFriendLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove friend?'**
  String get removeFriendLabel;

  /// No description provided for @removeFriendConfirmationLabel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {friend} from your friends? This action cannot be undone.'**
  String removeFriendConfirmationLabel(Object friend);

  /// No description provided for @deleteProjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete project?'**
  String get deleteProjectLabel;

  /// No description provided for @deleteProjectConfirmationLabel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete project {project}? This action cannot be undone.'**
  String deleteProjectConfirmationLabel(Object project);

  /// No description provided for @addImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Add images'**
  String get addImageLabel;

  /// No description provided for @typeAMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessageLabel;

  /// No description provided for @viewChatTitle.
  ///
  /// In en, this message translates to:
  /// **'View Chat'**
  String get viewChatTitle;

  /// No description provided for @deleteMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get deleteMessageLabel;

  /// No description provided for @confirmDeleteMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message? This action cannot be undone.'**
  String get confirmDeleteMessageLabel;

  /// No description provided for @replyToMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Reply to message'**
  String get replyToMessageLabel;

  /// No description provided for @replyingToLabel.
  ///
  /// In en, this message translates to:
  /// **'Replying to'**
  String get replyingToLabel;

  /// No description provided for @tasksLabel.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksLabel;

  /// No description provided for @addTaskLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTaskLabel;

  /// No description provided for @createATaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a Task'**
  String get createATaskTitle;

  /// No description provided for @editTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTaskTitle;

  /// No description provided for @taskTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitleLabel;

  /// No description provided for @enterTaskTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter task title'**
  String get enterTaskTitleLabel;

  /// No description provided for @enterTaskDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter task description'**
  String get enterTaskDescriptionLabel;

  /// No description provided for @taskPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Task priority'**
  String get taskPriorityLabel;

  /// No description provided for @taskPriorityLowLabel.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get taskPriorityLowLabel;

  /// No description provided for @taskPriorityMediumLabel.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get taskPriorityMediumLabel;

  /// No description provided for @taskPriorityHighLabel.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get taskPriorityHighLabel;

  /// No description provided for @errorLoadingTasksMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading tasks'**
  String get errorLoadingTasksMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
