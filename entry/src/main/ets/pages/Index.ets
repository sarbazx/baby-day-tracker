import { SPLASH_PAGE, SplashPage } from 'feature_splash';
import { BABY_PAGE, BabyPage, HOME_PAGE, HomePage, ADD_BABY_PAGE, AddBabyPage, ADD_BABY_LOG_PAGE,
  AddBabyLogPage } from 'feature_home';

@Entry
@Component
struct Index {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  routerMap(builderName: string, param: object) {
    if (builderName === SPLASH_PAGE) {
      SplashPage()
    } else if (builderName === HOME_PAGE) {
      HomePage()
    } else if (builderName === BABY_PAGE) {
      BabyPage()
    } else if (builderName === ADD_BABY_PAGE) {
      AddBabyPage()
    } else if (builderName === ADD_BABY_LOG_PAGE) {
      AddBabyLogPage()
    }
  }

  aboutToAppear(): void {
    this.pageStack.pushPathByName(SPLASH_PAGE, null);
  }

  build() {
    Navigation(this.pageStack) {
    }
    .hideTitleBar(true)
    .hideBackButton(true)
    .ignoreLayoutSafeArea()
    .mode(NavigationMode.Stack)
    .navDestination(this.routerMap)
    .backgroundColor($r('app.color.background_color'))
  }
}