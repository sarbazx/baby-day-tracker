import { DIAPER_DETAIL_PAGE } from '../../../../Index';
import { SizeConstants } from '../lib/SizeConstants';
import { Diaper, DiaperType } from '../models/Diaper';
import DiaperViewModel from '../viewmodels/DiaperViewModel';
import { Baby } from '../models/Baby';
import { DiaperDetailParams } from './PageParams';
import { showDeleteConfirm } from '../components/ConfirmDialog';

@Component
export struct DiaperDetailPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State params: DiaperDetailParams = { diaperId: -1, babyId: -1 };
  @State diaper: Diaper = new Diaper(-1);
  @State loading: boolean = true;
  @State isEditing: boolean = false;
  private viewModel: DiaperViewModel = new DiaperViewModel();
  private context: UIContext = this.getUIContext();

  aboutToAppear(): void {
    this.loadDiaper();
  }

  async loadDiaper() {
    // Build the diaper from repository data
    const repository = await this.viewModel.getDiaperRepository();
    if (repository) {
      const diapers = await repository.getDiaperListByBabyId(this.params.babyId);
      const found = diapers.find(d => d.id === this.params.diaperId);
      if (found) {
        const type = found.type === 'pee' ? DiaperType.pee : DiaperType.poo;
        this.diaper = new Diaper(
          found.babyId,
          type,
          found.id,
          found.timestamp,
          found.note,
          found.intensity,
          found.condition,
          found.manualTimestamp
        );
      }
    }
    this.loading = false;
  }

  build() {
    NavDestination() {
      if (this.loading) {
        Column() {
          LoadingProgress()
            .width('32vp')
            .height('32vp')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.diaper.id === undefined || this.diaper.id === -1) {
        Column() {
          Text('Log not found')
            .fontSize('14fp')
            .fontColor($r('app.color.brand_border_color'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Column({ space: 12 }) {
          // Type
          Row({ space: 8 }) {
            Image(this.diaper.type === DiaperType.pee ? $r('app.media.pee') : $r('app.media.poop'))
              .width('24vp')
              .height('24vp');
            Text(this.diaper.type === DiaperType.pee ? 'Pee' : 'Poop')
              .fontSize('16fp')
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White);
          }
          .padding(12)
          .backgroundColor($r('app.color.brand_color'))
          .borderRadius(8)
          .width('90%');

          // Date
          Row({ space: 8 }) {
            Text('Time')
              .fontSize('12fp')
              .fontColor($r('app.color.on_primary_color'));
            Text(this.diaper.date)
              .fontSize('12fp')
              .fontColor(Color.White);
          }
          .width('90%');

          // Intensity
          if (this.diaper.intensity) {
            Row({ space: 8 }) {
              Text('Intensity')
                .fontSize('12fp')
                .fontColor($r('app.color.on_primary_color'));
              Text(this.diaper.intensity)
                .fontSize('12fp')
                .fontColor(Color.White);
            }
            .width('90%');
          }

          // Condition
          if (this.diaper.condition) {
            Row({ space: 8 }) {
              Text('Condition')
                .fontSize('12fp')
                .fontColor($r('app.color.on_primary_color'));
              Text(this.diaper.condition)
                .fontSize('12fp')
                .fontColor(Color.White);
            }
            .width('90%');
          }

          // Note
          if (this.diaper.note) {
            Column({ space: 4 }) {
              Text('Note')
                .fontSize('12fp')
                .fontColor($r('app.color.on_primary_color'))
                .width('90%');
              Text(this.diaper.note)
                .fontSize('12fp')
                .fontColor(Color.White)
                .width('90%');
            }
            .width('90%');
          }

          Blank(20);

          Row({ space: 12 }) {
            Button('Edit')
              .fontSize('12fp')
              .fontColor(Color.White)
              .backgroundColor($r('app.color.brand_color'))
              .borderRadius($r('sys.float.segment_button_height'))
              .padding({
                left: 16,
                right: 16,
                top: 8,
                bottom: 8
              })
              .onClick(() => {
                this.isEditing = true;
              });

            Button('Delete')
              .fontSize('12fp')
              .fontColor($r('app.color.brand_border_color'))
              .backgroundColor(Color.Transparent)
              .borderColor($r('app.color.brand_border_color'))
              .borderWidth(1)
              .borderRadius($r('sys.float.segment_button_height'))
              .padding({
                left: 16,
                right: 16,
                top: 8,
                bottom: 8
              })
              .onClick(async () => {
                const confirmed = await showDeleteConfirm(this.context, 'this diaper log');
                if (confirmed && this.diaper.id !== undefined) {
                  await this.viewModel.deleteDiaperById(this.params.diaperId);
                  this.pageStack.pop();
                }
              });
          }
          .width('90%')
          .justifyContent(FlexAlign.Center);
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center);
      }
    }
    .hideBackButton(false)
    .title('Log Detail')
    .onReady((context) => {
      const param = context.pathInfo.param as Record<string, Object>;
      const diaperIdVal = param['diaperId'];
      const babyIdVal = param['babyId'];
      if (diaperIdVal !== undefined && diaperIdVal !== null &&
        babyIdVal !== undefined && babyIdVal !== null) {
        this.params = {
          diaperId: diaperIdVal as number,
          babyId: babyIdVal as number
        };
        this.loadDiaper();
      }
    })
  }
}
