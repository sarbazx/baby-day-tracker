import { ADD_BABY_LOG_PAGE, DIAPER_DETAIL_PAGE, EDIT_BABY_PAGE, HISTORY_PAGE, INSIGHTS_PAGE } from '../../../../Index';
import { EmptyState } from '../components/EmptyState';
import { SizeConstants } from '../lib/SizeConstants';
import { Diaper, DiaperType } from '../models/Diaper';
import DiaperViewModel from '../viewmodels/DiaperViewModel';
import { ArcList, ArcListItem } from '@ohos.arkui.ArcList';
import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  ArcListAttribute,
  ArcListItemAttribute,
  ColorMetrics,
  ComponentContent,
  LengthMetrics,
  LengthUnit
} from '@kit.ArkUI';
import { Baby } from '../models/Baby';
import { AppPreferencesService, ReminderService } from 'feature_store';

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
  @State private reminderEnabled: boolean = false;
  private reminderService: ReminderService = ReminderService.getInstance();

  aboutToAppear(): void {
    this.viewModel.loadDiapers(this.baby.id);
    this.initAddDiaperBtn();
    this.initReminders();
  }

  async initReminders() {
    try {
      const prefs = await AppPreferencesService.getInstance();
      const state = await prefs.getState();
      this.reminderEnabled = state.reminderDefaults.enabled;
    } catch (error) {
      console.error(`[BabyView} ${error.code} ${error.message}`)
    }
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
    Column({ space: 4 }) {
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

      if (diaper.intensity || diaper.condition) {
        Row({ space: 4 }) {
          if (diaper.intensity) {
            Text(diaper.intensity)
              .fontSize('9fp')
              .fontColor(Color.White)
              .padding({
                left: 6,
                right: 6,
                top: 2,
                bottom: 2
              })
              .backgroundColor($r('app.color.background_color'))
              .borderWidth(1)
              .borderColor($r('app.color.background_border_color'))
              .borderRadius($r('sys.float.segment_button_height'))
          }
          if (diaper.condition) {
            Text(diaper.condition)
              .fontSize('9fp')
              .fontColor(Color.White)
              .padding({
                left: 6,
                right: 6,
                top: 2,
                bottom: 2
              })
              .backgroundColor($r('app.color.background_color'))
              .borderWidth(1)
              .borderColor($r('app.color.background_border_color'))
              .borderRadius($r('sys.float.segment_button_height'))
          }
        }
        .width('90%')
      }
    }
    .margin({ bottom: '8vp' })
    .width('90%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Stack() {
      ArcList({ header: this.header }) {
        ArcListItem() {
          Row({ space: 6 }) {
            Text('Insights')
              .fontSize('11fp')
              .fontColor($r('app.color.brand_color'))
              .padding({
                left: 8,
                right: 8,
                top: 5,
                bottom: 5
              })
              .onClick(() => {
                this.pageStack.pushPathByName(INSIGHTS_PAGE, { babyId: this.baby.id }, () => {
                  // refresh after insights
                });
              })

            Text('History')
              .fontSize('11fp')
              .fontColor($r('app.color.brand_color'))
              .padding({
                left: 8,
                right: 8,
                top: 5,
                bottom: 5
              })
              .onClick(() => {
                this.pageStack.pushPathByName(HISTORY_PAGE, { babyId: this.baby.id }, () => {
                  // refresh after history
                });
              })

            Text('Remind')
              .fontSize('11fp')
              .fontColor(this.reminderEnabled ? $r('app.color.brand_border_color') : $r('app.color.brand_color'))
              .padding({
                left: 8,
                right: 8,
                top: 5,
                bottom: 5
              })
              .onClick(() => {
                this.toggleReminder();
              })

            Text('Edit')
              .fontSize('11fp')
              .fontColor($r('app.color.brand_color'))
              .padding({
                left: 8,
                right: 8,
                top: 5,
                bottom: 5
              })
              .onClick(() => {
                this.pageStack.pushPathByName(EDIT_BABY_PAGE, { babyId: this.baby.id }, () => {
                  // refresh after edit
                });
              })
          }
          .width(SizeConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .margin({ bottom: 8 });

        }

        LazyForEach(this.viewModel.datasource, (diaper: Diaper) => {
          ArcListItem() {
            this.diaperViewItem(diaper);
          }
          .onClick(() => {
            if (diaper.id !== undefined) {
              this.pageStack.pushPathByName(DIAPER_DETAIL_PAGE, { diaperId: diaper.id, babyId: this.baby.id }, () => {
                this.viewModel.loadDiapers(this.baby.id);
              });
            }
          })
        }, (diaper: Diaper) => `${diaper.id}`)
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

  private async toggleReminder(): Promise<void> {
    const enabled = !this.reminderEnabled;
    try {
      if (enabled) {
        const hasPermission = await this.reminderService.requestNotificationPermission();
        if (!hasPermission) {
          return;
        }
        await this.reminderService.enableGlobalReminders(4);
      } else {
        await this.reminderService.disableGlobalReminders();
      }
      const prefs = await AppPreferencesService.getInstance();
      await prefs.setReminderDefaults({
        enabled: enabled,
        hour: 8,
        minute: 0
      });
      this.reminderEnabled = enabled;
    } catch (error) {
      console.error(`[BabyView} ${error.code} ${error.message}`)
    }
  }
}