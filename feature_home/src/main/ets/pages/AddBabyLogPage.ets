import { SizeConstants } from '../lib/SizeConstants';
import { ArcButton, ArcButtonOptions, ArcButtonStyleMode, ColorMetrics, LengthMetrics, LengthUnit } from '@kit.ArkUI';
import { DiaperType } from '../models/Diaper';
import DiaperViewModel from '../viewmodels/DiaperViewModel';
import { ADD_BABY_LOG_PAGE } from '../../../../Index';

@Component
export struct AddBabyLogPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State diaperType: DiaperType = DiaperType.pee;
  private options: ArcButtonOptions = new ArcButtonOptions({});
  private viewModel: DiaperViewModel = new DiaperViewModel()

  arcButtonInit() {
    try {
      this.options = new ArcButtonOptions({
        label: 'Add Diaper',
        styleMode: ArcButtonStyleMode.CUSTOM,
        fontSize: new LengthMetrics(15, LengthUnit.FP),
        shadowEnabled: true,
        backgroundColor: ColorMetrics.resourceColor($r('app.color.brand_color')),
        onClick: () => {
          const params = this.pageStack.getParamByName(ADD_BABY_LOG_PAGE) as number[];
          if (params.length > 0) {
            const babyId = params[0] as number;
            this.viewModel.addDiaper(babyId, this.diaperType).then(() => {
              this.pageStack.pop({ result: true })
            })
          }
        },
      })
    } catch (err) {
      console.error(`[BabyDayTracker] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  aboutToAppear(): void {
    this.arcButtonInit()
  }

  @Builder
  diaperTypeSelectionBuilder() {
    Row({ space: 8 }) {
      Column() {
        Image($r('app.media.pee'))
          .width($r('app.float.icon_bigger_size'))
          .height($r('app.float.icon_bigger_size'))
        Text('Pee')
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .fontSize($r('app.float.item_title_font_size'))
      }
      .borderWidth(1)
      .borderColor(this.diaperType === DiaperType.pee ? $r('app.color.brand_border_color') :
        $r('app.color.background_border_color'))
      .backgroundColor(this.diaperType === DiaperType.pee ? $r('app.color.brand_color') :
        $r('app.color.background_color'))
      .borderRadius($r('sys.float.segment_button_height'))
      .padding('8vp')
      .onClick(() => {
        this.diaperType = DiaperType.pee;
      })

      Column() {
        Image($r('app.media.poop'))
          .width($r('app.float.icon_bigger_size'))
          .height($r('app.float.icon_bigger_size'))
        Text('Poop')
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .fontSize($r('app.float.item_title_font_size'))
      }
      .borderWidth(1)
      .borderColor(this.diaperType === DiaperType.poo ? $r('app.color.brand_border_color') :
        $r('app.color.background_border_color'))
      .backgroundColor(this.diaperType === DiaperType.poo ? $r('app.color.brand_color') :
        $r('app.color.background_color'))
      .borderRadius($r('sys.float.segment_button_height'))
      .padding('8vp')
      .onClick(() => {
        this.diaperType = DiaperType.poo;
      })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width(SizeConstants.FULL_PERCENT)
    .height('50%')
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
          Text('Select Diaper Type')
            .fontSize(10)
          this.diaperTypeSelectionBuilder()
        }

        ArcButton({
          options: this.options
        }).align(Alignment.Bottom)
      }
      .width(SizeConstants.FULL_PERCENT)
      .height(SizeConstants.FULL_PERCENT)
    }
    .hideBackButton(true)
  }
}