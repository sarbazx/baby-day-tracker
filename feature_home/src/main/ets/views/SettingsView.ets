import { SizeConstants } from '../lib/SizeConstants';
import { BackupService, GlobalContext, HomeSortMode, InsightPeriod, ReminderService } from 'feature_store';
import { SettingsViewModel } from '../viewmodels/SettingsViewModel';

@Component
export struct SettingsView {
  @Consume('pageStack') pageStack: NavPathStack;
  private viewModel: SettingsViewModel = new SettingsViewModel();
  private reminderService: ReminderService = ReminderService.getInstance();
  private backupService: BackupService = BackupService.getInstance();
  @State private archiveVisible: boolean = false;
  @State private insightPeriod: InsightPeriod = InsightPeriod.THIRTY_DAYS;
  @State private reminderEnabled: boolean = false;
  @State private homeSortMode: HomeSortMode = HomeSortMode.RECENT_FIRST;
  @State private backupStatus: string = '';

  async aboutToAppear(): Promise<void> {
    const ctx = GlobalContext.getInstance().getSavedContext();
    if (ctx) {
      await this.viewModel.init(ctx);
      // Sync viewmodel state into @State vars for reactive binding
      setTimeout(() => {
        this.archiveVisible = this.viewModel.archiveVisible;
        this.insightPeriod = this.viewModel.insightPeriod;
        this.reminderEnabled = this.viewModel.reminderEnabled;
        this.homeSortMode = this.viewModel.homeSortMode;
      }, 50);
    }
  }

  @Builder
  periodChip(label: string, period: InsightPeriod) {
    Text(label)
      .fontSize('10fp')
      .fontColor(this.insightPeriod === period ? $r('app.color.on_primary_color') : $r('app.color.on_primary_color'))
      .opacity(this.insightPeriod === period ? 1.0 : 0.5)
      .padding({
        left: 8,
        right: 8,
        top: 4,
        bottom: 4
      })
      .borderRadius(12)
      .backgroundColor(this.insightPeriod === period ? $r('app.color.brand_color') : 'rgba(255,255,255,0.1)')
      .onClick(async () => {
        await this.viewModel.setInsightPeriod(period);
        this.insightPeriod = period;
      })
  }

  @Builder
  sortChip(label: string, mode: HomeSortMode) {
    Text(label)
      .fontSize('10fp')
      .fontColor(this.homeSortMode === mode ? $r('app.color.on_primary_color') : $r('app.color.on_primary_color'))
      .opacity(this.homeSortMode === mode ? 1.0 : 0.5)
      .padding({
        left: 8,
        right: 8,
        top: 4,
        bottom: 4
      })
      .borderRadius(12)
      .backgroundColor(this.homeSortMode === mode ? $r('app.color.brand_color') : 'rgba(255,255,255,0.1)')
      .onClick(async () => {
        await this.viewModel.setHomeSortMode(mode);
        this.homeSortMode = mode;
      })
  }

