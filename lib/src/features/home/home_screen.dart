import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/core/widgets/controller_listener.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/router/routes.dart';
import 'package:test_app/src/widgets/common/my_action_sheet.dart';
import 'package:test_app/src/widgets/common/my_badge.dart';
import 'package:test_app/src/widgets/common/my_banner.dart';
import 'package:test_app/src/widgets/common/my_button.dart';
import 'package:test_app/src/widgets/common/my_checkbox.dart';
import 'package:test_app/src/widgets/common/my_content_switcher.dart';
import 'package:test_app/src/widgets/common/my_dialog.dart';
import 'package:test_app/src/widgets/common/my_dropdown.dart';
import 'package:test_app/src/widgets/common/my_filter.dart';
import 'package:test_app/src/widgets/common/my_nav_bar.dart';
import 'package:test_app/src/widgets/common/my_number_input.dart';
import 'package:test_app/src/widgets/common/my_radio_button.dart';
import 'package:test_app/src/widgets/common/my_search_bar.dart';
import 'package:test_app/src/widgets/common/my_slider.dart';
import 'package:test_app/src/widgets/common/my_star_rating.dart';
import 'package:test_app/src/widgets/common/my_tabs.dart';
import 'package:test_app/src/widgets/common/my_tap_bar.dart';
import 'package:test_app/src/widgets/common/my_text_area.dart';
import 'package:test_app/src/widgets/common/my_text_field.dart';
import 'package:test_app/src/widgets/common/my_toast.dart';
import 'package:test_app/src/widgets/common/my_toggle.dart';
import 'package:test_app/src/widgets/common/my_tooltip.dart';
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
              MyButtonPrimary(
                onPressed: () => context.appController.logout(),
                text: 'Logout',
              ),
              const SizedBox(height: 16),
              MyBanner(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onPressed: () => debugPrint('Button pressed'),
                buttonText: 'Button',
                image: const PlaceholderImage(),
              ),
              const SizedBox(height: 16),
              MyToastInformative(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onClose: () => debugPrint('Toast closed'),
              ),
              const SizedBox(height: 16),
              MyToastSuccess(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onClose: () => debugPrint('Toast closed'),
              ),
              const SizedBox(height: 16),
              MyToastWarning(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onClose: () => debugPrint('Toast closed'),
              ),
              const SizedBox(height: 16),
              MyToastError(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onClose: () => debugPrint('Toast closed'),
              ),
              const SizedBox(height: 16),
              MyDialog2(
                title: 'Title',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                onPressed1: () => debugPrint('Button 1 pressed'),
                onPressed2: () => debugPrint('Button 2 pressed'),
                buttonText1: 'Button 1',
                buttonText2: 'Button 2',
              ),
              const SizedBox(height: 16),
              MyDialog3(
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
              const SizedBox(height: 16),
              MyTooltip(
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
                  MyBadgeSymbol(symbol: '9'),
                  const SizedBox(width: 8),
                  MyBadgeIcon(icon: AppIcons.check),
                  const SizedBox(width: 8),
                  MyBadgeEmpty(),
                ],
              ),
              const SizedBox(height: 16),
              MyContentSwitcher(
                sectionCount: 4,
                sectionTitles: List.generate(
                  4,
                  (index) => 'Section ${index + 1}',
                ),
                onSectionSelected: (value) =>
                    debugPrint('Selected section: $value'),
              ),
              const SizedBox(height: 16),
              MyContentSwitcher(
                sectionCount: 3,
                sectionTitles: List.generate(
                  3,
                  (index) => 'Section ${index + 1}',
                ),
                onSectionSelected: (value) =>
                    debugPrint('Selected section: $value'),
              ),
              const SizedBox(height: 16),
              MyContentSwitcher(
                sectionCount: 2,
                sectionTitles: List.generate(
                  2,
                  (index) => 'Section ${index + 1}',
                ),
                onSectionSelected: (value) =>
                    debugPrint('Selected section: $value'),
              ),
              const SizedBox(height: 16),
              MyTabs(
                tabCount: 6,
                tabTitles: List.generate(6, (index) => 'Title ${index + 1}'),
                onTabSelected: (value) => debugPrint('Selected tab: $value'),
              ),
              const SizedBox(height: 16),
              MyActionSheet(
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
              const SizedBox(height: 16),
              MyFilter(onPressed: () => debugPrint('Filter pressed')),
              const SizedBox(height: 16),
              MyFilter(
                filteredItemCount: 2,
                onPressed: () => debugPrint('Filter pressed'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyCheckbox(
                    value: false,
                    onChanged: (value) =>
                        debugPrint('Checkbox 1 changed: $value'),
                  ),
                  const SizedBox(width: 16),
                  MyCheckbox(
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
                  MyCheckbox(
                    value: false,
                    size: checkboxMediumSize,
                    onChanged: (value) =>
                        debugPrint('Checkbox 3 changed: $value'),
                  ),
                  const SizedBox(width: 16),
                  MyCheckbox(
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
                  MyCheckbox(
                    value: false,
                    size: checkboxLargeSize,
                    onChanged: (value) =>
                        debugPrint('Checkbox 5 changed: $value'),
                  ),
                  const SizedBox(width: 16),
                  MyCheckbox(
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
                onChanged: (value) => {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyRadioButton(
                      value: false,
                      onChanged: (value) =>
                          debugPrint('Radio button 1 changed: $value'),
                    ),
                    const SizedBox(width: 16),
                    MyRadioButton(
                      value: true,
                      onChanged: (value) =>
                          debugPrint('Radio button 2 changed: $value'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RadioGroup<bool>(
                groupValue: true,
                onChanged: (value) => {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyRadioButton(
                      value: false,
                      size: radioButtonMediumSize,
                      onChanged: (value) =>
                          debugPrint('Radio button 3 changed: $value'),
                    ),
                    const SizedBox(width: 16),
                    MyRadioButton(
                      value: true,
                      size: radioButtonMediumSize,
                      onChanged: (value) =>
                          debugPrint('Radio button 4 changed: $value'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RadioGroup<bool>(
                groupValue: true,
                onChanged: (value) => {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyRadioButton(
                      value: false,
                      size: radioButtonLargeSize,
                      onChanged: (value) =>
                          debugPrint('Radio button 5 changed: $value'),
                    ),
                    const SizedBox(width: 16),
                    MyRadioButton(
                      value: true,
                      size: radioButtonLargeSize,
                      onChanged: (value) =>
                          debugPrint('Radio button 6 changed: $value'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              MyToggle(
                value: false,
                onChanged: (value) => debugPrint('Toggle 1 changed: $value'),
              ),
              const SizedBox(height: 16),
              MyToggle(
                value: true,
                onChanged: (value) => debugPrint('Toggle 2 changed: $value'),
              ),
              const SizedBox(height: 16),
              MyStarRating(
                rating: 0,
                onRatingChanged: (value) =>
                    debugPrint('Star rating changed: $value'),
              ),
              const SizedBox(height: 16),
              MySlider(
                value: 50,
                onChanged: (value) => debugPrint('Slider changed: $value'),
              ),
              const SizedBox(height: 16),
              MySliderDefault(
                value: 50,
                onChanged: (value) =>
                    debugPrint('Slider default changed: $value'),
              ),
              const SizedBox(height: 16),
              MySliderTitled(
                value: 50,
                title: 'Title',
                onChanged: (value) =>
                    debugPrint('Slider titled changed: $value'),
              ),
              const SizedBox(height: 16),
              MyNumberInput(
                value: 123,
                onChanged: (value) =>
                    debugPrint('Number input changed: $value'),
              ),
              const SizedBox(height: 16),
              MyNumberInputTitled(
                value: 123,
                title: 'Title',
                onChanged: (value) =>
                    debugPrint('Number input titled changed: $value'),
              ),
              const SizedBox(height: 16),
              MyNumberInputTitled(
                value: 123,
                min: 123,
                title: 'Title',
                onChanged: (value) =>
                    debugPrint('Number input titled with min changed: $value'),
              ),
              const SizedBox(height: 16),
              MyNumberInputTitled(
                value: 123,
                max: 123,
                title: 'Title',
                onChanged: (value) =>
                    debugPrint('Number input titled with max changed: $value'),
              ),
              const SizedBox(height: 16),
              MyNumberInputTitled(
                value: 123,
                title: 'Title',
                supportText: 'Support text',
                onChanged: (value) => debugPrint(
                  'Number input titled with support text changed: $value',
                ),
              ),
              const SizedBox(height: 16),
              MyNumberInputTitled(
                value: 123,
                title: 'Title',
                enabled: false,
                onChanged: (value) => debugPrint(
                  'Number input titled with disabled state changed: $value',
                ),
              ),
              const SizedBox(height: 16),
              MyTextField(title: 'Title', placeholder: 'Placeholder'),
              const SizedBox(height: 16),
              MyTextField(title: 'Title', text: 'Text'),
              const SizedBox(height: 16),
              MyTextField(
                title: 'Title',
                text: 'Text',
                validator: (value) =>
                    value == 'Text' ? 'Cannot be "Text"' : null,
                autovalidateMode: AutovalidateMode.always,
              ),
              const SizedBox(height: 16),
              MyTextField(title: 'Title', text: 'Text', enabled: false),
              const SizedBox(height: 16),
              MyTextField(
                title: 'Title',
                placeholder: 'Placeholder',
                supportText: 'Support text',
                obscureText: false,
                showIcon: true,
              ),
              const SizedBox(height: 16),
              MyTextField(
                title: 'Title',
                placeholder: 'Placeholder',
                unit: '€',
              ),
              const SizedBox(height: 16),
              MyTextArea(title: 'Title', placeholder: 'Placeholder'),
              const SizedBox(height: 16),
              MyTextArea(title: 'Title', text: 'Text'),
              const SizedBox(height: 16),
              MyTextArea(
                title: 'Title',
                text: 'Text',
                validator: (value) =>
                    value == 'Text' ? 'Cannot be "Text"' : null,
                autovalidateMode: AutovalidateMode.always,
              ),
              const SizedBox(height: 16),
              MyTextArea(title: 'Title', text: 'Text', enabled: false),
              const SizedBox(height: 16),
              MyTextArea(
                title: 'Title',
                placeholder: 'Placeholder',
                supportText: 'Support text',
              ),
              const SizedBox(height: 16),
              MyTextArea(title: 'Title', placeholder: 'Placeholder', unit: '€'),
              const SizedBox(height: 16),
              MyDropdown(
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
              const SizedBox(height: 16),
              MyDropdown(
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
              const SizedBox(height: 16),
              MyDropdown(
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
              const SizedBox(height: 16),
              MyDropdown(
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
              const SizedBox(height: 16),
              MySearchBar(),
              const SizedBox(height: 16),
              MySearchBar(text: 'Text'),
              const SizedBox(height: 16),
              MyTapBar(
                tabCount: 5,
                tabTitles: List.generate(5, (index) => 'Tab ${index + 1}'),
                tabIcons: List.generate(5, (index) => AppIcons.record),
              ),
              const SizedBox(height: 16),
              MyNavBar(
                title: 'Page Title',
                leftIcon: AppIcons.arrowLeft,
                rightText: 'Edit',
                onPressedLeft: () => debugPrint('Pressed left'),
                onPressedRight: () => debugPrint('Pressed right'),
              ),
              const SizedBox(height: 16),
              MyNavBar(
                title: 'Page Title',
                leftIcon: AppIcons.arrowLeft,
                rightIcon: AppIcons.heartOutlined,
                onPressedLeft: () => debugPrint('Pressed left'),
                onPressedRight: () => debugPrint('Pressed right'),
              ),
              const SizedBox(height: 16),
              MyNavBar(
                title: 'Page Title',
                leftIcon: AppIcons.arrowLeft,
                rightImage: const PlaceholderAvatar(size: AvatarSize.small),
                onPressedLeft: () => debugPrint('Pressed left'),
                onPressedRight: () => debugPrint('Pressed right'),
              ),
              const SizedBox(height: 16),
              MyNavBar(
                title: 'Page Title',
                leftIcon: AppIcons.arrowLeft,
                onPressedLeft: () => debugPrint('Pressed left'),
                onPressedRight: () => debugPrint('Pressed right'),
              ),
              const SizedBox(height: 16),
              MyNavBar(
                title: 'Page Title',
                leftText: 'Cancel',
                rightText: 'Edit',
                onPressedLeft: () => debugPrint('Pressed left'),
                onPressedRight: () => debugPrint('Pressed right'),
              ),
              const SizedBox(height: 16),
              MyNavBar(
                title: 'Page Title',
                leftText: 'Cancel',
                rightIcon: AppIcons.heartOutlined,
                onPressedLeft: () => debugPrint('Pressed left'),
                onPressedRight: () => debugPrint('Pressed right'),
              ),
              const SizedBox(height: 16),
              MyNavBar(
                title: 'Page Title',
                leftText: 'Cancel',
                rightImage: const PlaceholderAvatar(size: AvatarSize.small),
                onPressedLeft: () => debugPrint('Pressed left'),
                onPressedRight: () => debugPrint('Pressed right'),
              ),
              const SizedBox(height: 16),
              MyNavBar(
                title: 'Page Title',
                leftText: 'Cancel',
                onPressedLeft: () => debugPrint('Pressed left'),
                onPressedRight: () => debugPrint('Pressed right'),
              ),
              const SizedBox(height: 16),
              MyNavBar(
                title: 'Page Title',
                rightText: 'Edit',
                onPressedLeft: () => debugPrint('Pressed left'),
                onPressedRight: () => debugPrint('Pressed right'),
              ),
              const SizedBox(height: 16),
              MyNavBar(
                title: 'Page Title',
                rightIcon: AppIcons.heartOutlined,
                onPressedLeft: () => debugPrint('Pressed left'),
                onPressedRight: () => debugPrint('Pressed right'),
              ),
              const SizedBox(height: 16),
              MyNavBar(
                title: 'Page Title',
                rightImage: const PlaceholderAvatar(size: AvatarSize.small),
                onPressedLeft: () => debugPrint('Pressed left'),
                onPressedRight: () => debugPrint('Pressed right'),
              ),
              const SizedBox(height: 16),
              MyNavBar(
                title: 'Page Title',
                onPressedLeft: () => debugPrint('Pressed left'),
                onPressedRight: () => debugPrint('Pressed right'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
