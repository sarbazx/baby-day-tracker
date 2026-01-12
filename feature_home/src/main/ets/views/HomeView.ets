import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  ArcList,
  ArcListAttribute,
  ArcListItem,
  ArcListItemAttribute,
  ColorMetrics,
  ComponentContent,
  LengthMetrics,
  LengthUnit
} from '@kit.ArkUI';
import { BabyListItem } from '../components/BabyListItem';
import { SizeConstants } from '../lib/SizeConstants';
import { Baby } from '../models/Baby';
import BabyViewModel from '../viewmodels/BabyViewModel';

@Builder
function homeViewHeaderBuilder() {
  Column() {
    Text('Babies')
      .fontSize('20vp')
      .fontWeight(FontWeight.Bold)
  }.margin(0)
}

@Component
export struct HomeView {
  @Consume('pageStack') pageStack: NavPathStack;
  context: UIContext = this.getUIContext()
  header: ComponentContent<Object> = new ComponentContent(this.context, wrapBuilder(homeViewHeaderBuilder));
  options: ArcButtonOptions = new ArcButtonOptions({});
  @State loading: boolean = false;
  @State private viewModel: BabyViewModel = new BabyViewModel();

  @Builder
  itemEnd(baby: Baby) {
    Row() {
      Button('Delete')
        .backgroundColor($r('app.color.brand_border_color'))
        .fontColor($r('app.color.on_brand_color'))
        .margin(4)
        .onClick(async () => {
          await this.viewModel.deleteBaby(baby);
        })
    }
    .padding(4)
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  arcButtonInit() {
    try {
      this.options = new ArcButtonOptions({
        label: 'New Baby',
        styleMode: ArcButtonStyleMode.CUSTOM,
        backgroundColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
        fontSize: new LengthMetrics(15, LengthUnit.FP),
        shadowEnabled: true,
        onClick: () => {
          this.pageStack.pushPathByName('AddBabyPage', null, () => {
            this.viewModel.loadBabies();
          });
        }
      })
    } catch (err) {
      console.error(`[BabyDayTracker] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  aboutToAppear(): void {
    this.arcButtonInit();
    this.viewModel?.loadBabies()
  }

  build() {
    Refresh({ refreshing: $$this.loading }) {
      Stack() {
        ArcList({ header: this.header }) {
          if (this.viewModel?.isEmptyData) {
            ArcListItem() {
              Text($r('app.string.empty_babies_message'))
                .fontSize($r('app.float.empty_babies_font_size'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.on_primary_color'))
                .textAlign(TextAlign.Center)
                .width('80%')
            }
          }
          LazyForEach(
            this.viewModel?.datasource,
            (baby: Baby) => {
              ArcListItem() {
                BabyListItem({
                  title: baby.name,
                  subtitle: baby.birthday,
                  image: baby.image
                })
              }
              .width('80%')
              .onClick(() => {
                this.pageStack.pushPathByName('BabyPage', [baby.id]);
              })
              .swipeAction({
                end: {
                  builder: () => {
                    this.itemEnd(baby)
                  },
                  onAction: () => {
                    this.context.animateTo({ duration: 1000 }, () => {
                      this.viewModel.deleteBaby(baby);
                    })
                  },
                  actionAreaDistance: 56
                }
              })
            },
            (baby: Baby, index: number) => `${baby.id}-${index}`
          )
        }
        .cachedCount(5)
        .layoutWeight(1)
        .scrollBar(BarState.On)
        .space(LengthMetrics.px(10))
        .width(SizeConstants.FULL_PERCENT)
        .height(SizeConstants.FULL_PERCENT)

        ArcButton({
          options: this.options
        }).align(Alignment.Bottom)
      }
      .width(SizeConstants.FULL_PERCENT)
      .height(SizeConstants.FULL_PERCENT)
      .alignContent(Alignment.Bottom)
    }
    .onRefreshing(() => this.viewModel?.loadBabies().then(() => {
      this.loading = false;
    }))
    .layoutWeight(1)
    .height(SizeConstants.FULL_PERCENT)
    .width(SizeConstants.FULL_PERCENT)

  }
}
