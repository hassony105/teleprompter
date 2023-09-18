import 'package:camera/camera.dart';
import 'package:teleprompter/src/data/services/cameraService/camera_dectector.dart';
import 'package:teleprompter/src/data/services/camera_service.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';

mixin RecorderState {
  bool _isRecording = false;
  bool _isCameraReady = false;

  Future<void> prepareCamera() async {
    await CameraService().startCameras();
    await CameraService().selectCamera();
    _isCameraReady = true;
  }

  bool isRecording() => _isRecording;

  Future<void> startRecording(TeleprompterState teleprompterState) async {
    _isRecording = true;

    await CameraService().startRecording(teleprompterState);
  }

  Future<void> toggleCamera() async {
    if(CameraService().cameraController?.description.lensDirection == CameraLensDirection.front) {
      await CameraService().selectCamera();
    } else {
      await CameraService().selectCamera(CameraLensDirection.front);
    }
  }

  Future<bool> stopRecording() async {
    _isRecording = false;

    return CameraService().stopRecording();
  }

  bool isCameraReady() => _isCameraReady;

  void disposeCamera() {
    _isCameraReady = false;
  }
}
