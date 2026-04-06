import { ADD_BABY_LOG_PAGE } from '../../../../Index';
import { SizeConstants } from '../lib/SizeConstants';
import { Diaper, DiaperType } from '../models/Diaper';
import DiaperViewModel from '../viewmodels/DiaperViewModel';
import { ArcList, ArcListItem } from '@ohos.arkui.ArcList';
import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  ColorMetrics,
  ComponentContent,
  LengthMetrics,
  LengthUnit,
  ArcListAttribute,
  ArcListItemAttribute
} from '@kit.ArkUI';
import { Baby } from '../models/Baby';

@Builder
function diaperHeaderBuilder(baby: Baby) {
  Row({ space: 10 }) {
    Image(baby.image)
      .width($r('app.float.icon_bigger_size'))
      .height($r('app.float.icon_bigger_size'))
    Text(baby.name)
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
}

@Component
export struct DiaperView {
  @Consume('pageStack') pageStack: NavPathStack;
  @Prop @Require baby: Baby;
  context: UIContext = this.getUIContext();
  headerBuilder: WrappedBuilder<[Baby]> = wrapBuilder(diaperHeaderBuilder);
  header: ComponentContent<Object> =
    new ComponentContent(this.context, this.headerBuilder, this.baby);
  options: ArcButtonOptions = new ArcButtonOptions({})
  private viewModel: DiaperViewModel = new DiaperViewModel();
  @State diapers: Diaper[] = [];

  aboutToAppear(): void {
    this.viewModel.loadDiapers(this.baby.id);
    this.initAddDiaperBtn();
  }

  initAddDiaperBtn() {
    try {
      this.options = new ArcButtonOptions({
        label: 'Add Log',
        styleMode: ArcButtonStyleMode.CUSTOM,
        backgroundColor: ColorMetrics.resourceColor($r('app.color.background_color')),
        fontSize: new LengthMetrics(15, LengthUnit.FP),
        shadowEnabled: true,
        onClick: () => {
          this.pageStack.pushPathByName(ADD_BABY_LOG_PAGE, [this.baby.id], () => {
            this.viewModel.loadDiapers(this.baby.id)
          })
        }
      })
    } catch (error) {
    }
  }

  @Builder
  diaperViewItem(diaper: Diaper) {
    Row({ space: 4 }) {
      Row() {
        Image($r('app.media.diaper'))
          .width($r('app.float.icon_size'))
          .height($r('app.float.icon_size'))
        Text(diaper.date)
          .fontSize($r('app.float.item_title_font_size'))
          .fontWeight(FontWeight.Bold)
      }
      .backgroundColor($r('app.color.brand_color'))
      .borderColor($r('app.color.background_border_color'))
      .borderRadius($r('sys.float.segment_button_height'))
      .borderWidth(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .padding({
        top: '6vp',
        right: '8vp',
        bottom: '6vp',
        left: '8vp'
      })

      Row() {
        Image(diaper.type === DiaperType.pee ? $r('app.media.pee') : $r('app.media.poop'))
          .width($r('app.float.icon_size'))
          .height($r('app.float.icon_size'))
        Text(diaper.type === DiaperType.pee ? 'Pee' : 'Poop')
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
    .width('90%')
  }

  build() {
    Stack() {
      ArcList({ header: this.header }) {
        LazyForEach(this.viewModel.datasource, (diaper: Diaper) => {
          ArcListItem() {
            this.diaperViewItem(diaper);
          }
        })
      }
      .cachedCount(5)
      .layoutWeight(1)

      ArcButton({
        options: this.options
      }).align(Alignment.Bottom)

    }
    .width(SizeConstants.FULL_PERCENT)
    .height(SizeConstants.FULL_PERCENT)
    .alignContent(Alignment.Bottom)
  }
}