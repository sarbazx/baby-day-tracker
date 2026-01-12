import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  ArcScrollBar,
  ColorMetrics,
  LengthMetrics,
  LengthUnit
} from '@kit.ArkUI';
import { BabyBirthSelect, SelectOption } from '../components/BabyBirthSelect';
import { GenderSelect, GenderType } from '../components/GenderSelect';
import { getMonthDays, getMonthNames } from '../lib/date-utils';
import { SizeConstants } from '../lib/SizeConstants';
import BabyViewModel from '../viewmodels/BabyViewModel';

@Component
export struct AddBabyView {
  @Consume('pageStack') pageStack: NavPathStack;
  private scroller: Scroller = new Scroller();
  private controller: TextInputController = new TextInputController();
  private options: ArcButtonOptions = new ArcButtonOptions({});
  @State viewModel: BabyViewModel = new BabyViewModel();
  @State babyName: string = ''
  @State yearOptions: SelectOption[] = []
  @State selectedYearIndex: number = -1;
  @State monthOptions: SelectOption[] = []
  @State selectedMonthIndex: number = -1;
  @State dayOptions: SelectOption[] = [];
  @State selectedDayIndex: number = -1;
  @State selectedBabyGender: GenderType = GenderType.girl;

  arcButtonInit() {
    try {
      this.options = new ArcButtonOptions({
        label: 'Add Baby',
        styleMode: ArcButtonStyleMode.CUSTOM,
        fontSize: new LengthMetrics(15, LengthUnit.FP),
        shadowEnabled: true,
        backgroundColor: ColorMetrics.resourceColor($r('app.color.brand_color')),
        onClick: () => {

          if (this.babyName === '' || this.selectedYearIndex === -1 || this.selectedMonthIndex === -1 ||
            this.selectedDayIndex === -1) {
            return;
          }
          const selectedYear = parseInt(this.yearOptions[this.selectedYearIndex].value);
          const selectedDay = parseInt(this.dayOptions[this.selectedDayIndex].value);
          this.viewModel.addBaby(
            this.babyName,
            selectedYear,
            this.selectedMonthIndex,
            selectedDay,
            this.selectedBabyGender
          ).then((result) => {
            if (result) {
              this.pageStack.pop({ result: true })
            }
          })
        }
      })
    } catch (err) {
      console.error(`[BabyDayTracker] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  daysInit() {
    const currentYear = (new Date()).getFullYear();
    const year = this.selectedYearIndex === -1 ? currentYear : parseInt(this.yearOptions[this.selectedYearIndex].value);
    this.dayOptions = getMonthDays(year, this.selectedMonthIndex)
      .map((value): SelectOption => ({ value: `${value}` }))
  }

  aboutToAppear(): void {
    this.arcButtonInit()
    const currentYear = (new Date()).getFullYear() + 1;
    this.yearOptions = Array
      .from<number, number>({ length: currentYear - (currentYear - 2) }, (_, i) => (currentYear - 2) + i)
      .map((value): SelectOption => ({ value: `${value}` }))
    this.monthOptions = getMonthNames()
      .map((value): SelectOption => ({ value: `${value}` }))
    this.daysInit()
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll(this.scroller) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
          Blank(50)
          GenderSelect({
            currentGender: this.selectedBabyGender,
            onClick: (value: GenderType) => {
              this.selectedBabyGender = value;
            }
          })

          TextInput({ text: this.babyName!!, placeholder: 'Baby Name', controller: this.controller })
            .width(SizeConstants.FULL_PERCENT)
            .inputFilter('[a-zA-Z]', (e) => {
              console.info(JSON.stringify(e));
            })
            .margin({ bottom: 10 })
          Text('Baby Birth Date:')
            .margin({ bottom: 10 })
            .textAlign(TextAlign.Center)
            .fontWeight(FontWeight.Bold)
            .fontSize('12fp')
            .fontColor(Color.White)
            .fontColor($r('app.color.on_primary_color'))
          BabyBirthSelect({
            currentIndex: this.selectedYearIndex,
            options: this.yearOptions,
            label: 'Year',
            onClick: (index) => this.selectedYearIndex = index
          })
          BabyBirthSelect({
            currentIndex: this.selectedMonthIndex,
            options: this.monthOptions,
            label: 'Month',
            onClick: (index) => {
              this.selectedMonthIndex = index;
              this.daysInit();
            }
          })
          BabyBirthSelect({
            currentIndex: this.selectedDayIndex,
            options: this.dayOptions,
            label: 'Day',
            onClick: (index) => this.selectedDayIndex = index
          })
          Blank(100)
        }
      }
      .width('90%')
      .height(SizeConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)

      ArcScrollBar({ scroller: this.scroller, state: BarState.On })
      ArcButton({
        options: this.options
      }).align(Alignment.Bottom)
    }
    .width(SizeConstants.FULL_PERCENT)
    .height(SizeConstants.FULL_PERCENT)
  }
}
