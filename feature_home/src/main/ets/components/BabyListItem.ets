import { ArcListItem, ArcListItemAttribute } from '@ohos.arkui.ArcList';
import { SizeConstants } from '../lib/SizeConstants';

export interface BabyListItemSummary {
  lastChange?: Date;
  todayCount: number;
  isOverdue: boolean;
}

interface ItemParams {
  readonly title: string;
  readonly subtitle: string;
  readonly image: string | Resource;
  readonly summary?: BabyListItemSummary;
  readonly onQuickPee?: () => void;
  readonly onQuickPoo?: () => void;
}

@Builder
export function BabyListItem(params: ItemParams) {
  ArcListItem() {
    Column({ space: 4 }) {
      Row() {
        Image(params.image)
          .width($r('app.float.icon_size'))
          .height($r('app.float.icon_size'))
        Column() {
          Text(params.title)
            .fontSize($r('app.float.item_title_font_size'))
            .fontWeight(FontWeight.Bold)
          if (params.summary) {
            Text(`${params.summary.todayCount} today`)
              .fontSize('9fp')
              .fontColor($r('app.color.on_primary_color'))
            if (params.summary.isOverdue) {
              Text('Overdue')
                .fontSize('9fp')
                .fontColor($r('app.color.brand_border_color'))
                .fontWeight(FontWeight.Bold)
            }
          }
        }
        .margin({ left: '8vp' })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      if (params.summary && params.summary.lastChange) {
        Text(`Last: ${params.subtitle}`)
          .fontSize('9fp')
          .fontColor($r('app.color.on_primary_color'))
          .width('100%')
      }

      if (params.onQuickPee || params.onQuickPoo) {
        Row({ space: 6 }) {
          if (params.onQuickPee) {
            Button() {
              Row() {
                Image($r('app.media.pee'))
                  .width($r('app.float.icon_size'))
                  .height($r('app.float.icon_size'))
                Text('Pee')
                  .fontSize($r('app.float.item_title_font_size'))
                  .fontWeight(FontWeight.Bold)
              }
            }
            .fontSize('10fp')
            .fontColor(Color.White)
            .backgroundColor($r('app.color.brand_color'))
            .borderRadius($r('sys.float.segment_button_height'))
            .padding({
              left: 10,
              right: 10,
              top: 3,
              bottom: 3
            })
            .onClick(() => {
              if (params.onQuickPee) {
                params.onQuickPee();
              }
            });
          }
          if (params.onQuickPoo) {
            Button() {
              Row() {
                Image($r('app.media.poop'))
                  .width($r('app.float.icon_size'))
                  .height($r('app.float.icon_size'))
                Text('Poop')
                  .fontSize($r('app.float.item_title_font_size'))
                  .fontWeight(FontWeight.Bold)
              }
            }
            .fontSize('10fp')
            .fontColor(Color.White)
            .backgroundColor($r('app.color.on_brand_color'))
            .borderRadius($r('sys.float.segment_button_height'))
            .padding({
              left: 10,
              right: 10,
              top: 3,
              bottom: 3
            })
            .onClick(() => {
              if (params.onQuickPoo) {
                params.onQuickPoo();
              }
            });
          }
        }
        .width(SizeConstants.FULL_PERCENT)
        .margin({ top: 4 })
      }
    }
    .backgroundColor(params.summary?.isOverdue ? 'rgba(255,0,0,0.1)' : Color.Gray)
    .borderWidth(1)
    .borderColor(params.summary?.isOverdue ? $r('app.color.brand_border_color') :
      $r('app.color.background_border_color'))
    .borderRadius($r('sys.float.segment_button_height'))
    .width('100%')
    .padding({
      top: '10vp',
      right: '14vp',
      bottom: '10vp',
      left: '14vp'
    })
  }
}
