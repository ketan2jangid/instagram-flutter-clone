import 'package:image_picker/image_picker.dart';

imageSelector(ImageSource source) async {
  final ImagePicker _picker = ImagePicker();

  XFile? _img = await _picker.pickImage(source: source);

  if (_img == null) {
    print('No image selected');

    return null;
  }

  return _img.readAsBytes();
}
