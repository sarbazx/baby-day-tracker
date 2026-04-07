import { SizeConstants } from '../lib/SizeConstants';
import { ArcButton, ArcButtonOptions, ArcButtonStyleMode, ColorMetrics, LengthMetrics, LengthUnit } from '@kit.ArkUI';
import { DiaperType } from '../models/Diaper';
import DiaperViewModel from '../viewmodels/DiaperViewModel';
import { ADD_BABY_LOG_PAGE } from '../../../../Index';

@Component
export struct AddBabyLogPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State diaperType: DiaperType = DiaperType.pee;
  @State selectedIntensity: string = '';
  @State selectedCondition: string = '';
  @State note: string = '';
  @State useManualTime: boolean = false;
  @State manualHour: number = new Date().getHours();
  @State manualMinute: number = new Date().getMinutes();
  @State manualYear: number = new Date().getFullYear();
  @State manualMonth: number = new Date().getMonth();
  @State manualDay: number = new Date().getDate();
  @State showAdvanced: boolean = false;
  @State showError: boolean = false;
  private options: ArcButtonOptions = new ArcButtonOptions({});
  private viewModel: DiaperViewModel = new DiaperViewModel();

  arcButtonInit() {
    try {
      this.options = new ArcButtonOptions({
        label: 'Add Diaper',
        styleMode: ArcButtonStyleMode.CUSTOM,
        fontSize: new LengthMetrics(15, LengthUnit.FP),
        shadowEnabled: true,
        backgroundColor: ColorMetrics.resourceColor($r('app.color.brand_color')),
        onClick: () => {
          const params = this.pageStack.getParamByName(ADD_BABY_LOG_PAGE) as number[];
          if (params.length > 0) {
            const babyId = params[0] as number;
            const timestamp = this.useManualTime
              ? new Date(this.manualYear, this.manualMonth, this.manualDay, this.manualHour, this.manualMinute)
              : undefined;
            this.viewModel.addDiaper(
              babyId,
              this.diaperType,
              this.note || undefined,
              this.selectedIntensity || undefined,
              this.selectedCondition || undefined,
              timestamp
            ).then((success) => {
              if (success) {
                this.pageStack.pop({ result: true });
              } else {
                this.showError = true;
              }
            });
          }
        }
      });
    } catch (err) {
      console.error(`[BabyDayTracker] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  aboutToAppear(): void {
    this.arcButtonInit();
  }

  @Builder
  typeButton(type: DiaperType, label: string, icon: ResourceStr) {
    Column() {
      Image(icon)
        .width($r('app.float.icon_bigger_size'))
        .height($r('app.float.icon_bigger_size'))
      Text(label)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.diaperType === type ? Color.White : $r('app.color.on_primary_color'))
        .fontSize($r('app.float.item_title_font_size'))
    }
    .borderWidth(1)
    .borderColor(this.diaperType === type ? $r('app.color.brand_border_color') :
      $r('app.color.background_border_color'))
    .backgroundColor(this.diaperType === type ? $r('app.color.brand_color') : $r('app.color.background_color'))
    .borderRadius($r('sys.float.segment_button_height'))
    .padding('8vp')
    .flexShrink(0)
    .onClick(() => {
      this.diaperType = type;
    })
  }

  @Builder
  segmentPicker(label: string, options: string[], selected: string, onSelect: (v: string) => void) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize('10fp')
        .fontColor($r('app.color.on_primary_color'))
        .fontWeight(FontWeight.Bold)
      Row({ space: 4 }) {
        ForEach(options, (opt: string) => {
          Text(opt)
            .fontSize('10fp')
            .fontColor(selected === opt ? Color.White : $r('app.color.on_primary_color'))
            .padding({
              left: 6,
              right: 6,
              top: 3,
              bottom: 3
            })
            .backgroundColor(selected === opt ? $r('app.color.brand_color') : $r('app.color.background_color'))
            .borderWidth(1)
            .borderColor($r('app.color.background_border_color'))
            .borderRadius($r('sys.float.segment_button_height'))
            .onClick(() => onSelect(opt))
        })
      }
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column({ space: 8 }) {
          if (this.showError) {
            Text('Failed to save. Try again.')
              .fontSize('10fp')
              .fontColor($r('app.color.brand_border_color'))
              .margin({ bottom: 4 });
          }

          Text('Diaper Type')
            .fontSize('10fp')
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_primary_color'));

          Row({ space: 8 }) {
            this.typeButton(DiaperType.pee, 'Pee', $r('app.media.pee'));
            this.typeButton(DiaperType.poo, 'Poop', $r('app.media.poop'));
          }
          .width('100%')
          .justifyContent(FlexAlign.Center);

          // Advanced fields toggle
          Row() {
            Text(this.showAdvanced ? 'Hide Details' : 'More Details')
              .fontSize('10fp')
              .fontColor($r('app.color.brand_color'))
              .onClick(() => {
                this.showAdvanced = !this.showAdvanced;
              })
          }
          .margin({ top: 4 });

          if (this.showAdvanced) {
            Column({ space: 8 }) {
              // Intensity
              this.segmentPicker('Intensity', ['Mild', 'Moderate', 'Heavy'], this.selectedIntensity,
                (v) => {
                  this.selectedIntensity = v;
                });

              // Condition
              this.segmentPicker('Condition', ['Normal', 'Loose', 'Watery', 'Constipated'], this.selectedCondition,
                (v) => {
                  this.selectedCondition = v;
                });

              // Note
              TextInput({ placeholder: 'Note (optional)', text: this.note })
                .fontSize('10fp')
                .width('90%')
                .onChange((v) => {
                  this.note = v;
                });

              // Manual time toggle
              Row({ space: 6 }) {
                Text('Custom Time')
                  .fontSize('10fp')
                  .fontColor($r('app.color.on_primary_color'));
                Toggle({ type: ToggleType.Checkbox, isOn: this.useManualTime })
                  .size({ width: 16, height: 16 })
                  .onChange((v) => {
                    this.useManualTime = v;
                  });
              };

              if (this.useManualTime) {
                Row({ space: 4 }) {
                  Text(`${this.manualYear}-${(this.manualMonth + 1).toString()
                    .padStart(2, `0`)}-${this.manualDay.toString().padStart(2, `0`)} ${this.manualHour.toString()
                    .padStart(2, `0`)}:${this.manualMinute.toString().padStart(2, `0`)}`)
                    .fontSize('9fp')
                    .fontColor($r('app.color.on_primary_color'));
                }
                .width('100%')
                .justifyContent(FlexAlign.Center);
              }
            }
            .width('100%');
          }

          Blank(10);
        }
        .width('90%')
        .height('100%')
        .justifyContent(FlexAlign.Center);

        ArcButton({
          options: this.options
        }).align(Alignment.Bottom);
      }
      .width(SizeConstants.FULL_PERCENT)
      .height(SizeConstants.FULL_PERCENT)
    }
    .hideBackButton(true)
  }
}
