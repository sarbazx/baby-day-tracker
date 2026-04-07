import { hilog } from '@kit.PerformanceAnalysisKit';
import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';
import { BackupService, GlobalContext } from 'feature_store';

const DOMAIN = 0x0000;

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup() {
    hilog.info(DOMAIN, 'testTag', 'onBackup started');
    try {
      const ctx = GlobalContext.getInstance().getSavedContext();
      if (ctx) {
        const backupService = BackupService.getInstance();
        const json = await backupService.buildBackupJson();
        hilog.info(DOMAIN, 'testTag', 'onBackup: JSON generated, size=%{public}d', json.length);
      } else {
        hilog.warn(DOMAIN, 'testTag', 'onBackup: no context available');
      }
    } catch (err) {
      const error = err as Error;
      hilog.error(DOMAIN, 'testTag', 'onBackup failed: %{public}s', error.message);
    }
    await Promise.resolve();
  }

  async onRestore(bundleVersion: BundleVersion) {
    hilog.info(DOMAIN, 'testTag', 'onRestore started %{public}s', JSON.stringify(bundleVersion));
    await Promise.resolve();
  }
}