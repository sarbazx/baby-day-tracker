import { SettingsView } from '../views/SettingsView';

@Component
export struct SettingsPage {
  build() {
    NavDestination() {
      SettingsView()
    }
    .hideBackButton(true)
  }
}
