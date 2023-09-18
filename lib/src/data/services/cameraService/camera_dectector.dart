import 'package:camera/camera.dart';
import 'package:teleprompter/src/shared/app_logger.dart';

List<CameraDescription> cameras = [];

class CameraDetector {
  bool _cameraReady = false;
  CameraController? cameraController;

  Future<void> startCameras() async {
    cameras = await availableCameras();
  }

  bool isCameraReady() => _cameraReady;

  CameraController? getCameraController() => cameraController;

  Future<void> selectCamera([CameraLensDirection direction = CameraLensDirection.back]) async {
    for (final CameraDescription cameraDescription in cameras) {
      if (cameraDescription.lensDirection == direction) {
        await onNewCameraSelected(cameraDescription);
        _cameraReady = true;
      }
    }
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.veryHigh,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // If the controller is updated then update the UI.
    cameraController!.addListener(() {
      AppLogger().debug('camera event: ${cameraController!.value}');
      if (cameraController!.value.hasError) {
        AppLogger().debug('Camera error ${cameraController!.value.errorDescription}');
      }
    });

    try {
      await cameraController!.initialize();
    } on CameraException {
      rethrow;
    }
  }
}