  @Builder
  sectionHeader(titleKey: string) {
    Text(titleKey)
      .fontSize('10fp')
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.brand_color'))
      .width(SizeConstants.FULL_PERCENT)
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 6
      })
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          this.sectionHeader('Display')
          Row() {
            Text('Show archived')
              .fontSize('12fp')
              .fontColor($r('app.color.on_primary_color'))
              .flexGrow(1)
            Toggle({ type: ToggleType.Switch, isOn: this.archiveVisible })
              .selectedColor($r('app.color.brand_color'))
              .onChange(async (isOn: boolean) => {
                await this.viewModel.setArchiveVisible(isOn);
                this.archiveVisible = isOn;
              })
          }
          .width(SizeConstants.FULL_PERCENT)
          .padding({
            left: 16,
            right: 16,
            top: 10,
            bottom: 10
          })
          .justifyContent(FlexAlign.SpaceBetween)

          Text('Sort order')
            .fontSize('12fp')
            .fontColor($r('app.color.on_primary_color'))
            .width(SizeConstants.FULL_PERCENT)
            .padding({
              left: 16,
              right: 16,
              top: 10,
              bottom: 4
            })

          Row({ space: 6 }) {
            this.sortChip('Recent', HomeSortMode.RECENT_FIRST)
            this.sortChip('Overdue', HomeSortMode.OVERDUE_FIRST)
            this.sortChip('A-Z', HomeSortMode.NAME_ASC)
          }
          .width(SizeConstants.FULL_PERCENT)
          .padding({ left: 16, right: 16, bottom: 10 })
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)

          this.sectionHeader('History')
          Text('Default period')
            .fontSize('12fp')
            .fontColor($r('app.color.on_primary_color'))
            .width(SizeConstants.FULL_PERCENT)
            .padding({
              left: 16,
              right: 16,
              top: 10,
              bottom: 4
            })

          Row({ space: 6 }) {
            this.periodChip('7D', InsightPeriod.SEVEN_DAYS)
            this.periodChip('30D', InsightPeriod.THIRTY_DAYS)
            this.periodChip('90D', InsightPeriod.NINETY_DAYS)
          }
          .width(SizeConstants.FULL_PERCENT)
          .padding({ left: 16, right: 16, bottom: 10 })
          .justifyContent(FlexAlign.Center)

          this.sectionHeader('Reminders')
          Row() {
            Text('Enable reminders')
              .fontSize('12fp')
              .fontColor($r('app.color.on_primary_color'))
              .flexGrow(1)
            Toggle({ type: ToggleType.Switch, isOn: this.reminderEnabled })
              .selectedColor($r('app.color.brand_color'))
              .onChange(async (isOn: boolean) => {
                await this.viewModel.setReminderDefaults(isOn);
                this.reminderEnabled = isOn;
                if (isOn) {
                  await this.reminderService.requestNotificationPermission();
                  await this.reminderService.enableGlobalReminders(4);
                } else {
                  await this.reminderService.disableGlobalReminders();
                }
              })
          }
          .width(SizeConstants.FULL_PERCENT)
          .padding({
            left: 16,
            right: 16,
            top: 10,
            bottom: 10
          })
          .justifyContent(FlexAlign.SpaceBetween)

          this.sectionHeader('Data')
          Row() {
            Text('Export backup')
              .fontSize('12fp')
              .fontColor($r('app.color.on_primary_color'))
              .flexGrow(1)
            Text('→')
              .fontSize('12fp')
              .fontColor($r('app.color.brand_color'))
          }
          .width(SizeConstants.FULL_PERCENT)
          .padding({
            left: 16,
            right: 16,
            top: 10,
            bottom: 10
          })
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(async () => {
            try {
              await this.backupService.buildBackupJson();
              this.backupStatus = 'Backup ready';
              setTimeout(() => {
                this.backupStatus = '';
              }, 3000);
            } catch {
              this.backupStatus = 'Backup failed';
              setTimeout(() => {
                this.backupStatus = '';
              }, 3000);
            }
          })

          if (this.backupStatus !== '') {
            Text(this.backupStatus)
              .fontSize('10fp')
              .fontColor($r('app.color.brand_color'))
              .padding({ left: 16, right: 16, bottom: 8 })
          }

          this.sectionHeader('About')
          Text('Reset onboarding')
            .fontSize('12fp')
            .fontColor($r('app.color.brand_color'))
            .padding({
              left: 16,
              right: 16,
              top: 10,
              bottom: 10
            })
            .onClick(() => {
              this.handleResetOnboarding();
            })

          Text('Baby Day Tracker v1.0')
            .fontSize('10fp')
            .fontColor($r('app.color.on_primary_color'))
            .opacity(0.5)
            .padding({ top: 16, bottom: 24 })
            .textAlign(TextAlign.Center)
            .width(SizeConstants.FULL_PERCENT)

        }
        .width(SizeConstants.FULL_PERCENT)
      }
      .width(SizeConstants.FULL_PERCENT)
      .height(SizeConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
    }
    .width(SizeConstants.FULL_PERCENT)
    .height(SizeConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.background_color'))
  }

  private async handleResetOnboarding(): Promise<void> {
    await this.viewModel.resetOnboarding();
    this.pageStack.clear();
    this.pageStack.pushPathByName('SplashPage', null);
  }
}
