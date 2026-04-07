import { HomeView } from '../views/HomeView';

@Component
export struct HomePage {
  build() {
    NavDestination() {
      RelativeContainer() {
        HomeView()
      }
      .height('100%')
      .width('100%')
    }.hideBackButton(true)
  }
}