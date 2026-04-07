import { Context } from '@kit.AbilityKit';
import preferences from '@ohos.data.preferences';
import GlobalContext from '../lib/GlobalContext';

export enum HomeSortMode {
  RECENT_FIRST = 'recent_first',
  OLDEST_FIRST = 'oldest_first',
  NAME_ASC = 'name_asc',
  OVERDUE_FIRST = 'overdue_first'
}

export enum InsightPeriod {
  SEVEN_DAYS = '7d',
  THIRTY_DAYS = '30d',
  NINETY_DAYS = '90d'
}

export interface ReminderDefaults {
  enabled: boolean;
  hour: number;
  minute: number;
}

export interface AppPreferencesState {
  onboardingCompleted: boolean;
  homeSortMode: HomeSortMode;
  archiveVisible: boolean;
  reminderDefaults: ReminderDefaults;
  insightPeriod: InsightPeriod;
  lastSelectedBabyId: number | null;
}

const DEFAULT_REMINDER_DEFAULTS: ReminderDefaults = {
  enabled: false,
  hour: 8,
  minute: 0
};

const DEFAULT_STATE: AppPreferencesState = {
  onboardingCompleted: false,
  homeSortMode: HomeSortMode.RECENT_FIRST,
  archiveVisible: false,
  reminderDefaults: DEFAULT_REMINDER_DEFAULTS,
  insightPeriod: InsightPeriod.THIRTY_DAYS,
  lastSelectedBabyId: null
};

const STORAGE_NAME = 'BabyDayTracker.preferences';
const LAST_SELECTED_BABY_ID_SENTINEL = -1;

class PreferenceStoreWrapper {
  private storeObj?: preferences.Preferences;

  async getPreferences(ctx: Context): Promise<preferences.Preferences> {
    if (this.storeObj) {
      return this.storeObj;
    }
    this.storeObj = await preferences.getPreferences(ctx, STORAGE_NAME);
    return this.storeObj;
  }

  getBoolean(store: preferences.Preferences, key: string, fallback: boolean): Promise<boolean> {
    return store.get(key, fallback) as Promise<boolean>;
  }

  getNumber(store: preferences.Preferences, key: string, fallback: number): Promise<number> {
    return store.get(key, fallback) as Promise<number>;
  }

  getString(store: preferences.Preferences, key: string, fallback: string): Promise<string> {
    return store.get(key, fallback) as Promise<string>;
  }

  putBoolean(store: preferences.Preferences, key: string, value: boolean): Promise<void> {
    return store.put(key, value);
  }

  putNumber(store: preferences.Preferences, key: string, value: number): Promise<void> {
    return store.put(key, value);
  }

  putString(store: preferences.Preferences, key: string, value: string): Promise<void> {
    return store.put(key, value);
  }

  flush(store: preferences.Preferences): Promise<void> {
    return store.flush();
  }
}

const STORE_WRAPPER = new PreferenceStoreWrapper();

export class AppPreferencesService {
  private static instance?: AppPreferencesService;
  private readonly context: Context;
  private initPromise?: Promise<void>;

  private constructor(context: Context) {
    this.context = context;
  }

  static async getInstance(context?: Context): Promise<AppPreferencesService> {
    if (!AppPreferencesService.instance) {
      const resolvedContext = context ?? GlobalContext.getInstance().getSavedContext();
      if (!resolvedContext) {
        throw new Error('AppPreferencesService requires a Context before initialization');
      }
      AppPreferencesService.instance = new AppPreferencesService(resolvedContext);
    }

    await AppPreferencesService.instance.ensureInitialized();
    return AppPreferencesService.instance;
  }

  async getState(): Promise<AppPreferencesState> {
    return this.readState();
  }

  async updateState(
    onboardingCompleted?: boolean,
    homeSortMode?: HomeSortMode,
    archiveVisible?: boolean,
    reminderDefaults?: ReminderDefaults,
    insightPeriod?: InsightPeriod,
    lastSelectedBabyId?: number | null
  ): Promise<AppPreferencesState> {
    const current = await this.readState();
    const nextState: AppPreferencesState = {
      onboardingCompleted: onboardingCompleted !== undefined ? onboardingCompleted : current.onboardingCompleted,
      homeSortMode: homeSortMode !== undefined ? homeSortMode : current.homeSortMode,
      archiveVisible: archiveVisible !== undefined ? archiveVisible : current.archiveVisible,
      reminderDefaults: reminderDefaults !== undefined ? reminderDefaults : current.reminderDefaults,
      insightPeriod: insightPeriod !== undefined ? insightPeriod : current.insightPeriod,
      lastSelectedBabyId: lastSelectedBabyId !== undefined ? lastSelectedBabyId : current.lastSelectedBabyId
    };
    await this.writeState(nextState);
    return nextState;
  }

  async setOnboardingCompleted(value: boolean): Promise<AppPreferencesState> {
    return this.updateState(value, undefined, undefined, undefined, undefined, undefined);
  }

  async setHomeSortMode(value: HomeSortMode): Promise<AppPreferencesState> {
    return this.updateState(undefined, value, undefined, undefined, undefined, undefined);
  }

