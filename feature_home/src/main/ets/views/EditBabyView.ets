import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  ArcScrollBar,
  ColorMetrics,
  LengthMetrics,
  LengthUnit
} from '@kit.ArkUI';
import { BABY_PAGE } from '../../../../Index';
import { BabyBirthSelect, SelectOption } from '../components/BabyBirthSelect';
import { GenderSelect, GenderType } from '../components/GenderSelect';
import { getMonthDays, getMonthNames } from '../lib/date-utils';
import { SizeConstants } from '../lib/SizeConstants';
import { Baby } from '../models/Baby';
import BabyViewModel from '../viewmodels/BabyViewModel';

@Component
export struct EditBabyView {
  @Consume('pageStack') pageStack: NavPathStack;
  @Prop @Require baby: Baby;
  @State babyName: string = '';
  @State yearOptions: SelectOption[] = [];
  @State selectedYearIndex: number = -1;
  @State monthOptions: SelectOption[] = [];
  @State selectedMonthIndex: number = -1;
  @State dayOptions: SelectOption[] = [];
  @State selectedDayIndex: number = -1;
  @State selectedBabyGender: GenderType = GenderType.girl;
  @State isArchived: boolean = false;
  private scroller: Scroller = new Scroller();
  private controller: TextInputController = new TextInputController();
  private options: ArcButtonOptions = new ArcButtonOptions({});
  private viewModel: BabyViewModel = new BabyViewModel();

  aboutToAppear(): void {
    this.initForm();
    this.arcButtonInit();
  }

  initForm() {
    this.babyName = this.baby.name;
    this.selectedBabyGender = this.baby.gender === 'boy' ? GenderType.boy : GenderType.girl;
    this.isArchived = this.baby.isArchived;

    const currentYear = (new Date()).getFullYear() + 1;
    this.yearOptions = Array
      .from<number, number>({ length: currentYear - (currentYear - 2) }, (_, i) => (currentYear - 2) + i)
      .map((value): SelectOption => ({ value: `${value}` }));

    const birthDate = this.baby.dateOfBirth;
    const birthYear = birthDate.getFullYear();
    this.selectedYearIndex = this.yearOptions.findIndex(o => parseInt(o.value) === birthYear);
    if (this.selectedYearIndex === -1) {
      this.selectedYearIndex = 0;
    }

    this.monthOptions = getMonthNames()
      .map((value): SelectOption => ({ value: `${value}` }));
    this.selectedMonthIndex = birthDate.getMonth();

    this.dayOptions = getMonthDays(birthYear, birthDate.getMonth())
      .map((value): SelectOption => ({ value: `${value}` }));
    this.selectedDayIndex = this.dayOptions.findIndex(o => parseInt(o.value) === birthDate.getDate());
    if (this.selectedDayIndex === -1) {
      this.selectedDayIndex = 0;
    }
  }

  daysInit() {
    const currentYear = (new Date()).getFullYear();
    const year =
      this.selectedYearIndex >= 0 ? parseInt(this.yearOptions[this.selectedYearIndex]?.value ?? `${currentYear}`) :
        currentYear;
    this.dayOptions = getMonthDays(year, this.selectedMonthIndex)
      .map((value): SelectOption => ({ value: `${value}` }));
  }

  arcButtonInit() {
    try {
      this.options = new ArcButtonOptions({
        label: 'Save',
        styleMode: ArcButtonStyleMode.CUSTOM,
        fontSize: new LengthMetrics(15, LengthUnit.FP),
        shadowEnabled: true,
        backgroundColor: ColorMetrics.resourceColor($r('app.color.brand_color')),
        onClick: async () => {
          if (this.babyName === '' || this.selectedYearIndex < 0 ||
            this.selectedMonthIndex < 0 || this.selectedDayIndex < 0) {
            return;
          }
          const selectedYear = parseInt(this.yearOptions[this.selectedYearIndex].value);
          const selectedDay = parseInt(this.dayOptions[this.selectedDayIndex].value);
          const success = await this.viewModel.updateBaby(
            this.baby.id,
            this.babyName,
            selectedYear,
            this.selectedMonthIndex,
            selectedDay,
            this.selectedBabyGender,
            this.isArchived,
          );
          if (success) {
            await this.viewModel.loadBabies();
            this.pageStack.pushPathByName('BabyPage', [this.baby.id]);
          }
        }
      });
    } catch (err) {
      console.error(`[BabyDayTracker] edit baby failed: ${err}`);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll(this.scroller) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
          Blank(20);

          GenderSelect({
            currentGender: this.selectedBabyGender,
            onClick: (value: GenderType) => {
              this.selectedBabyGender = value;
            }
          });

          TextInput({ text: this.babyName, placeholder: 'Baby Name', controller: this.controller })
            .width(SizeConstants.FULL_PERCENT)
            .inputFilter('[a-zA-Z]', (e) => {
              console.info(JSON.stringify(e));
            })
            .onChange((value: string) => {
              this.babyName = value;
            })
            .margin({ bottom: 10 });

          Text('Baby Birth Date:')
            .margin({ bottom: 10 })
            .textAlign(TextAlign.Center)
            .fontWeight(FontWeight.Bold)
            .fontSize('12fp')
            .fontColor($r('app.color.on_primary_color'));

          BabyBirthSelect({
            currentIndex: this.selectedYearIndex,
            options: this.yearOptions,
            label: 'Year',
            onClick: (index) => this.selectedYearIndex = index
          });
          BabyBirthSelect({
            currentIndex: this.selectedMonthIndex,
            options: this.monthOptions,
            label: 'Month',
            onClick: (index) => {
              this.selectedMonthIndex = index;
              this.daysInit();
            }
          });
          BabyBirthSelect({
            currentIndex: this.selectedDayIndex,
            options: this.dayOptions,
            label: 'Day',
            onClick: (index) => this.selectedDayIndex = index
          });

          Blank(10);

          Row({ space: 12 }) {
            Button(this.isArchived ? 'Unarchive' : 'Archive')
              .fontSize('12fp')
              .fontColor(this.isArchived ? $r('app.color.on_brand_color') : $r('app.color.brand_border_color'))
              .backgroundColor(Color.Transparent)
              .borderColor(this.isArchived ? $r('app.color.on_brand_color') : $r('app.color.brand_border_color'))
              .borderWidth(1)
              .borderRadius($r('sys.float.segment_button_height'))
              .padding({
                left: 12,
                right: 12,
                top: 6,
                bottom: 6
              })
              .onClick(() => {
                this.isArchived = !this.isArchived;
              });
          };

          Blank(100);
        }
      }
      .width('90%')
      .height(SizeConstants.FULL_PERCENT)
      .scrollBar(BarState.Off);

      ArcScrollBar({ scroller: this.scroller, state: BarState.On });
      ArcButton({
        options: this.options
      }).align(Alignment.Bottom);
    }
    .width(SizeConstants.FULL_PERCENT)
    .height(SizeConstants.FULL_PERCENT);
  }
}
