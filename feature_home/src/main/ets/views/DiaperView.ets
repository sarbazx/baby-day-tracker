import { ADD_BABY_LOG_PAGE } from '../../../../Index';
import { SizeConstants } from '../lib/SizeConstants';
import { Diaper, DiaperType } from '../models/Diaper';
import DiaperViewModel from '../viewmodels/DiaperViewModel';

@Component
export struct DiaperView {
  @Consume('pageStack') pageStack: NavPathStack;
  private viewModel: DiaperViewModel = new DiaperViewModel();
  @Prop @Require babyId: number;
  @State diaper: Diaper | null = null;

  loadLatestDiaper() {
    this
      .viewModel
      .loadLatestDiaper(this.babyId)
      .then((diaper) => this.diaper = diaper)
  }

  aboutToAppear(): void {
    this.loadLatestDiaper();
  }

  @Builder
  addDiaperBuilder() {
    Row({ space: 2 }) {
      Image($r('app.media.add_diaper'))
        .width($r('app.float.icon_size'))
        .height($r('app.float.icon_size'))
      Text('Add Diaper')
        .fontColor(Color.White)
        .fontSize($r('app.float.item_subtitle_font_size'))
        .textAlign(TextAlign.Center)
    }
    .borderWidth(1)
    .borderColor($r('app.color.background_border_color'))
    .backgroundColor($r('app.color.background_color'))
    .borderRadius($r('sys.float.segment_button_height'))
    .onClick(() => {
      this.pageStack.pushPathByName(ADD_BABY_LOG_PAGE, [this.babyId], () => {
        this.loadLatestDiaper();
      })
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .padding({
      top: '6vp',
      right: '8vp',
      bottom: '6vp',
      left: '8vp'
    })
  }

  build() {
    Column() {
      if (this.diaper) {
        Row({ space: 4 }) {
          Row() {
            Image($r('app.media.diaper'))
              .width($r('app.float.icon_size'))
              .height($r('app.float.icon_size'))
            Text(this.diaper.date)
              .fontSize($r('app.float.item_title_font_size'))
              .fontWeight(FontWeight.Bold)
          }
          .backgroundColor($r('app.color.brand_color'))
          .borderColor($r('app.color.background_border_color'))
          .borderRadius($r('sys.float.segment_button_height'))
          .borderWidth(1)
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .padding({
            top: '6vp',
            right: '8vp',
            bottom: '6vp',
            left: '8vp'
          })

          Row() {
            Image(this.diaper.type === DiaperType.pee ? $r('app.media.pee') : $r('app.media.poop'))
              .width($r('app.float.icon_size'))
              .height($r('app.float.icon_size'))
            Text(this.diaper.type === DiaperType.pee ? 'Pee' : 'Poop')
              .fontSize($r('app.float.item_title_font_size'))
              .fontWeight(FontWeight.Bold)
          }
          .backgroundColor($r('app.color.on_brand_color'))
          .borderColor($r('app.color.background_border_color'))
          .borderWidth(1)
          .borderRadius($r('sys.float.segment_button_height'))
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
          .padding({
            top: '6vp',
            right: '8vp',
            bottom: '6vp',
            left: '8vp'
          })
        }
        .margin({ bottom: '8vp' })
        .width('100%')
      }
      this.addDiaperBuilder()
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width(SizeConstants.FULL_PERCENT)

  }
}