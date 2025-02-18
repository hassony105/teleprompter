import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';
import 'package:teleprompter/src/shared/app_logger.dart';
import 'package:teleprompter/src/ui/textScroller/text_scroller_options_component.dart';
import 'package:teleprompter/src/ui/textScroller/text_scroller_oriented_component.dart';

/// This class represents the TextScrollerComponent, a StatefulWidget that provides
/// functionality for displaying text and controlling its scrolling behavior.
class TextScrollerComponent extends StatefulWidget {
  /// The title of the widget, typically used as the app bar title.
  final String title;
  final String opacityLabel;
  final String speedLabel;
  final String fontSizeLabel;
  final String pauseLabel;
  final String playLabel;
  final Color color;

  /// The text content to be displayed and scrolled.
  final String text;

  /// A message to be displayed when the recording is successfully saved to the gallery.
  final String savedToGallery;

  /// An error message to be displayed when there is an issue saving the recording to the gallery.
  final String errorSavingToGallery;

  /// Widget to be used as start recording
  final Widget startRecordingButton;

  /// Widget to be used as stop recording
  final Widget stopRecordingButton;

  /// An optional shape border for the floating action button.
  final ShapeBorder? floatingButtonShape;

  const TextScrollerComponent({
    required this.title,
    required this.text,
    required this.savedToGallery,
    required this.errorSavingToGallery,
    required this.startRecordingButton,
    required this.stopRecordingButton,
    required this.opacityLabel,
    required this.speedLabel,
    required this.fontSizeLabel,
    required this.pauseLabel,
    required this.playLabel,
    required this.color,
    this.floatingButtonShape,
    super.key,
  });

  @override
  _TextScrollerComponentState createState() => _TextScrollerComponentState();
}

class _TextScrollerComponentState extends State<TextScrollerComponent>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final TeleprompterState teleprompterState =
        Provider.of<TeleprompterState>(context, listen: false);

    final ScrollController scrollController = ScrollController(
        initialScrollOffset: teleprompterState.getScrollPosition());
    scrollController.addListener(() {
      teleprompterState.setScrollPosition = scrollController.offset;
    });
    AppLogger()
        .debug('scroll controller clients: ${scrollController.hasClients}');

    if (teleprompterState.isScrolling()) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () {
          if (!scrollController.hasClients) {
            return;
          }
          final double maxExtent = scrollController.position.maxScrollExtent;
          final double distanceDifference = maxExtent - scrollController.offset;
          final double durationDouble =
              distanceDifference / teleprompterState.getSpeedFactor();

          final double max = scrollController.position.maxScrollExtent;
          AppLogger().debug('animate to $max');
          scrollController.animateTo(max,
              duration: Duration(seconds: durationDouble.toInt()),
              curve: Curves.linear);
        },
      );
    } else {
      if (scrollController.hasClients) {
        Future.delayed(Duration.zero, () {
          scrollController.animateTo(scrollController.offset,
              duration: Duration.zero, curve: Curves.linear);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:FittedBox(
                child: Text(
                  widget.title,
                  overflow: TextOverflow.fade,
                ),
              ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: NativeDeviceOrientationReader(
              builder: (context) {
                final orientation =
                    NativeDeviceOrientationReader.orientation(context);
                AppLogger().debug('Received new orientation: $orientation');

                return TextScrollerOrientedComponent(
                  scrollController,
                  orientation,
                  text: widget.text,
                );
              },
            ),
          ),

          TextScrollerOptionsComponent(
              index: teleprompterState.getOptionIndex(),
              updateIndex: (int index) {
                teleprompterState.updateOptionIndex = index;
                teleprompterState.refresh();
              },
            savedToGallery: widget.savedToGallery,
            errorSavingToGallery: widget.errorSavingToGallery,
            opacityLabel: widget.opacityLabel,
            speedLabel: widget.speedLabel,
            fontSizeLabel: widget.fontSizeLabel,
            pauseLabel: widget.pauseLabel,
            playLabel: widget.playLabel,
            sliderColor: widget.color,
          )
        ],
      ),
    );
  }
}
