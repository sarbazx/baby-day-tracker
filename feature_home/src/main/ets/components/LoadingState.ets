@Component
export struct LoadingState {
  build() {
    Column() {
      LoadingProgress()
        .width($r('app.float.icon_bigger_size'))
        .height($r('app.float.icon_bigger_size'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
