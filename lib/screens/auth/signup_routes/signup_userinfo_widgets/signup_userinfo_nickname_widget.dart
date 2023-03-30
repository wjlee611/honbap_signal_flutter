import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honbap_signal_flutter/bloc/auth/post_user_signup/post_user_signup_bloc.dart';
import 'package:honbap_signal_flutter/bloc/auth/post_user_signup/post_user_signup_event.dart';
import 'package:honbap_signal_flutter/bloc/auth/post_user_signup/post_user_signup_state.dart';
import 'package:honbap_signal_flutter/constants/sizes.dart';
import 'package:honbap_signal_flutter/screens/auth/signup_routes/signup_userinfo_widgets/signup_double_check_button_widget.dart';

class SignupUserInfoNickName extends StatefulWidget {
  const SignupUserInfoNickName({super.key});

  @override
  State<SignupUserInfoNickName> createState() => _SignupUserInfoNickNameState();
}

class _SignupUserInfoNickNameState extends State<SignupUserInfoNickName> {
  String _nickname = '';
  bool _nicknameChecked = false;
  bool _isChecking = false;
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  final _nickNameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nickNameFocus.addListener(_checkNicknameValidate);
  }

  @override
  void dispose() {
    _nickNameFocus.dispose();
    super.dispose();
  }

  String? _nicknameValidator(String? value) {
    // Invaled
    if (value != null && value.isEmpty) {
      return '사용할 수 없는 닉네임입니다';
    }

    // Check if nickname is available
    if (!_nicknameChecked) return "중복확인 해주세요";

    // Valid
    context
        .read<SignupUserBloc>()
        .add(SignupNickNameChangedEvent(nickName: value ?? ''));
    return null;
  }

  void _nicknameCheck() async {
    if (_nicknameChecked || _nickname == '') return;

    // TODO: 닉네임 중복확인 로직 추가
    if (_isChecking) return;
    setState(() {
      _isChecking = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isChecking = false;
    });

    // Valid
    setState(() {
      _nicknameChecked = true;
    });
    _checkNicknameValidate();
  }

  void _checkNicknameValidate() {
    if (_nickname == '') return;

    if (_fieldKey.currentState != null) {
      _fieldKey.currentState!.validate();
    }
  }

  void _onChanged(String value) {
    _nickname = value;

    context
        .read<SignupUserBloc>()
        .add(const SignupNickNameChangedEvent(nickName: ''));
    setState(() {
      _nicknameChecked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupUserBloc, SignupUserInfoState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '닉네임은 3개월마다 변경이 가능합니다!',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          SizedBox(
            height: Sizes.size80,
            child: TextFormField(
              key: _fieldKey,
              focusNode: _nickNameFocus,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              style: const TextStyle(fontSize: Sizes.size16),
              decoration: InputDecoration(
                suffix: GestureDetector(
                  onTap: _nicknameCheck,
                  child: SignupDoubleCheckButton(
                    isAvailable: _nicknameChecked,
                    isLoading: _isChecking,
                  ),
                ),
                hintText: '닉네임을 입력해주세요',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              cursorColor: Theme.of(context).primaryColor,
              onChanged: _onChanged,
              validator: (value) => _nicknameValidator(value),
              onEditingComplete: _checkNicknameValidate,
              onTapOutside: (_) => _checkNicknameValidate(),
              onFieldSubmitted: (_) => _checkNicknameValidate(),
            ),
          ),
        ],
      ),
    );
  }
}
