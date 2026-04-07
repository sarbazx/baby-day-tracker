import { EDIT_BABY_PAGE, HISTORY_PAGE, INSIGHTS_PAGE } from '../../../../Index';
import { SizeConstants } from '../lib/SizeConstants';
import { Baby } from '../models/Baby';
import { DiaperView } from './DiaperView';
import { AppPreferencesService, ReminderService } from 'feature_store';

@Component
export struct BabyView {
  @Consume('pageStack') pageStack: NavPathStack;
  @Prop @Require baby: Baby;

  build() {
    Column() {


      DiaperView({ baby: this.baby })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width(SizeConstants.FULL_PERCENT)
    .height(SizeConstants.FULL_PERCENT)
  }
}
