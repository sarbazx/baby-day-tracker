import { SizeConstants } from '../lib/SizeConstants';

export enum GenderType {
  boy,
  girl
}


interface GenderSelectParams {
  readonly currentGender: GenderType;
  readonly onClick: Callback<GenderType>
}

@Builder
export function GenderSelect(params: GenderSelectParams) {
  Column() {
    Text('Baby Gender:')
      .margin({ bottom: 10 })
      .textAlign(TextAlign.Center)
      .fontWeight(FontWeight.Bold)
      .fontSize($r('app.float.label_font_size'))
      .fontColor(Color.White)
      .fontColor($r('app.color.on_primary_color'))
      .textAlign(TextAlign.Start)
    Row() {
      Row() {
        Image($r('app.media.boy'))
          .width($r('app.float.icon_size'))
          .height($r('app.float.icon_size'))
          .margin({ right: 10 })
        Text('Boy')
          .fontSize($r('app.float.label_font_size_1'))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .padding(10)
      .borderWidth(2)
      .borderRadius(20)
      .borderColor(params.currentGender === GenderType.boy ? $r('app.color.brand_border_color') :
        $r('app.color.background_border_color'))
      .margin({ right: 10 })
      .backgroundColor(params.currentGender === GenderType.boy ? $r('app.color.brand_color') :
        $r('app.color.background_color'))
      .onClick(() => {
        params.onClick(GenderType.boy);
      })

      Row() {
        Image($r('app.media.girl'))
          .width($r('app.float.icon_size'))
          .height($r('app.float.icon_size'))
          .margin({ right: 10 })
        Text('Girl')
          .fontSize($r('app.float.label_font_size_1'))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .backgroundColor(params.currentGender === GenderType.girl ? $r('app.color.brand_color') :
        $r('app.color.background_color'))
      .padding(10)
      .borderWidth(2)
      .borderRadius(20)
      .borderColor(params.currentGender === GenderType.girl ? $r('app.color.brand_border_color') :
        $r('app.color.background_border_color'))
      .onClick(() => {
        params.onClick(GenderType.girl);
      })
    }

  }
  .width(SizeConstants.FULL_PERCENT)
  .padding(5)
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .margin({ bottom: 20 })
}