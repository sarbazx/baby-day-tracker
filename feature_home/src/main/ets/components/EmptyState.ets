import { SizeConstants } from '../lib/SizeConstants';

@Component
export struct EmptyState {
  @Prop message: string = 'No data to display';
  @Prop subtitle: string = '';
  @Prop actionLabel: string = '';
  onAction?: () => void;

  build() {
    Column() {
      Text(this.message)
        .fontSize($r('app.float.empty_babies_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.on_primary_color'))
        .textAlign(TextAlign.Center)
        .width(SizeConstants.EIGHTY_PERCENT)

      if (this.subtitle !== '') {
        Text(this.subtitle)
          .fontSize('12fp')
          .fontColor($r('app.color.on_primary_color'))
          .opacity(0.7)
          .textAlign(TextAlign.Center)
          .width(SizeConstants.EIGHTY_PERCENT)
          .width(SizeConstants.EIGHTY_PERCENT)
          .margin({ top: 6 })
      }

      if (this.actionLabel !== '' && this.onAction !== undefined) {
        Blank(12)
        Button(this.actionLabel)
          .fontSize($r('app.float.item_title_font_size'))
          .fontColor($r('app.color.brand_color'))
          .backgroundColor(Color.Transparent)
          .borderColor($r('app.color.brand_color'))
          .borderWidth(1)
          .borderRadius($r('sys.float.segment_button_height'))
          .padding({
            left: 12,
            right: 12,
            top: 6,
            bottom: 6
          })
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      }
    }
    .width(SizeConstants.FULL_PERCENT)
    .height(SizeConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
