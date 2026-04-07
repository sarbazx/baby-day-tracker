import { SPLASH_PAGE, SplashPage } from 'feature_splash';
import {
  ADD_BABY_LOG_PAGE,
  ADD_BABY_PAGE,
  AddBabyLogPage,
  AddBabyPage,
  BABY_PAGE,
  BabyPage,
  DIAPER_DETAIL_PAGE,
  DiaperDetailPage,
  EDIT_BABY_PAGE,
  EditBabyPage,
  HISTORY_PAGE,
  HistoryPage,
  HOME_PAGE,
  HomePage,
  INSIGHTS_PAGE,
  InsightsPage,
  ONBOARDING_PAGE,
  OnboardingPage,
  SETTINGS_PAGE,
  SettingsPage
} from 'feature_home';

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
    } else if (builderName === EDIT_BABY_PAGE) {
      EditBabyPage()
    } else if (builderName === HISTORY_PAGE) {
      HistoryPage()
    } else if (builderName === INSIGHTS_PAGE) {
      InsightsPage()
    } else if (builderName === SETTINGS_PAGE) {
      SettingsPage()
    } else if (builderName === ONBOARDING_PAGE) {
      OnboardingPage()
    } else if (builderName === DIAPER_DETAIL_PAGE) {
      DiaperDetailPage()
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
