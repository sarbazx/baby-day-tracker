import { ArcListItem, ArcListItemAttribute } from '@ohos.arkui.ArcList';

interface ItemParams {
  readonly title: string;
  readonly subtitle: string;
  readonly image: string | Resource;
}

@Builder
export function BabyListItem(params: ItemParams) {
  ArcListItem() {
    Row() {
      Image(params.image)
        .width($r('app.float.icon_size'))
        .height($r('app.float.icon_size'))
      Column() {
        Text(params.title)
          .fontSize($r('app.float.item_title_font_size'))
          .fontWeight(FontWeight.Bold)
        Blank(2)
        Text(params.subtitle)
          .fontSize($r('app.float.item_subtitle_font_size'))
      }
      .margin({ left: '8vp' })
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor(Color.Gray)
    .borderWidth(1)
    .borderRadius($r('sys.float.segment_button_height'))
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .padding({
      top: '10vp',
      right: '14vp',
      bottom: '10vp',
      left: '14vp'
    })
  }
}