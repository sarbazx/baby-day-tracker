import { Baby } from '../models/Baby';
import BabyViewModel from '../viewmodels/BabyViewModel';
import { BabyView } from '../views/BabyView';

@Component
export struct BabyPage {
  @State baby: Baby = Baby.empty();
  private viewModel: BabyViewModel = new BabyViewModel();

  build() {
    NavDestination() {
      if (this.baby.id === -1) {
        LoadingProgress()
          .width($r('app.float.icon_bigger_size'))
          .height($r('app.float.icon_bigger_size'))
      } else {
        BabyView({ baby: this.baby })
      }
    }
    .hideBackButton(true)
    .onReady((context) => {
      const params = context.pathStack.getParamByName('BabyPage') as number[];
      if (params.length > 0) {
        const babyId = parseInt(`${params[0]}`)
        this.viewModel.loadBabyById(babyId).then((baby) => this.baby = baby);
      }
    })
  }
}