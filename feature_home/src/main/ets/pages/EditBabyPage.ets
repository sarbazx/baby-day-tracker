import { EditBabyParams } from './PageParams';
import { GenderType } from '../components/GenderSelect';
import { Baby } from '../models/Baby';
import { EditBabyView } from '../views/EditBabyView';
import BabyViewModel from '../viewmodels/BabyViewModel';

@Component
export struct EditBabyPage {
  @State params: EditBabyParams = { babyId: -1 };
  @State baby: Baby = Baby.empty();
  @State loading: boolean = true;
  private viewModel: BabyViewModel = new BabyViewModel();

  aboutToAppear(): void {
    this.loadBaby();
  }

  async loadBaby() {
    if (this.params.babyId > 0) {
      this.baby = await this.viewModel.loadBabyById(this.params.babyId);
    }
    this.loading = false;
  }

  build() {
    NavDestination() {
      if (this.loading || this.baby.isEmpty) {
        Column() {
          LoadingProgress()
            .width('32vp')
            .height('32vp')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        EditBabyView({ baby: this.baby })
      }
    }
    .hideBackButton(true)
    .onReady((context) => {
      const param = context.pathInfo.param as Record<string, Object>;
      const babyIdVal = param['babyId'];
      if (babyIdVal !== undefined && babyIdVal !== null) {
        this.params = { babyId: babyIdVal as number };
        this.loadBaby();
      }
    })
  }
}
