import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/app_accordion.dart';
import 'package:test_app/src/widgets/common/app_action_sheet.dart';
import 'package:test_app/src/widgets/common/app_badge.dart';
import 'package:test_app/src/widgets/common/app_banner.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_calendar.dart';
import 'package:test_app/src/widgets/common/app_card.dart';
import 'package:test_app/src/widgets/common/app_checkbox.dart';
import 'package:test_app/src/widgets/common/app_content_switcher.dart';
import 'package:test_app/src/widgets/common/app_dialog.dart';
import 'package:test_app/src/widgets/common/app_divider.dart';
import 'package:test_app/src/widgets/common/app_dropdown.dart';
import 'package:test_app/src/widgets/common/app_filter.dart';
import 'package:test_app/src/widgets/common/app_list_item.dart';
import 'package:test_app/src/widgets/common/app_list_title.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_number_input.dart';
import 'package:test_app/src/widgets/common/app_pagination_dots.dart';
import 'package:test_app/src/widgets/common/app_progress_bar.dart';
import 'package:test_app/src/widgets/common/app_radio_button.dart';
import 'package:test_app/src/widgets/common/app_search_bar.dart';
import 'package:test_app/src/widgets/common/app_slider.dart';
import 'package:test_app/src/widgets/common/app_star_rating.dart';
import 'package:test_app/src/widgets/common/app_stepper.dart';
import 'package:test_app/src/widgets/common/app_tabs.dart';
import 'package:test_app/src/widgets/common/app_tag.dart';
import 'package:test_app/src/widgets/common/app_tap_bar.dart';
import 'package:test_app/src/widgets/common/app_text_area.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';
import 'package:test_app/src/widgets/common/app_toast.dart';
import 'package:test_app/src/widgets/common/app_toggle.dart';
import 'package:test_app/src/widgets/common/app_tooltip.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      controller: context.appController,
      listenWhen: (previous, current) {
        if (!previous.isFailed && current.isFailed) {
          return true;
        }
        if (!previous.isAuthorized && current.isAuthorized) {
          return true;
        }
        return false;
      },
      listener: (context, previous, current) {
        if (current.isFailed) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${current.message}')));
        } else if (!current.isAuthorized && previous.isAuthorized) {
          context.go(loginPath);
        }
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        child: Scaffold(
          body: ListView(
            children: [
              AppButtonPrimary(
                onPressed: () => context.appController.logout(),
                text: 'Logout',
              ),
              const SizedBox(height: 16),
              AppBanner(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onPressed: () => debugPrint('Button pressed'),
                buttonText: 'Button',
                image: const PlaceholderImage(),
              ),
              const SizedBox(height: 16),
              AppToastInformative(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onClose: () => debugPrint('Toast closed'),
              ),
              const SizedBox(height: 16),
              AppToastSuccess(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onClose: () => debugPrint('Toast closed'),
              ),
              const SizedBox(height: 16),
              AppToastWarning(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onClose: () => debugPrint('Toast closed'),
              ),
              const SizedBox(height: 16),
              AppToastError(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onClose: () => debugPrint('Toast closed'),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppDialog2(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                    onPressed1: () => debugPrint('Button 1 pressed'),
                    onPressed2: () => debugPrint('Button 2 pressed'),
                    buttonText1: 'Button 1',
                    buttonText2: 'Button 2',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppDialog3(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                    onPressed1: () => debugPrint('Button 1 pressed'),
                    onPressed2: () => debugPrint('Button 2 pressed'),
                    onPressed3: () => debugPrint('Button 3 pressed'),
                    buttonText1: 'Button 1',
                    buttonText2: 'Button 2',
                    buttonText3: 'Button 3',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTooltip(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                isTop: true,
                horizontalOffset: 0.69,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppBadgeSymbol(symbol: '9'),
                  const SizedBox(width: 8),
                  AppBadgeIcon(icon: AppIcons.check),
                  const SizedBox(width: 8),
                  AppBadgeEmpty(),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 332,
                  child: AppContentSwitcher(
                    sectionCount: 4,
                    sectionTitles: List.generate(
                      4,
                      (index) => 'Section ${index + 1}',
                    ),
                    onSectionSelected: (value) =>
                        debugPrint('Selected section: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 332,
                  child: AppContentSwitcher(
                    sectionCount: 3,
                    sectionTitles: List.generate(
                      3,
                      (index) => 'Section ${index + 1}',
                    ),
                    onSectionSelected: (value) =>
                        debugPrint('Selected section: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 332,
                  child: AppContentSwitcher(
                    sectionCount: 2,
                    sectionTitles: List.generate(
                      2,
                      (index) => 'Section ${index + 1}',
                    ),
                    onSectionSelected: (value) =>
                        debugPrint('Selected section: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 405,
                  child: AppTabs(
                    tabCount: 6,
                    tabTitles: List.generate(
                      6,
                      (index) => 'Title ${index + 1}',
                    ),
                    onTabSelected: (value) =>
                        debugPrint('Selected tab: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppActionSheet(
                    actionCount: 5,
                    actionTitles: List.generate(
                      5,
                      (index) => 'Action ${index + 1}',
                    ),
                    actionIcons: List.generate(5, (index) => AppIcons.record),
                    onActionPressed: List.generate(
                      5,
                      (index) =>
                          () => debugPrint('Action ${index + 1} pressed'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppFilter(onPressed: () => debugPrint('Filter pressed')),
              const SizedBox(height: 16),
              AppFilter(
                filteredItemCount: 2,
                onPressed: () => debugPrint('Filter pressed'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppCheckbox(
                    value: false,
                    onChanged: (value) =>
                        debugPrint('Checkbox 1 changed: $value'),
                  ),
                  const SizedBox(width: 16),
                  AppCheckbox(
                    value: true,
                    onChanged: (value) =>
                        debugPrint('Checkbox 2 changed: $value'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppCheckbox(
                    value: false,
                    size: checkboxMediumSize,
                    onChanged: (value) =>
                        debugPrint('Checkbox 3 changed: $value'),
                  ),
                  const SizedBox(width: 16),
                  AppCheckbox(
                    value: true,
                    size: checkboxMediumSize,
                    onChanged: (value) =>
                        debugPrint('Checkbox 4 changed: $value'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppCheckbox(
                    value: false,
                    size: checkboxLargeSize,
                    onChanged: (value) =>
                        debugPrint('Checkbox 5 changed: $value'),
                  ),
                  const SizedBox(width: 16),
                  AppCheckbox(
                    value: true,
                    size: checkboxLargeSize,
                    onChanged: (value) =>
                        debugPrint('Checkbox 6 changed: $value'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RadioGroup<bool>(
                groupValue: true,
                onChanged: (value) => debugPrint('Selected: $value'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppRadioButton(value: false),
                    const SizedBox(width: 16),
                    AppRadioButton(value: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RadioGroup<bool>(
                groupValue: true,
                onChanged: (value) => debugPrint('Selected: $value'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppRadioButton(value: false, size: radioButtonMediumSize),
                    const SizedBox(width: 16),
                    AppRadioButton(value: true, size: radioButtonMediumSize),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RadioGroup<bool>(
                groupValue: true,
                onChanged: (value) => debugPrint('Selected: $value'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppRadioButton(value: false, size: radioButtonLargeSize),
                    const SizedBox(width: 16),
                    AppRadioButton(value: true, size: radioButtonLargeSize),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppToggle(
                value: false,
                onChanged: (value) => debugPrint('Toggle 1 changed: $value'),
              ),
              const SizedBox(height: 16),
              AppToggle(
                value: true,
                onChanged: (value) => debugPrint('Toggle 2 changed: $value'),
              ),
              const SizedBox(height: 16),
              AppStarRating(
                rating: 0,
                onRatingChanged: (value) =>
                    debugPrint('Star rating changed: $value'),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppSlider(
                    value: 50,
                    onChanged: (value) => debugPrint('Slider changed: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppSliderDefault(
                    value: 50,
                    onChanged: (value) =>
                        debugPrint('Slider default changed: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppSliderTitled(
                    value: 50,
                    title: 'Title',
                    onChanged: (value) =>
                        debugPrint('Slider titled changed: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppNumberInput(
                value: 123,
                onChanged: (value) =>
                    debugPrint('Number input changed: $value'),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 303,
                  child: AppNumberInputTitled(
                    value: 123,
                    title: 'Title',
                    onChanged: (value) =>
                        debugPrint('Number input titled changed: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 303,
                  child: AppNumberInputTitled(
                    value: 123,
                    min: 123,
                    title: 'Title',
                    onChanged: (value) => debugPrint(
                      'Number input titled with min changed: $value',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 303,
                  child: AppNumberInputTitled(
                    value: 123,
                    max: 123,
                    title: 'Title',
                    onChanged: (value) => debugPrint(
                      'Number input titled with max changed: $value',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 303,
                  child: AppNumberInputTitled(
                    value: 123,
                    title: 'Title',
                    supportText: 'Support text',
                    onChanged: (value) => debugPrint(
                      'Number input titled with support text changed: $value',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 303,
                  child: AppNumberInputTitled(
                    value: 123,
                    title: 'Title',
                    enabled: false,
                    onChanged: (value) => debugPrint(
                      'Number input titled with disabled state changed: $value',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppTextField(
                    title: 'Title',
                    placeholder: 'Placeholder',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppTextField(title: 'Title', text: 'Text'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppTextField(
                    title: 'Title',
                    text: 'Text',
                    validator: (value) =>
                        value == 'Text' ? 'Cannot be "Text"' : null,
                    autovalidateMode: AutovalidateMode.always,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppTextField(
                    title: 'Title',
                    text: 'Text',
                    enabled: false,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppTextField(
                    title: 'Title',
                    placeholder: 'Placeholder',
                    supportText: 'Support text',
                    obscureText: false,
                    showIcon: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppTextField(
                    title: 'Title',
                    placeholder: 'Placeholder',
                    unit: '€',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppTextArea(
                    title: 'Title',
                    placeholder: 'Placeholder',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppTextArea(title: 'Title', text: 'Text'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppTextArea(
                    title: 'Title',
                    text: 'Text',
                    validator: (value) =>
                        value == 'Text' ? 'Cannot be "Text"' : null,
                    autovalidateMode: AutovalidateMode.always,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppTextArea(
                    title: 'Title',
                    text: 'Text',
                    enabled: false,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppTextArea(
                    title: 'Title',
                    placeholder: 'Placeholder',
                    supportText: 'Support text',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppTextArea(
                    title: 'Title',
                    placeholder: 'Placeholder',
                    unit: '€',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppDropdown(
                    items: List.generate(
                      5,
                      (index) => DropdownMenuEntry<String>(
                        value: 'Option ${index + 1}',
                        label: 'Option ${index + 1}',
                      ),
                    ),
                    title: 'Title',
                    onSelected: (value) => debugPrint('Selected: $value'),
                    placeholder: 'Placeholder',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppDropdown(
                    items: List.generate(
                      5,
                      (index) => DropdownMenuEntry<String>(
                        value: 'Option ${index + 1}',
                        label: 'Option ${index + 1}',
                      ),
                    ),
                    title: 'Title',
                    onSelected: (value) => debugPrint('Selected: $value'),
                    text: 'Text',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppDropdown(
                    items: List.generate(
                      5,
                      (index) => DropdownMenuEntry<String>(
                        value: 'Option ${index + 1}',
                        label: 'Option ${index + 1}',
                      ),
                    ),
                    title: 'Title',
                    onSelected: (value) => debugPrint('Selected: $value'),
                    text: 'Text',
                    validator: (value) =>
                        value == 'Text' ? 'Cannot be "Text"' : null,
                    autovalidateMode: AutovalidateMode.always,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 295,
                  child: AppDropdown(
                    items: List.generate(
                      5,
                      (index) => DropdownMenuEntry<String>(
                        value: 'Option ${index + 1}',
                        label: 'Option ${index + 1}',
                      ),
                    ),
                    title: 'Title',
                    onSelected: (value) => debugPrint('Selected: $value'),
                    text: 'Text',
                    enabled: false,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: SizedBox(width: 311, child: AppSearchBar())),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(width: 311, child: AppSearchBar(text: 'Text')),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 423,
                  child: AppTapBar(
                    tabCount: 5,
                    tabTitles: List.generate(5, (index) => 'Tab ${index + 1}'),
                    tabIcons: List.generate(5, (index) => AppIcons.record),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 375,
                  child: AppNavBar(
                    title: 'Page Title',
                    leftIcon: AppIcons.arrowLeft,
                    rightText: 'Edit',
                    onPressedLeft: () => debugPrint('Pressed left'),
                    onPressedRight: () => debugPrint('Pressed right'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 375,
                  child: AppNavBar(
                    title: 'Page Title',
                    leftIcon: AppIcons.arrowLeft,
                    rightIcon: AppIcons.heartOutlined,
                    onPressedLeft: () => debugPrint('Pressed left'),
                    onPressedRight: () => debugPrint('Pressed right'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 375,
                  child: AppNavBar(
                    title: 'Page Title',
                    leftIcon: AppIcons.arrowLeft,
                    rightImage: const PlaceholderAvatar(size: AvatarSize.small),
                    onPressedLeft: () => debugPrint('Pressed left'),
                    onPressedRight: () => debugPrint('Pressed right'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 375,
                  child: AppNavBar(
                    title: 'Page Title',
                    leftText: 'Cancel',
                    rightText: 'Edit',
                    onPressedLeft: () => debugPrint('Pressed left'),
                    onPressedRight: () => debugPrint('Pressed right'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 375,
                  child: AppNavBar(
                    title: 'Page Title',
                    leftText: 'Cancel',
                    rightIcon: AppIcons.heartOutlined,
                    onPressedLeft: () => debugPrint('Pressed left'),
                    onPressedRight: () => debugPrint('Pressed right'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 375,
                  child: AppNavBar(
                    title: 'Page Title',
                    leftText: 'Cancel',
                    rightImage: const PlaceholderAvatar(size: AvatarSize.small),
                    onPressedLeft: () => debugPrint('Pressed left'),
                    onPressedRight: () => debugPrint('Pressed right'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 375,
                  child: AppNavBar(
                    title: 'Page Title',
                    leftText: 'Cancel',
                    onPressedLeft: () => debugPrint('Pressed left'),
                    onPressedRight: () => debugPrint('Pressed right'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 375,
                  child: AppNavBar(
                    title: 'Page Title',
                    rightText: 'Edit',
                    onPressedLeft: () => debugPrint('Pressed left'),
                    onPressedRight: () => debugPrint('Pressed right'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 375,
                  child: AppNavBar(
                    title: 'Page Title',
                    rightIcon: AppIcons.heartOutlined,
                    onPressedLeft: () => debugPrint('Pressed left'),
                    onPressedRight: () => debugPrint('Pressed right'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 375,
                  child: AppNavBar(
                    title: 'Page Title',
                    rightImage: const PlaceholderAvatar(size: AvatarSize.small),
                    onPressedLeft: () => debugPrint('Pressed left'),
                    onPressedRight: () => debugPrint('Pressed right'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 375,
                  child: AppNavBar(
                    title: 'Page Title',
                    onPressedLeft: () => debugPrint('Pressed left'),
                    onPressedRight: () => debugPrint('Pressed right'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 200,
                  child: AppCardLarge(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    tagText: 'TAG',
                    onTagPressed: () => debugPrint('Tag pressed'),
                    image: const PlaceholderImage(),
                    buttonText: 'Button',
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 200,
                  child: AppCardLarge(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    icon: AppIcons.heartFilled,
                    onIconButtonPressed: () =>
                        debugPrint('Icon button pressed'),
                    buttonText: 'Button',
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 200,
                  child: AppCardLarge(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    avatar: const PlaceholderAvatar(size: AvatarSize.medium),
                    onAvatarPressed: () => debugPrint('Avatar button pressed'),
                    buttonText: 'Button',
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCardSmall(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    buttonText: 'Button',
                    image: const PlaceholderImage(),
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCardSmall(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    image: const PlaceholderImage(),
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCardSmall(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    image: const PlaceholderImage(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCardSmall(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    buttonText: 'Button',
                    avatar: const PlaceholderAvatar(size: AvatarSize.small),
                    onAvatarPressed: () => debugPrint('Avatar button pressed'),
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCardSmall(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    avatar: const PlaceholderAvatar(size: AvatarSize.small),
                    onAvatarPressed: () => debugPrint('Avatar button pressed'),
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCardSmall(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    avatar: const PlaceholderAvatar(size: AvatarSize.small),
                    onAvatarPressed: () => debugPrint('Avatar button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCardSmall(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    buttonText: 'Button',
                    icon: AppIcons.heartFilled,
                    onIconButtonPressed: () =>
                        debugPrint('Icon button pressed'),
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCardSmall(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    icon: AppIcons.heartFilled,
                    onIconButtonPressed: () =>
                        debugPrint('Icon button pressed'),
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCardSmall(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    icon: AppIcons.heartFilled,
                    onIconButtonPressed: () =>
                        debugPrint('Icon button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCardSmall(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    buttonText: 'Button',
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCardSmall(
                    title: 'Title',
                    subtitle: 'Subtitle',
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCardSmall(title: 'Title', subtitle: 'Subtitle'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 46,
                  child: AppTag(
                    text: 'TAG',
                    onPressed: () => debugPrint('Tag pressed'),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListTitle(title: 'Title'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListTitle(
                    title: 'Title',
                    buttonText: 'Edit',
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListTitle(
                    title: 'Title',
                    icon: AppIcons.search,
                    onPressed: () => debugPrint('Icon button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    icon: AppIcons.heartFilled,
                    control: AppListItemControl.button,
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    icon: AppIcons.heartFilled,
                    control: AppListItemControl.toggle,
                    value: false,
                    onChanged: (value) => debugPrint('Toggle changed: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    icon: AppIcons.heartFilled,
                    control: AppListItemControl.checkbox,
                    value: false,
                    onChanged: (value) =>
                        debugPrint('Checkbox changed: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    icon: AppIcons.heartFilled,
                    control: AppListItemControl.badge,
                    symbol: '9',
                    onPressed: () => debugPrint('Badge pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    icon: AppIcons.heartFilled,
                    control: AppListItemControl.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    avatar: const PlaceholderAvatar(size: AvatarSize.small),
                    control: AppListItemControl.button,
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    avatar: const PlaceholderAvatar(size: AvatarSize.small),
                    control: AppListItemControl.toggle,
                    value: false,
                    onChanged: (value) => debugPrint('Toggle changed: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    avatar: const PlaceholderAvatar(size: AvatarSize.small),
                    control: AppListItemControl.checkbox,
                    value: false,
                    onChanged: (value) =>
                        debugPrint('Checkbox changed: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    avatar: const PlaceholderAvatar(size: AvatarSize.small),
                    control: AppListItemControl.badge,
                    symbol: '9',
                    onPressed: () => debugPrint('Badge pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    avatar: const PlaceholderAvatar(size: AvatarSize.small),
                    control: AppListItemControl.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    control: AppListItemControl.button,
                    onPressed: () => debugPrint('Button pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    control: AppListItemControl.toggle,
                    value: false,
                    onChanged: (value) => debugPrint('Toggle changed: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    control: AppListItemControl.checkbox,
                    value: false,
                    onChanged: (value) =>
                        debugPrint('Checkbox changed: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    control: AppListItemControl.badge,
                    symbol: '9',
                    onPressed: () => debugPrint('Badge pressed'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 327,
                  child: AppListItem(
                    title: 'Title',
                    description:
                        'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do',
                    control: AppListItemControl.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppAccordion(
                    title: 'Title',
                    children: [
                      AppAccordionText('Content. Lorem ipsum dolor sit amet'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: SizedBox(width: 311, child: const AppDivider())),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCalendarMonthly(
                    initialDate: DateTime.now(),
                    onDatePressed: (date) => debugPrint('Date pressed: $date'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppCalendarWeekly(
                    initialDate: DateTime.now(),
                    onDatePressed: (date) => debugPrint('Date pressed: $date'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppStepper(
                    stepCount: 5,
                    currentStep: 0,
                    stepTitles: List.generate(5, (_) => 'Step'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppStepper(
                    stepCount: 4,
                    currentStep: 0,
                    stepTitles: List.generate(4, (_) => 'Step'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppStepper(
                    stepCount: 3,
                    currentStep: 0,
                    stepTitles: List.generate(3, (_) => 'Step'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppStepper(
                    stepCount: 2,
                    currentStep: 0,
                    stepTitles: List.generate(2, (_) => 'Step'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppStepper(
                    stepCount: 5,
                    currentStep: 0,
                    stepTitles: List.generate(5, (_) => 'Step'),
                    onStepTapped: (value) => debugPrint('Step tapped: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppStepper(
                    stepCount: 4,
                    currentStep: 0,
                    stepTitles: List.generate(4, (_) => 'Step'),
                    onStepTapped: (value) => debugPrint('Step tapped: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppStepper(
                    stepCount: 3,
                    currentStep: 0,
                    stepTitles: List.generate(3, (_) => 'Step'),
                    onStepTapped: (value) => debugPrint('Step tapped: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppStepper(
                    stepCount: 2,
                    currentStep: 0,
                    stepTitles: List.generate(2, (_) => 'Step'),
                    onStepTapped: (value) => debugPrint('Step tapped: $value'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: AppStepper(
                    stepCount: 4,
                    currentStep: 2,
                    stepTitles: List.generate(4, (_) => 'Step'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: const AppProgressBar(value: 0),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: const AppProgressBar(value: 0.25),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: const AppProgressBar(value: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: const AppProgressBar(value: 0.75),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: const AppProgressBar(value: 1),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 300,
                  child: const AppProgressBar(value: 0.55, steps: 6),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(width: 32, child: const AppLoader(value: 0)),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 32,
                  child: const AppLoader(value: 0.125),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(width: 32, child: const AppLoader(value: 0.25)),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 32,
                  child: const AppLoader(value: 0.375),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(width: 32, child: const AppLoader(value: 0.5)),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 32,
                  child: const AppLoader(value: 0.625),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(width: 32, child: const AppLoader(value: 0.75)),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 32,
                  child: const AppLoader(value: 0.875),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(width: 32, child: const AppLoader(value: 1)),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 72,
                  child: const AppPaginationDots(dotCount: 5, activeIndex: 1),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
