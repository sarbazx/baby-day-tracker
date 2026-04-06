import { SizeConstants } from '../lib/SizeConstants';
import { Baby } from '../models/Baby';
import { DiaperView } from './DiaperView';

@Component
export struct BabyView {
  @Consume('pageStack') pageStack: NavPathStack;
  @Prop @Require baby: Baby;

  build() {
    Column() {
      DiaperView({ baby: this.baby })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .width(SizeConstants.FULL_PERCENT)
    .height(SizeConstants.FULL_PERCENT)
  }
}