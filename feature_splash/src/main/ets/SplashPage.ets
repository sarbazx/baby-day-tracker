import { Loader } from './components/Loader';
import { AppPreferencesService } from 'feature_store';

@Builder
export function SplashPageBuilder(name: string, param: Object) {
  SplashPage()
}

@Component
export struct SplashPage {
  pageInfos: NavPathStack = new NavPathStack();
  private navigated: boolean = false;

  aboutToAppear(): void {
    this.routeAfterDelay();
  }

  build() {
    NavDestination() {
      Loader()
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }

  private async routeAfterDelay(): Promise<void> {
    await new Promise<void>(resolve => setTimeout(resolve, 1000));
    if (this.navigated) {
      return;
    }
    this.navigated = true;
    let showOnboarding: boolean = false;
    try {
      const service = await AppPreferencesService.getInstance();
      const state = await service.getState();
      showOnboarding = !state.onboardingCompleted;
    } catch {
      // fall through to home
    }
    if (showOnboarding) {
      this.pageInfos.pushPathByName('OnboardingPage', null);
    } else {
      this.pageInfos.pushPathByName('HomePage', null);
    }
  }
}