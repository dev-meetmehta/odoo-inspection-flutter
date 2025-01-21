import 'package:lookover/lookover.dart';
import '../widgets/login_footer.dart';
import '../widgets/login_form.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    return Scaffold(
        body: SingleChildScrollView(
     // reverse: true,
      child: CAllPadding(
        size: PaddingConstant().padding,
        child: CCommonWidget().CommonWidgetBox(
          height: sizeScreen.height,
          child: FullScreenLoader(
            widgetId: LoaderWidgetId.loginScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(
                  flex: 2,
                ),
                CCommonWidget().ImageAssets(
                    path: AppImagePaths().bottomLogo,
                    height: sizeScreen.height * .2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CTextBlack(StringConstant().inspect, mBold: true, mSize: NumberConstant().double_Title),
                    CTextBlack(
                      StringConstant().yourQuality,
                      mSize: NumberConstant().regular,
                    )
                  ],
                ),
                const Spacer(
                  flex: 1,
                ),
                LoginForm(),
                const Spacer(
                  flex: 2,
                ),
                LoginFooter(),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
