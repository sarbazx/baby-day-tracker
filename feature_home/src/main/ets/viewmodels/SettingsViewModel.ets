import { Context } from '@kit.AbilityKit';
import { AppPreferencesService, HomeSortMode, InsightPeriod, ReminderDefaults } from 'feature_store';

export class SettingsViewModel {
  @Track
  archiveVisible: boolean = false;
  @Track
  insightPeriod: InsightPeriod = InsightPeriod.THIRTY_DAYS;
  @Track
  reminderEnabled: boolean = false;
  @Track
  reminderHour: number = 8;
  @Track
  reminderMinute: number = 0;
  @Track
  homeSortMode: HomeSortMode = HomeSortMode.RECENT_FIRST;
  private preferencesService?: AppPreferencesService;

  async init(context: Context): Promise<void> {
    this.preferencesService = await AppPreferencesService.getInstance(context);
    await this.loadState();
  }

  async setArchiveVisible(value: boolean): Promise<void> {
    if (!this.preferencesService) {
      return;
    }
    this.archiveVisible = value;
    await this.preferencesService.setArchiveVisible(value);
  }

  async setInsightPeriod(value: InsightPeriod): Promise<void> {
    if (!this.preferencesService) {
      return;
    }
    this.insightPeriod = value;
    await this.preferencesService.setInsightPeriod(value);
  }

  async setHomeSortMode(value: HomeSortMode): Promise<void> {
    if (!this.preferencesService) {
      return;
    }
    this.homeSortMode = value;
    await this.preferencesService.setHomeSortMode(value);
  }

  async setReminderDefaults(enabled: boolean): Promise<void> {
    if (!this.preferencesService) {
      return;
    }
    this.reminderEnabled = enabled;
    const reminderDefaults: ReminderDefaults = {
      enabled: enabled,
      hour: this.reminderHour,
      minute: this.reminderMinute
    };
    await this.preferencesService.setReminderDefaults(reminderDefaults);
  }

  async resetOnboarding(): Promise<void> {
    if (!this.preferencesService) {
      return;
    }
    await this.preferencesService.setOnboardingCompleted(false);
  }

  private async loadState(): Promise<void> {
    if (!this.preferencesService) {
      return;
    }
    const state = await this.preferencesService.getState();
    this.archiveVisible = state.archiveVisible;
    this.insightPeriod = state.insightPeriod;
    this.reminderEnabled = state.reminderDefaults.enabled;
    this.reminderHour = state.reminderDefaults.hour;
    this.reminderMinute = state.reminderDefaults.minute;
    this.homeSortMode = state.homeSortMode;
  }
}
