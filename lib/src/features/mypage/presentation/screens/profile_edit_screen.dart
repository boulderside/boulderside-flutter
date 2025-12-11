import 'dart:io';

import 'package:boulderside_flutter/src/core/user/data/services/nickname_service.dart';
import 'package:boulderside_flutter/src/core/user/providers/user_providers.dart';
import 'package:boulderside_flutter/src/shared/utils/random_nickname_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  static const _accentColor = Color(0xFFFF3278);
  static const _cardColor = Color(0xFF262A34);

  bool _checking = false;
  bool _saving = false;
  bool? _nicknameAvailable;
  String? _lastCheckedNickname;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userStoreProvider).user;
    _nicknameController.text = user?.nickname ?? '';
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStoreProvider);
    final nicknameService = ref.watch(nicknameServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        foregroundColor: Colors.white,
        title: const Text(
          '프로필 수정',
          style: TextStyle(fontFamily: 'Pretendard', fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                Builder(
                  builder: (context) {
                    final hasImage =
                        _selectedImage != null ||
                        (userState.user?.profileImageUrl?.isNotEmpty ?? false);
                    return CircleAvatar(
                      radius: 48,
                      backgroundColor: hasImage
                          ? Colors.transparent
                          : const Color(0xFF2E3342),
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : userState.user?.profileImageUrl != null
                          ? NetworkImage(userState.user!.profileImageUrl!)
                          : null,
                      child: hasImage
                          ? null
                          : const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white54,
                            ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Material(
                    color: const Color(0xFFFF3278),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _pickImage,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '닉네임',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nicknameController,
            style: const TextStyle(color: Colors.white),
            onChanged: (_) => _handleNicknameChanged(),
            decoration: InputDecoration(
              hintText: '사용할 닉네임을 입력하세요',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: _cardColor,
              prefixIcon: IconButton(
                onPressed: _generateRandomNickname,
                icon: const Icon(Icons.casino),
                color: Colors.white70,
                tooltip: '랜덤 닉네임 생성',
              ),
              suffixIcon: _checking
                  ? Transform.scale(
                      scale: 0.5,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: _accentColor,
                      ),
                    )
                  : TextButton(
                      onPressed: () => _checkNickname(nicknameService),
                      child: Text(
                        '중복확인',
                        style: TextStyle(
                          color: _accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _accentColor),
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_nicknameAvailable != null)
            Text(
              _nicknameAvailable! ? '사용 가능한 닉네임입니다.' : '이미 사용 중인 닉네임입니다.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: _nicknameAvailable!
                    ? const Color(0xFF41E69B)
                    : Colors.redAccent,
              ),
            ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saving ? null : () => _saveChanges(nicknameService),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3278),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '저장',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkNickname(NicknameService nicknameService) async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      _showSnackBar('닉네임을 입력해주세요.');
      return;
    }
    setState(() {
      _checking = true;
      _nicknameAvailable = null;
    });
    try {
      final available = await nicknameService.checkNicknameAvailability(
        nickname,
      );
      setState(() {
        _nicknameAvailable = available;
        _lastCheckedNickname = nickname;
      });
    } catch (_) {
      _showSnackBar('닉네임을 확인할 수 없습니다. 잠시 후 다시 시도해주세요.');
    } finally {
      setState(() => _checking = false);
    }
  }

  Future<void> _saveChanges(NicknameService nicknameService) async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      _showSnackBar('닉네임을 입력해주세요.');
      return;
    }

    final userStore = ref.read(userStoreProvider.notifier);
    final currentUser = ref.read(userStoreProvider).user;
    if (currentUser == null) {
      _showSnackBar('로그인이 필요합니다.');
      return;
    }

    final nicknameChanged = nickname != currentUser.nickname;
    final imageChanged = _selectedImage != null;
    if (!nicknameChanged && !imageChanged) {
      _showSnackBar('변경된 내용이 없습니다.');
      return;
    }

    if (nicknameChanged) {
      final checkedCurrentNickname =
          _nicknameAvailable == true && _lastCheckedNickname == nickname;
      if (!checkedCurrentNickname) {
        _showSnackBar('닉네임 중복 확인을 완료해주세요.');
        return;
      }
    }

    setState(() {
      _saving = true;
      if (nicknameChanged) {
        _nicknameAvailable = null;
      }
    });

    File? resizedTempFile;
    try {
      var updatedUser = currentUser;

      if (nicknameChanged) {
        await nicknameService.updateNickname(nickname);
        updatedUser = updatedUser.copyWith(nickname: nickname);
      }

      if (imageChanged && _selectedImage != null) {
        resizedTempFile = await _createResizedImage(_selectedImage!);
        final uploadFile = resizedTempFile ?? _selectedImage!;
        final profileUrl = await nicknameService.updateProfileImage(uploadFile);
        if (profileUrl == null) {
          throw Exception('이미지 업로드 실패');
        }
        updatedUser = updatedUser.copyWith(profileImageUrl: profileUrl);
      }

      await userStore.updateUser(updatedUser);
      if (mounted) {
        _showSnackBar('프로필이 업데이트되었습니다.');
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('프로필을 저장하지 못했습니다. 잠시 후 다시 시도해주세요.');
      }
    } finally {
      if (resizedTempFile != null) {
        try {
          final parentDir = resizedTempFile.parent;
          if (await parentDir.exists()) {
            await parentDir.delete(recursive: true);
          } else if (await resizedTempFile.exists()) {
            await resizedTempFile.delete();
          }
        } catch (_) {
          // ignore cleanup errors
        }
      }
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final result = await _picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      setState(() {
        _selectedImage = File(result.path);
      });
    }
  }

  void _generateRandomNickname() {
    final randomNickname = RandomNicknameGenerator.generate();
    _nicknameController.text = randomNickname;
    _nicknameController.selection = TextSelection.fromPosition(
      TextPosition(offset: randomNickname.length),
    );
    setState(() {
      _nicknameAvailable = null;
      _lastCheckedNickname = null;
    });
  }

  Future<File?> _createResizedImage(File original) async {
    try {
      final bytes = await original.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        return null;
      }

      final resizedImage = img.copyResize(
        decodedImage,
        width: 512,
        height: 512,
        interpolation: img.Interpolation.linear,
      );

      final tempDir = await Directory.systemTemp.createTemp('profile_image');
      final resizedFile = File('${tempDir.path}/profile_512.png');
      await resizedFile.writeAsBytes(img.encodePng(resizedImage));
      return resizedFile;
    } catch (_) {
      return null;
    }
  }

  void _handleNicknameChanged() {
    final currentText = _nicknameController.text.trim();
    if (_lastCheckedNickname != null &&
        currentText != _lastCheckedNickname &&
        _nicknameAvailable != null) {
      setState(() => _nicknameAvailable = null);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
