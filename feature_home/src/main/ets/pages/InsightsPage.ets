import { InsightsParams } from './PageParams';
import { Baby } from '../models/Baby';
import { BabyRepository, GlobalContext } from 'feature_store';
import { InsightsView } from '../views/InsightsView';

@Component
export struct InsightsPage {
  @State params: InsightsParams = { babyId: -1 };
  @State baby: Baby | null = null;

  build() {
    NavDestination() {
      if (this.baby && this.baby.id !== -1) {
        InsightsView({ baby: this.baby })
      } else {
        Column() {
          Text('Loading...')
            .fontSize('14fp')
            .fontColor(Color.White)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .hideBackButton(true)
    .onReady((context) => {
      const param = context.pathInfo.param as Record<string, Object>;
      const babyIdVal = param['babyId'];
      if (babyIdVal !== undefined && babyIdVal !== null) {
        this.params = { babyId: babyIdVal as number };
        const ctx = GlobalContext.getInstance().getSavedContext();
        if (ctx) {
          BabyRepository.getInstance(ctx).then(async (repo) => {
            const iBaby = await repo.getBabyById(this.params.babyId);
            if (iBaby && iBaby.id !== undefined) {
              this.baby = new Baby(
                iBaby.id,
                iBaby.name,
                iBaby.dateOfBirth,
                iBaby.image,
                iBaby.gender,
                iBaby.isArchived ?? false,
                iBaby.archivedAt
              );
            }
          });
        }
      }
    })
  }
}
