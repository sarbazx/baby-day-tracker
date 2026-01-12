import { SizeConstants } from '../lib/SizeConstants';
import { Baby } from '../models/Baby';
import { DiaperView } from './DiaperView';

@Component
export struct BabyView {
  @Consume('pageStack') pageStack: NavPathStack;
  @Prop @Require baby: Baby;

  build() {
    Column() {
      Row({ space: 10 }) {
        Image(this.baby.image)
          .width($r('app.float.icon_bigger_size'))
          .height($r('app.float.icon_bigger_size'))
        Text(this.baby.name)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .fontSize($r('app.float.label_font_size_2'))
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 14 })
      .width(SizeConstants.FULL_PERCENT)
      .borderRadius(8)
      .padding('8vp')
      .backgroundColor($r('app.color.background_color'))

      DiaperView({ babyId: this.baby.id })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .width('90%')
    .height('100%')
  }
}