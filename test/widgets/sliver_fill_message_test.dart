import 'package:cineora/app/shared/widgets/sliver_fill_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reports zero intrinsic height while laying out taller, like text whose
/// device font metrics differ from its intrinsic estimate.
class _UnderReportingBox extends SingleChildRenderObjectWidget {
  const _UnderReportingBox({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderUnderReporting();
}

class _RenderUnderReporting extends RenderProxyBox {
  @override
  double computeMaxIntrinsicHeight(double width) => 0;

  @override
  double computeMinIntrinsicHeight(double width) => 0;
}

Future<void> _pump(WidgetTester tester, {required double viewport}) {
  tester.view.physicalSize = Size(320, viewport);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      home: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
          SliverFillMessage(
            child: _UnderReportingBox(
              child: Container(key: const Key('msg'), height: 200),
            ),
          ),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('message keeps its full height when space is short',
      (tester) async {
    await _pump(tester, viewport: 200);

    expect(tester.getSize(find.byKey(const Key('msg'))).height, 200);
    expect(tester.takeException(), isNull);
  });

  testWidgets('message is centred in the remaining space when it fits',
      (tester) async {
    await _pump(tester, viewport: 800);

    final rect = tester.getRect(find.byKey(const Key('msg')));
    expect(rect.height, 200);
    expect(rect.center.dy, closeTo(60 + (800 - 60) / 2, 0.5));
  });
}
