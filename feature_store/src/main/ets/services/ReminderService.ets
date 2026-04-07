import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppPreferencesService } from '../preferences/AppPreferencesService';
import { BabyRepository } from '../repository/BabyRepository';
import GlobalContext from '../lib/GlobalContext';

export interface BabyReminderState {
  babyId: number;
  babyName: string;
  reminderId: number;
  lastScheduledAt: Date;
}

class ReminderService {
  private static instance?: ReminderService;
  private notificationIdCounter: number = 2000;
  private activeReminders: Map<number, number> = new Map(); // babyId -> reminderId

  static getInstance(): ReminderService {
    if (!ReminderService.instance) {
      ReminderService.instance = new ReminderService();
    }
    return ReminderService.instance;
  }

  requestNotificationPermission(): Promise<boolean> {
    return new Promise<boolean>((resolve) => {
      const context = GlobalContext.getInstance().getSavedContext();
      if (!context) {
        resolve(false);
        return;
      }
      notificationManager.requestEnableNotification(context as never, (err: BusinessError<void>) => {
        if (err) {
          console.error(`Failed to request notification: ${err.message} `);
          resolve(false);
        } else {
          resolve(true);
        }
      });
    });
  }

  isNotificationEnabled(): Promise<boolean> {
    return new Promise<boolean>((resolve) => {
      notificationManager.isNotificationEnabled((err: BusinessError<void>, data: boolean) => {
        if (err) {
          resolve(false);
        } else {
          resolve(data);
        }
      });
    });
  }

  async scheduleReminderForAllBabies(): Promise<void> {
    try {
      const context = GlobalContext.getInstance().getSavedContext();
      if (!context) {
        return;
      }

      const prefs = await AppPreferencesService.getInstance(context);
      const state = await prefs.getState();
      if (!state.reminderDefaults.enabled) {
        return;
      }

      const repository = await BabyRepository.getInstance(context);
      const babies = await repository.getBabyList();

      for (let i = 0; i < babies.length; i++) {
        const baby = babies[i];
        if (baby.isArchived) {
          continue;
        }
        const intervalHours = 4; // default overdue threshold
        await this.scheduleReminderForBaby(baby.id!, baby.name, intervalHours);
      }
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to cancel all reminders: ${error.message} `);
    }
  }

  async cancelReminderForBaby(babyId: number): Promise<void> {
    const reminderId = this.activeReminders.get(babyId);
    if (reminderId !== undefined) {
      try {
        await reminderAgentManager.cancelReminder(reminderId);
        this.activeReminders.delete(babyId);
      } catch (err) {
        const error = err as BusinessError;
        console.error(`Failed to cancel all reminders: ${error.message} `);
      }
    }
  }

  async cancelAllReminders(): Promise<void> {
    try {
      const activeIds: number[] = [];
      this.activeReminders.forEach((reminderId: number) => {
        activeIds.push(reminderId);
      });
      for (let i = 0; i < activeIds.length; i++) {
        await reminderAgentManager.cancelReminder(activeIds[i]);
      }
      this.activeReminders.clear();
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to cancel all reminders: ${error.message} `);
    }
  }

  async enableGlobalReminders(intervalHours: number): Promise<void> {
    await this.cancelAllReminders();
    await this.scheduleReminderForAllBabies();
  }

  async disableGlobalReminders(): Promise<void> {
    await this.cancelAllReminders();
  }

  async getActiveReminderCount(): Promise<number> {
    try {
      const reminders = await reminderAgentManager.getValidReminders();
      return reminders.length;
    } catch {
      return 0;
    }
  }

  private async getNextNotificationId(): Promise<number> {
    this.notificationIdCounter++;
    return this.notificationIdCounter;
  }

  private async scheduleReminderForBaby(babyId: number, babyName: string, intervalHours: number): Promise<number> {
    const triggerSeconds = intervalHours * 3600;
    const notificationId = await this.getNextNotificationId();
    const title = 'Diaper Check';
    const content = `It's been ${intervalHours}h since ${babyName}'s last diaper change. Time to check?`;

    const timerReminder: reminderAgentManager.ReminderRequestTimer = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
      triggerTimeInSeconds: triggerSeconds,
      title: title,
      content: content,
      notificationId: notificationId
    };

    const reminderId = await reminderAgentManager.publishReminder(timerReminder);
    this.activeReminders.set(babyId, reminderId);
    return reminderId;
  }
}

export default ReminderService;
