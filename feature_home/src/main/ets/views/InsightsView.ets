import { Baby } from '../models/Baby';
import { DailyCount, InsightsSummary } from '../models/InsightsSummary';
import { EmptyState } from '../components/EmptyState';
import { LoadingState } from '../components/LoadingState';
import { SizeConstants } from '../lib/SizeConstants';
import InsightsService from '../services/InsightsService';

@Component
export struct InsightsView {
  @Consume('pageStack') pageStack: NavPathStack;
  @Prop @Require baby: Baby;
  @State summary: InsightsSummary | null = null;
  @State isLoading: boolean = true;
  @State isEmpty: boolean = false;

  aboutToAppear(): void {
    this.loadInsights();
  }

  @Builder
  statCard(label: string, value: string, accent?: boolean) {
    Column({ space: 2 }) {
      Text(value)
        .fontSize('16fp')
        .fontWeight(FontWeight.Bold)
        .fontColor(accent ? $r('app.color.brand_color') : Color.White)
      Text(label)
        .fontSize('9fp')
        .fontColor($r('app.color.on_primary_color'))
    }
    .width('45%')
    .padding('6vp')
    .backgroundColor($r('app.color.background_color'))
    .borderRadius(6)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  trendRow() {
    Column({ space: 4 }) {
      Text('3-Day Trend')
        .fontSize('10fp')
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.brand_color'))
        .width(SizeConstants.FULL_PERCENT)

      Row({ space: 3 }) {
        ForEach(this.summary?.dailyCounts ?? [], (item: DailyCount) => {
          Column({ space: 1 }) {
            // Bar
            Column()
              .width(SizeConstants.FULL_PERCENT)
              .height(`${Math.max(item.count * 6, 3)}px`)
              .backgroundColor($r('app.color.brand_color'))
              .borderRadius(2)
            // Day label
            Text(item.date.substring(5))
              .fontSize('7fp')
              .fontColor($r('app.color.on_primary_color'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }, (item: DailyCount) => item.date)
      }
      .width(SizeConstants.FULL_PERCENT)
      .alignItems(VerticalAlign.Bottom)
    }
    .width(SizeConstants.FULL_PERCENT)
    .padding({
      top: 6,
      right: 24,
      bottom: 6,
      left: 24
    })
    .margin({ bottom: 48 })
    .backgroundColor($r('app.color.background_color'))
    .borderRadius(6)
  }

  build() {
    Column({ space: 6 }) {
      if (this.isLoading) {
        LoadingState()
          .layoutWeight(1)
      } else if (this.isEmpty || !this.summary) {
        Column() {
          EmptyState({ message: 'No insights yet' })
        }
        .layoutWeight(1)
        .width(SizeConstants.FULL_PERCENT)
      } else {
        Scroll() {
          Column({ space: 6 }) {
            // Today's count highlight
            Row({ space: 6 }) {
              Column() {
                Text(`${this.summary.todayCount}`)
                  .fontSize('24fp')
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.brand_color'))
                Text('Today')
                  .fontSize('10fp')
                  .fontColor($r('app.color.on_primary_color'))
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)

              Column({ space: 2 }) {
                Text(`${this.summary.weekCount}`)
                  .fontSize('24fp')
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                Text('This Week')
                  .fontSize('10fp')
                  .fontColor($r('app.color.on_primary_color'))
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)
            }
            .width(SizeConstants.FULL_PERCENT)
            .padding('8vp')
            .backgroundColor($r('app.color.background_color'))
            .borderRadius(8)

            // Stats grid
            Row({ space: 6 }) {
              this.statCard('Avg Interval',
                this.summary.averageIntervalMinutes !== null ? `${this.summary.averageIntervalMinutes}m` : '—')
              this.statCard('Daily Avg',
                this.summary.averageDailyCount !== null ? `${this.summary.averageDailyCount}` : '—')
            }
            .justifyContent(FlexAlign.Center)
            .width(SizeConstants.FULL_PERCENT)

            Row({ space: 6 }) {
              this.statCard('Pee', `${this.summary.peeCount}`, this.summary.dominantType === 'pee')
              this.statCard('Poop', `${this.summary.pooCount}`, this.summary.dominantType === 'poo')
            }
            .justifyContent(FlexAlign.Center)
            .width(SizeConstants.FULL_PERCENT)

            // Week-over-week
            Row({ space: 6 }) {
              Column({ space: 2 }) {
                if (this.summary.weekOverWeekChange !== null) {
                  Text(`${this.summary.weekOverWeekChange >= 0 ? '+' : ''}${this.summary.weekOverWeekChange}%`)
                    .fontSize('14fp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.summary.weekOverWeekChange >= 0 ? '#4CAF50' : '#F44336')
                } else {
                  Text('No data')
                    .fontSize('14fp')
                    .fontColor($r('app.color.on_primary_color'))
                }
                Text('vs Last Week')
                  .fontSize('9fp')
                  .fontColor($r('app.color.on_primary_color'))
              }
              .width(SizeConstants.FULL_PERCENT)
              .padding('6vp')
              .backgroundColor($r('app.color.background_color'))
              .borderRadius(6)
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
            }
            .width(SizeConstants.FULL_PERCENT)

            // Trend chart
            this.trendRow()
          }
          .width(SizeConstants.FULL_PERCENT)
          .padding({ left: 6, right: 6, bottom: 6 })
        }
        .layoutWeight(1)
        .width(SizeConstants.FULL_PERCENT)
        .scrollBar(BarState.Off)
      }
    }
    .width(SizeConstants.FULL_PERCENT)
    .height(SizeConstants.FULL_PERCENT)
    .padding({ top: 4 })
  }

  private async loadInsights(): Promise<void> {
    this.isLoading = true;
    this.isEmpty = false;
    try {
      const s = await InsightsService.getInstance().computeSummary(this.baby.id);
      this.summary = s;
      this.isEmpty = s.totalLogs === 0;
    } catch (_) {
      this.isEmpty = true;
    } finally {
      this.isLoading = false;
    }
  }
}
