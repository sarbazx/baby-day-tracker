import { DIAPER_DETAIL_PAGE } from '../../../../Index';
import { EmptyState } from '../components/EmptyState';
import { SizeConstants } from '../lib/SizeConstants';
import { Diaper, DiaperType } from '../models/Diaper';
import HistoryViewModel, { GroupedDiapers, HistoryPeriod, HistoryTypeFilter } from '../viewmodels/HistoryViewModel';
import { ArcList, ArcListItem } from '@ohos.arkui.ArcList';
import { Baby } from '../models/Baby';

@Component
export struct HistoryView {
  @Consume('pageStack') navStack: NavPathStack;
  @Prop @Require baby: Baby;
  @State viewModel: HistoryViewModel = new HistoryViewModel();

  aboutToAppear(): void {
    this.viewModel.loadHistory(this.baby.id);
  }

  @Builder
  filterRow() {
    Column({ space: 4 }) {
      Row({ space: 4 }) {
        this.periodChip('Today', 'today')
        this.periodChip('7D', '7days')
        this.periodChip('30D', '30days')
        this.periodChip('All', 'all')
      }

      Row({ space: 4 }) {
        this.typeChip('All', 'all')
        this.typeChip('Pee', 'pee')
        this.typeChip('Poop', 'poo')
      }
    }
    .width(SizeConstants.FULL_PERCENT)
    .padding({
      left: 8,
      right: 8,
      top: 24,
      bottom: 14
    })
    .backgroundColor($r('app.color.background_color'))
    .borderRadius(6)
    .margin({ bottom: 6 })
  }

  @Builder
  periodChip(label: string, period: HistoryPeriod) {
    Text(label)
      .fontSize('9fp')
      .fontColor(this.viewModel.selectedPeriod === period ? Color.White : $r('app.color.brand_color'))
      .backgroundColor(this.viewModel.selectedPeriod === period ? $r('app.color.brand_color') : 'transparent')
      .borderColor($r('app.color.brand_color'))
      .borderWidth(1)
      .borderRadius($r('sys.float.segment_button_height'))
      .padding({
        left: 5,
        right: 5,
        top: 2,
        bottom: 2
      })
      .onClick(() => {
        this.viewModel.setPeriod(period, this.baby.id);
      })
  }

  @Builder
  typeChip(label: string, type: HistoryTypeFilter) {
    Text(label)
      .fontSize('9fp')
      .fontColor(this.viewModel.selectedType === type ? Color.White : $r('app.color.on_brand_color'))
      .backgroundColor(this.viewModel.selectedType === type ? $r('app.color.on_brand_color') : 'transparent')
      .borderColor($r('app.color.on_brand_color'))
      .borderWidth(1)
      .borderRadius($r('sys.float.segment_button_height'))
      .padding({
        left: 5,
        right: 5,
        top: 2,
        bottom: 2
      })
      .onClick(() => {
        this.viewModel.setType(type, this.baby.id);
      })
  }

  @Builder
  groupSection(label: string) {
    Text(label)
      .fontSize('10fp')
      .fontColor($r('app.color.brand_color'))
      .fontWeight(FontWeight.Bold)
      .padding({ left: 4, bottom: 3 })
      .width(SizeConstants.FULL_PERCENT)
  }

  @Builder
  diaperItem(diaper: Diaper) {
    Row({ space: 4 }) {
      Row() {
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
        top: '4vp',
        right: '6vp',
        bottom: '4vp',
        left: '6vp'
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
        top: '4vp',
        right: '6vp',
        bottom: '4vp',
        left: '6vp'
      })

      if (diaper.intensity || diaper.condition) {
        Row({ space: 2 }) {
          if (diaper.intensity) {
            Text(diaper.intensity)
              .fontSize('8fp')
              .fontColor(Color.White)
              .padding({
                left: 4,
                right: 4,
                top: 1,
                bottom: 1
              })
              .backgroundColor($r('app.color.background_color'))
              .borderWidth(1)
              .borderColor($r('app.color.background_border_color'))
              .borderRadius($r('sys.float.segment_button_height'))
          }
          if (diaper.condition) {
            Text(diaper.condition)
              .fontSize('8fp')
              .fontColor(Color.White)
              .padding({
                left: 4,
                right: 4,
                top: 1,
                bottom: 1
              })
              .backgroundColor($r('app.color.background_color'))
              .borderWidth(1)
              .borderColor($r('app.color.background_border_color'))
              .borderRadius($r('sys.float.segment_button_height'))
          }
        }
      }
    }
    .width('92%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: '3vp' })
  }

  build() {
    Column({ space: 6 }) {
      this.filterRow()

      if (this.viewModel.isEmpty && !this.viewModel.isLoading) {
        Column() {
          EmptyState({
            message: 'No logs for this filter',
            actionLabel: 'Clear',
            onAction: () => {
              this.viewModel.selectedPeriod = 'all';
              this.viewModel.selectedType = 'all';
              this.viewModel.loadHistory(this.baby.id);
            }
          })
        }
        .layoutWeight(1)
        .width(SizeConstants.FULL_PERCENT)
      } else {
        Scroll() {
          Column({ space: 4 }) {
            ForEach(this.viewModel.groupedDiapers, (group: GroupedDiapers) => {
              Column({ space: 2 }) {
                this.groupSection(group.label)
                ForEach(group.data, (diaper: Diaper) => {
                  this.diaperItem(diaper)
                }, (diaper: Diaper) => `${diaper.id}${diaper.type}`)
              }
              .width(SizeConstants.FULL_PERCENT)
              .padding({
                top: '4vp',
                left: '6vp',
                right: '6vp',
                bottom: '4vp'
              })
            }, (group: GroupedDiapers) => group.todayStr)
          }
          .width(SizeConstants.FULL_PERCENT)
          .padding({ bottom: '6vp' })
        }
        .layoutWeight(1)
        .width(SizeConstants.FULL_PERCENT)
        .scrollBar(BarState.Off)
      }
    }
    .width(SizeConstants.FULL_PERCENT)
    .height(SizeConstants.FULL_PERCENT)
    .padding({ left: 6, right: 6, top: 4 })
  }
}
