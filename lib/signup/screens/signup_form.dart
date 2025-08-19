import 'package:flutter/material.dart';
import '../widgets/terms_row.dart';

class SignupFormScreen extends StatefulWidget {
  const SignupFormScreen({super.key});

  @override
  State<SignupFormScreen> createState() => _SignupFormScreenState();
}

class _SignupFormScreenState extends State<SignupFormScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String? _selectedGender;

  // 이메일 중복확인 상태 변수
  bool _emailDuplicateChecked = false;

  bool _agreeTerms1 = false;
  bool _agreeTerms2 = false;
  bool _agreeTerms3 = false;

  bool get _allFieldsFilled =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _passwordConfirmController.text.isNotEmpty &&
      _nameController.text.trim().isNotEmpty &&
      _passwordController.text == _passwordConfirmController.text &&
      //_passwordController.text.length >= 6 && 6자리 이상은 추후에 고려하기
      _selectedGender != null &&
      _emailDuplicateChecked;

  bool get _allTermsAgreed => _agreeTerms1 && _agreeTerms2 && _agreeTerms3;

  bool get _canSubmit => _allFieldsFilled && _allTermsAgreed;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onChanged(_) => setState(() {});

  void _showComingSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('준비 중입니다.')));
  }

  void _checkEmailDuplicate() {
    final email = _emailController.text.trim();

    // API가 없으므로 일단 사용가능하다고 처리
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181A20),
          title: const Text(
            '중복확인 완료',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            '사용가능한 아이디입니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Color(0xFFFF3278),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    setState(() {
      _emailDuplicateChecked = true;
    });
  }

  void _handleSubmit() {
    // TODO: 실제 회원가입 API 연동 예정
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 스크롤 가능한 내용
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    // 입력 필드를 먼저 배치하도록 순서 조정 (프로필 이미지는 아래로 이동)
                    const SizedBox(height: 12),

                    // 이메일
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '아이디',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                onChanged: _onChanged,
                                enabled: !_emailDuplicateChecked,
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: _emailDuplicateChecked
                                      ? Colors.grey[400]
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  hintText: '아이디를 입력하세요',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: _emailDuplicateChecked
                                        ? Colors.grey[500]
                                        : Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  filled: true,
                                  fillColor: _emailDuplicateChecked
                                      ? Colors.grey[800]
                                      : const Color.fromRGBO(
                                          130,
                                          145,
                                          179,
                                          0.1333,
                                        ),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: _emailDuplicateChecked
                                          ? Colors.grey[700]!
                                          : Colors.grey[600]!,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey[700]!,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed:
                                    _emailController.text.trim().isNotEmpty
                                    ? _checkEmailDuplicate
                                    : null,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                        (states) {
                                          if (states.contains(
                                            MaterialState.disabled,
                                          )) {
                                            return Colors.grey[700];
                                          }
                                          return const Color(0xFFFF3278);
                                        },
                                      ),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                        Colors.white,
                                      ),
                                  shape:
                                      MaterialStateProperty.all<
                                        RoundedRectangleBorder
                                      >(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                  elevation: MaterialStateProperty.all<double>(
                                    0,
                                  ),
                                ),
                                child: const Text(
                                  '중복확인',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 비밀번호
                    TextField(
                      controller: _passwordController,
                      onChanged: _onChanged,
                      obscureText: true,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        labelStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: '비밀번호를 입력하세요 (6자 이상)',
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: const Color.fromRGBO(130, 145, 179, 0.1333),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[600]!),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 비밀번호 확인
                    TextField(
                      controller: _passwordConfirmController,
                      onChanged: _onChanged,
                      obscureText: true,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        labelText: '비밀번호를 다시 입력해주세요',
                        labelStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: '비밀번호를 다시 입력하세요',
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: const Color.fromRGBO(130, 145, 179, 0.1333),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[600]!),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    // 비밀번호 일치 여부 안내 텍스트
                    Builder(
                      builder: (_) {
                        final hasPassword = _passwordController.text.isNotEmpty;
                        final hasConfirm =
                            _passwordConfirmController.text.isNotEmpty;
                        if (!hasPassword && !hasConfirm) {
                          return const SizedBox(height: 0);
                        }
                        final matches =
                            _passwordController.text ==
                            _passwordConfirmController.text;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            matches ? '비밀번호가 일치합니다.' : '비밀번호가 일치하지 않습니다.',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: matches
                                  ? const Color(0xFF00C853)
                                  : const Color(0xFFFF5252),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // 프로필 이미지 (원형) - 입력 필드 아래로 이동, 크기 확대
                    Center(
                      child: Stack(
                        children: [
                          const CircleAvatar(
                            radius: 56,
                            backgroundColor: Color(0xFF2A2F3A),
                            child: Icon(
                              Icons.person,
                              size: 56,
                              color: Colors.white70,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: _showComingSoon,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF3278),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 이름 또는 닉네임 (프로필 이미지 아래로 이동)
                    TextField(
                      controller: _nameController,
                      onChanged: _onChanged,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        labelText: '이름 또는 닉네임을 입력해주세요',
                        labelStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: '이름 또는 닉네임',
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: const Color.fromRGBO(130, 145, 179, 0.1333),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[600]!),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 성별 선택
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '성별',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text(
                                  '남성',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                value: 'male',
                                groupValue: _selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                                activeColor: const Color(0xFFFF3278),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text(
                                  '여성',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                value: 'female',
                                groupValue: _selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                                activeColor: const Color(0xFFFF3278),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Container(height: 1, color: Colors.grey[700]),
                    const SizedBox(height: 12),

                    // 이용약관 동의 섹션
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(130, 145, 179, 0.1333),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 이용약관 제목
                          Text(
                            '이용약관',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 약관 동의 항목들
                          TermsRow(
                            label: '[필수] 이용약관 동의',
                            checked: _agreeTerms1,
                            onChanged: (v) =>
                                setState(() => _agreeTerms1 = v ?? false),
                            onView: _showComingSoon,
                          ),
                          TermsRow(
                            label: '[필수] 개인정보 처리방침 동의',
                            checked: _agreeTerms2,
                            onChanged: (v) =>
                                setState(() => _agreeTerms2 = v ?? false),
                            onView: _showComingSoon,
                          ),
                          TermsRow(
                            label: '[필수] 만 14세 이상입니다',
                            checked: _agreeTerms3,
                            onChanged: (v) =>
                                setState(() => _agreeTerms3 = v ?? false),
                            onView: _showComingSoon,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 하단 고정 회원가입 버튼
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _handleSubmit : null,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey[700];
                      }
                      return const Color(0xFFFF3278);
                    }),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    elevation: MaterialStateProperty.all<double>(0),
                  ),
                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
