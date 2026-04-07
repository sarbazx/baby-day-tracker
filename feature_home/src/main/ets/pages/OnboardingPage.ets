import { AppPreferencesService } from 'feature_store';
import { ArcButton, ArcButtonOptions, ArcButtonStyleMode, ColorMetrics, LengthMetrics, LengthUnit } from '@kit.ArkUI';
import { SizeConstants } from '../lib/SizeConstants';

@Component
export struct OnboardingPage {
  options: ArcButtonOptions = new ArcButtonOptions({});
  @State private currentIndex: number = 0;
  private pageInfos: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    try {
      this.options = new ArcButtonOptions({
        label: 'Get Started',
        styleMode: ArcButtonStyleMode.CUSTOM,
        backgroundColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
        fontSize: new LengthMetrics(15, LengthUnit.FP),
        shadowEnabled: true,
        onClick: () => this.completeOnboarding()
      })
    } catch (error) {
      console.error(`[OnboardingPage] ${error}`);
    }
  }

  @Builder
  slide(icon: string, title: string, subtitle: string) {
    Column() {
      Text(icon)
        .fontSize('40fp')
        .margin({ bottom: 16 })
      Text(title)
        .fontSize('16fp')
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.on_primary_color'))
        .textAlign(TextAlign.Center)
        .margin({ bottom: 8 })
      Text(subtitle)
        .fontSize('12fp')
        .fontColor($r('app.color.on_primary_color'))
        .opacity(0.8)
        .textAlign(TextAlign.Center)
        .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  dotIndicator(index: number) {
    Column() {
      if (index === this.currentIndex) {
        Circle()
          .fill($r('app.color.brand_color'))
          .width('6vp')
          .height('6vp')
      } else {
        Circle()
          .fill($r('app.color.on_primary_color'))
          .opacity(0.3)
          .width('6vp')
          .height('6vp')
      }
    }
    .width('6vp')
    .height('6vp')
    .margin({ left: 3, right: 3 })
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Swiper() {
            this.slide('💧', 'Track Every Change', 'Log diaper changes quickly with just a tap')
            this.slide('📊', 'See Trends & Insights', 'Monitor patterns and get overdue alerts')
            this.slide('⏰', 'Stay on Top of Care', 'Set reminders so nothing gets missed')
          }
          .index(this.currentIndex)
          .onChange((index: number) => {
            this.currentIndex = index;
          })
          .displayCount(1)
          .loop(false)
          .indicator(false)
          .width('100%')
          .height('65%')

          Row() {
            this.dotIndicator(0)
            this.dotIndicator(1)
            this.dotIndicator(2)
          }
          .margin({ top: 12, bottom: 24 })

        }
        .width(SizeConstants.FULL_PERCENT)
        .height(SizeConstants.FULL_PERCENT)

        ArcButton({
          options: this.options
        }).align(Alignment.Bottom)

      }
      .width(SizeConstants.FULL_PERCENT)
      .height(SizeConstants.FULL_PERCENT)
      .alignContent(Alignment.Bottom)
      .backgroundColor($r('app.color.background_color'))
    }
    .hideBackButton(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }

  private async completeOnboarding(): Promise<void> {
    try {
      const service = await AppPreferencesService.getInstance();
      await service.setOnboardingCompleted(true);
    } catch (error) {
      console.error(`[OnboardingPage] ${error}`);
    }
    this.pageInfos.clear();
    this.pageInfos.pushPathByName('HomePage', null);
  }
}
