import { LottieController, LottieView } from '@ohos/lottie-turbo';

@Component
export struct Loader {
  private controller: LottieController = new LottieController();

  build() {
    Column() {
      LottieView({
        lottieId: 'loader',
        path: $rawfile('loading.json'),
        controller: this.controller,
      })
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}