import { DEFAULT_ERROR_MESSAGE, DEFAULT_RETRY_LABEL } from '../models/UiState';

@Component
export struct ErrorState {
  @Prop message: string = DEFAULT_ERROR_MESSAGE;
  @Prop retryLabel: string = DEFAULT_RETRY_LABEL;
  onRetry?: () => void;

  build() {
    Column() {
      Text(this.message)
        .fontSize($r('app.float.item_title_font_size'))
        .fontColor($r('app.color.brand_border_color'))
        .textAlign(TextAlign.Center)
        .width('80%')

      if (this.onRetry) {
        Blank(12)
        Button(this.retryLabel)
          .fontSize($r('app.float.item_title_font_size'))
          .fontColor(Color.White)
          .backgroundColor($r('app.color.brand_color'))
          .borderRadius($r('sys.float.segment_button_height'))
          .padding({
            left: 16,
            right: 16,
            top: 6,
            bottom: 6
          })
          .onClick(() => {
            if (this.onRetry) {
              this.onRetry();
            }
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
