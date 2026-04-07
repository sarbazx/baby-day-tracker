import { AppPreferencesService, GlobalContext, HomeSortMode } from 'feature_store';
import { SizeConstants } from '../lib/SizeConstants';

@Component
export struct HomeHeader {
  @Consume('pageStack') pageStack: NavPathStack;
  @Prop sortMode: HomeSortMode = HomeSortMode.RECENT_FIRST;
  @Prop loadedCount: number = 0;
  @Prop totalToday: number = 0;
  @Prop overdueCount: number = 0;
  onSortChange?: (mode: HomeSortMode) => void;

  @Builder
  sortChip(label: string, mode: HomeSortMode) {
    Text(label)
      .fontSize('9fp')
      .fontColor(this.sortMode === mode ? Color.White : $r('app.color.brand_color'))
      .backgroundColor(this.sortMode === mode ? $r('app.color.brand_color') : 'transparent')
      .borderColor($r('app.color.brand_color'))
      .borderWidth(1)
      .borderRadius($r('sys.float.segment_button_height'))
      .padding({
        left: 6,
        right: 6,
        top: 2,
        bottom: 2
      })
      .onClick(async () => {
        const ctx = GlobalContext.getInstance().getSavedContext();
        if (ctx) {
          await AppPreferencesService.getInstance(ctx).then((s) => s.setHomeSortMode(mode));
        }
        if (this.onSortChange) {
          this.onSortChange(mode);
        }
      })
  }

  build() {
    Column({ space: 6 }) {
      Text('Babies')
        .fontSize('18fp')
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Row({ space: 8 }) {
        Column({ space: 1 }) {
          Text(`${this.totalToday}`)
            .fontSize('14fp')
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.brand_color'))
          Text('Today')
            .fontSize('8fp')
            .fontColor($r('app.color.on_primary_color'))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 1 }) {
          Text(`${this.overdueCount}`)
            .fontSize('14fp')
            .fontWeight(FontWeight.Bold)
            .fontColor(this.overdueCount > 0 ? '#F44336' : Color.White)
          Text('Overdue')
            .fontSize('8fp')
            .fontColor($r('app.color.on_primary_color'))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 1 }) {
          Text(`${this.loadedCount}`)
            .fontSize('14fp')
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text('Babies')
            .fontSize('8fp')
            .fontColor($r('app.color.on_primary_color'))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width(SizeConstants.FULL_PERCENT)
      .padding('6vp')
      .backgroundColor($r('app.color.background_color'))
      .borderRadius(6)

      Row({ space: 4 }) {
        Blank()
        this.sortChip('Recent', HomeSortMode.RECENT_FIRST)
        this.sortChip('Overdue', HomeSortMode.OVERDUE_FIRST)
        this.sortChip('A-Z', HomeSortMode.NAME_ASC)
        Blank()
        Text('⚙')
          .fontSize('14fp')
          .fontColor($r('app.color.on_primary_color'))
          .opacity(0.6)
          .onClick(() => {
            this.pageStack.pushPathByName('SettingsPage', null);
          })
        Blank()
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .width(SizeConstants.FULL_PERCENT)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width(SizeConstants.FULL_PERCENT)
    .padding('6vp')
  }
}