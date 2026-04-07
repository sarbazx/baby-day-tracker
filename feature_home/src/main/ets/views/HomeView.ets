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
import { AppPreferencesService, GlobalContext, HomeSortMode } from 'feature_store';
import { EmptyState } from '../components/EmptyState';
import { BabyListItem, BabyListItemSummary } from '../components/BabyListItem';
import { SizeConstants } from '../lib/SizeConstants';
import { Baby } from '../models/Baby';
import { DiaperType } from '../models/Diaper';
import BabyViewModel from '../viewmodels/BabyViewModel';
import { showDeleteConfirm } from '../components/ConfirmDialog';
import { HomeHeader } from '../components/HomeHeader';

@Component
export struct HomeView {
  @Consume('pageStack') pageStack: NavPathStack;
  context: UIContext = this.getUIContext();
  options: ArcButtonOptions = new ArcButtonOptions({});
  @State loading: boolean = false;
  @State private viewModel: BabyViewModel = new BabyViewModel();
  @State private loadedBabies: Baby[] = [];
  @State private diaperSummaries: Map<number, BabyListItemSummary> = new Map();
  @State private sortMode: HomeSortMode = HomeSortMode.RECENT_FIRST;
  @State private totalToday: number = 0;
  @State private overdueCount: number = 0;

  @Builder
  itemEnd(baby: Baby) {
    Row() {
      Button('❌')
        .backgroundColor($r('app.color.on_primary_color'))
        .margin(2)
        .onClick(async () => {
          const confirmed = await showDeleteConfirm(this.context, baby.name);
          if (confirmed) {
            await this.viewModel.deleteBaby(baby);
          }
        })
    }
    .padding(2)
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
            this.loadBabies();
          });
        }
      })
    } catch (err) {
      console.error(`[BabyDayTracker] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  aboutToAppear(): void {
    this.arcButtonInit();
    this.loadWithPreferences();
  }

  build() {
    Refresh({ refreshing: $$this.loading }) {
      Stack() {
        ArcList() {
          // Header with summary and sort controls
          ArcListItem() {
            HomeHeader({
              sortMode: this.sortMode,
              loadedCount: this.loadedBabies.length,
              totalToday: this.totalToday,
              overdueCount: this.overdueCount,
              onSortChange: (mode: HomeSortMode) => {
                this.sortMode = mode;
              }
            })
          }

          if (this.loadedBabies.length === 0 && !this.loading) {
            ArcListItem() {
              EmptyState({
                message: 'No babies yet',
                subtitle: 'Add your first baby to start tracking diaper changes',
                actionLabel: 'Add Baby',
                onAction: () => {
                  this.pageStack.pushPathByName('AddBabyPage', null, () => {
                    this.loadBabies();
                  });
                }
              })
            }
          }

          ForEach(this.getSortedBabies(), (baby: Baby) => {
            ArcListItem() {
              BabyListItem({
                title: baby.name,
                subtitle: baby.birthday,
                image: baby.image,
                summary: this.diaperSummaries.get(baby.id),
                onQuickPee: () => {
                  this.viewModel.quickLog(baby.id, DiaperType.pee).then(() => {
                    this.loadBabies();
                  });
                },
                onQuickPoo: () => {
                  this.viewModel.quickLog(baby.id, DiaperType.poo).then(() => {
                    this.loadBabies();
                  });
                }
              })
            }
            .width(SizeConstants.EIGHTY_PERCENT)
            .onClick(() => {
              const savedContext = GlobalContext.getInstance().getSavedContext();
              if (savedContext) {
                void AppPreferencesService.getInstance(savedContext)
                  .then((service) => service.setLastSelectedBabyId(baby.id))
                  .catch(() => {
                  });
              }
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
          }, (baby: Baby) => `${baby.id}`)
        }
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
    .onRefreshing(async () => {
      await this.loadBabies();
      this.loading = false;
    })
    .layoutWeight(1)
    .height(SizeConstants.FULL_PERCENT)
    .width(SizeConstants.FULL_PERCENT)
  }

  private computeTotalToday(): number {
    let total = 0;
    this.diaperSummaries.forEach((sum) => {
      total += sum.todayCount;
    });
    return total;
  }

  private computeOverdueCount(): number {
    let count = 0;
    this.diaperSummaries.forEach((sum) => {
      if (sum.isOverdue) {
        count++;
      }
    });
    return count;
  }

  private getSortedBabies(): Baby[] {
    const sorted = [...this.loadedBabies];
    switch (this.sortMode) {
      case HomeSortMode.NAME_ASC:
        return sorted.sort((a, b) => a.name.localeCompare(b.name));
      case HomeSortMode.OVERDUE_FIRST:
        return sorted.sort((a, b) => {
          const sumA = this.diaperSummaries.get(a.id);
          const sumB = this.diaperSummaries.get(b.id);
          const overdueA = sumA?.isOverdue ? 0 : 1;
          const overdueB = sumB?.isOverdue ? 0 : 1;
          return overdueA - overdueB;
        });
      case HomeSortMode.OLDEST_FIRST:
        return sorted.sort((a, b) => a.dateOfBirth.getTime() - b.dateOfBirth.getTime());
      case HomeSortMode.RECENT_FIRST:
      default:
        return sorted.sort((a, b) => b.dateOfBirth.getTime() - a.dateOfBirth.getTime());
    }
  }

  private async loadWithPreferences(): Promise<void> {
    try {
      const ctx = GlobalContext.getInstance().getSavedContext();
      if (ctx) {
        const prefs = await AppPreferencesService.getInstance(ctx);
        this.sortMode = (await prefs.getState()).homeSortMode;
      }
    } catch (error) {
      console.error(`[HomeView] ${error.code} ${error.message}`)
    }
    await this.loadBabies();
  }

  private async loadBabies(): Promise<void> {
    await this.viewModel.loadBabies();
    const babies: Baby[] = [];
    const summaries = new Map<number, BabyListItemSummary>();
    for (let i = 0; i < this.viewModel.datasource.totalCount(); i++) {
      const baby = this.viewModel.datasource.getData(i);
      if (baby) {
        babies.push(baby);
        const vmSummary = this.viewModel.getBabySummary(baby.id);
        summaries.set(baby.id, {
          lastChange: vmSummary.lastChange,
          todayCount: vmSummary.todayCount,
          isOverdue: vmSummary.isOverdue
        });
      }
    }
    this.loadedBabies = babies;
    this.diaperSummaries = summaries;
    this.totalToday = this.computeTotalToday();
    this.overdueCount = this.computeOverdueCount();
  }
}
