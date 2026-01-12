import { AddBabyView } from '../views/AddBabyView'

@Component
export struct AddBabyPage {
  build() {
    NavDestination() {
      AddBabyView()
    }
    .hideBackButton(true)
  }
}