  async setArchiveVisible(value: boolean): Promise<AppPreferencesState> {
    return this.updateState(undefined, undefined, value, undefined, undefined, undefined);
  }

  async setReminderDefaults(value: ReminderDefaults): Promise<AppPreferencesState> {
    return this.updateState(undefined, undefined, undefined, value, undefined, undefined);
  }

  async setInsightPeriod(value: InsightPeriod): Promise<AppPreferencesState> {
    return this.updateState(undefined, undefined, undefined, undefined, value, undefined);
  }

  async setLastSelectedBabyId(value: number | null): Promise<AppPreferencesState> {
    return this.updateState(undefined, undefined, undefined, undefined, undefined, value);
  }

  private async ensureInitialized(): Promise<void> {
    if (!this.initPromise) {
      this.initPromise = this.initialize().catch((err: Error) => {
        this.initPromise = undefined;
        throw new Error(err.message);
      });
    }

    return this.initPromise;
  }

  private async initialize(): Promise<void> {
    await STORE_WRAPPER.getPreferences(this.context);
  }

  private async readState(): Promise<AppPreferencesState> {
    const store = await STORE_WRAPPER.getPreferences(this.context);
    const persistedLastSelectedBabyId =
      await STORE_WRAPPER.getNumber(store, 'lastSelectedBabyId', LAST_SELECTED_BABY_ID_SENTINEL);
    const onboardingCompleted =
      await STORE_WRAPPER.getBoolean(store, 'onboardingCompleted', DEFAULT_STATE.onboardingCompleted);
    const homeSortModeRaw = await STORE_WRAPPER.getString(store, 'homeSortMode', DEFAULT_STATE.homeSortMode);
    const archiveVisible = await STORE_WRAPPER.getBoolean(store, 'archiveVisible', DEFAULT_STATE.archiveVisible);
    const reminderDefaultsRaw = await STORE_WRAPPER.getString(store, 'reminderDefaults', '');
    const insightPeriodRaw = await STORE_WRAPPER.getString(store, 'insightPeriod', DEFAULT_STATE.insightPeriod);

    const reminderDefaults = this.normalizeReminderDefaults(reminderDefaultsRaw);

    return {
      onboardingCompleted,
      homeSortMode: this.normalizeHomeSortMode(homeSortModeRaw),
      archiveVisible,
      reminderDefaults,
      insightPeriod: this.normalizeInsightPeriod(insightPeriodRaw),
      lastSelectedBabyId: persistedLastSelectedBabyId >= 0 ? persistedLastSelectedBabyId : null
    };
  }

  private async writeState(state: AppPreferencesState): Promise<void> {
    const store = await STORE_WRAPPER.getPreferences(this.context);
    await STORE_WRAPPER.putBoolean(store, 'onboardingCompleted', state.onboardingCompleted);
    await STORE_WRAPPER.putString(store, 'homeSortMode', state.homeSortMode);
    await STORE_WRAPPER.putBoolean(store, 'archiveVisible', state.archiveVisible);
    await STORE_WRAPPER.putString(store, 'reminderDefaults', JSON.stringify(state.reminderDefaults));
    await STORE_WRAPPER.putString(store, 'insightPeriod', state.insightPeriod);
    await STORE_WRAPPER.putNumber(store, 'lastSelectedBabyId',
      state.lastSelectedBabyId ?? LAST_SELECTED_BABY_ID_SENTINEL);
    await STORE_WRAPPER.flush(store);
  }

  private normalizeHomeSortMode(value: string): HomeSortMode {
    if (value === HomeSortMode.RECENT_FIRST || value === HomeSortMode.OLDEST_FIRST || value === HomeSortMode.NAME_ASC ||
      value === HomeSortMode.OVERDUE_FIRST) {
      return value as HomeSortMode;
    }
    return DEFAULT_STATE.homeSortMode;
  }

  private normalizeInsightPeriod(value: string): InsightPeriod {
    if (value === InsightPeriod.SEVEN_DAYS || value === InsightPeriod.THIRTY_DAYS ||
      value === InsightPeriod.NINETY_DAYS) {
      return value as InsightPeriod;
    }
    return DEFAULT_STATE.insightPeriod;
  }

  private normalizeReminderDefaults(rawValue: string): ReminderDefaults {
    if (!rawValue) {
      return DEFAULT_REMINDER_DEFAULTS;
    }
    try {
      const parsed: ReminderDefaults = JSON.parse(rawValue) as ReminderDefaults;
      return {
        enabled: typeof parsed.enabled === 'boolean' ? parsed.enabled : DEFAULT_REMINDER_DEFAULTS.enabled,
        hour: typeof parsed.hour === 'number' ? parsed.hour : DEFAULT_REMINDER_DEFAULTS.hour,
        minute: typeof parsed.minute === 'number' ? parsed.minute : DEFAULT_REMINDER_DEFAULTS.minute
      };
    } catch {
      return DEFAULT_REMINDER_DEFAULTS;
    }
  }
}
