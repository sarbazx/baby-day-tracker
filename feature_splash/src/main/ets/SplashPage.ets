import { Loader } from './components/Loader';

@Builder
export function SplashPageBuilder(name: string, param: Object) {
  SplashPage()
}

@Component
export struct SplashPage {
  pageInfos: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    setTimeout(() => {
      this.pageInfos.pushPathByName('HomePage', null);
    }, 1000)
  }

  build() {
    NavDestination() {
      Loader()
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
  }
}