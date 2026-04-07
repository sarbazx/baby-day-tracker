
export interface ConfirmOptions {
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  isDangerous?: boolean;
}

export interface ConfirmResult {
  confirmed: boolean;
}

const DEFAULT_CONFIRM = 'Confirm';
const DEFAULT_CANCEL = 'Cancel';

interface DialogButton {
  text: string;
  color: ResourceStr;
}

export async function showConfirm(context: UIContext, options: ConfirmOptions): Promise<boolean> {
  try {
    const cancelBtn: DialogButton = {
      text: options.cancelText ?? DEFAULT_CANCEL,
      color: $r('app.color.on_primary_color') as ResourceStr
    };
    const confirmBtn: DialogButton = {
      text: options.confirmText ?? DEFAULT_CONFIRM,
      color: options.isDangerous
        ? ($r('app.color.brand_border_color') as ResourceStr)
        : ($r('app.color.brand_color') as ResourceStr)
    };
    const buttons: DialogButton[] = [cancelBtn, confirmBtn];
    const result = await context.getPromptAction().showDialog({
      title: options.title,
      message: options.message,
      buttons: buttons
    });
    if (result !== undefined && result !== null) {
      return result.index === 1;
    }
    return false;
  } catch {
    return false;
  }
}

export async function showDeleteConfirm(context: UIContext, targetName: string): Promise<boolean> {
  return showConfirm(context, {
    title: 'Delete',
    message: `Delete ${targetName}?`,
    confirmText: 'Delete',
    isDangerous: true
  });
}
