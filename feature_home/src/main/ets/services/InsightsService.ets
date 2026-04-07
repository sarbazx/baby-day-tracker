import { DiaperRepository, GlobalContext, IDiaper } from 'feature_store';
import { DailyCount, InsightsSummary } from '../models/InsightsSummary';
import { isOverdue } from '../lib/date-utils';

export default class InsightsService {
  private static instance?: InsightsService;
  private diaperRepository?: DiaperRepository;
  private diaperRepositoryPromise?: Promise<DiaperRepository>;

  private constructor() {
    const context = GlobalContext.getInstance().getSavedContext();
    if (context) {
      this.diaperRepositoryPromise = DiaperRepository.getInstance(context).then((repo) => {
        this.diaperRepository = repo;
        return repo;
      });
    }
  }

  static getInstance(): InsightsService {
    if (!InsightsService.instance) {
      InsightsService.instance = new InsightsService();
    }
    return InsightsService.instance;
  }

  async computeSummary(babyId: number): Promise<InsightsSummary> {
    const repository = this.diaperRepository ?? await this.diaperRepositoryPromise;

    const allDiapers = repository ? await repository.getDiaperListByBabyId(babyId) : [];
    const todayDiapers = repository ?
      await repository.getDiaperListByBabyIdFiltered(babyId, this.getPeriodStart(0), undefined, undefined) : [];
    const weekDiapers = repository ?
      await repository.getDiaperListByBabyIdFiltered(babyId, this.getPeriodStart(7), undefined, undefined) : [];
    const monthDiapers = repository ?
      await repository.getDiaperListByBabyIdFiltered(babyId, this.getPeriodStart(30), undefined, undefined) : [];
    const lastWeekDiapers = repository ?
      await repository.getDiaperListByBabyIdFiltered(babyId, this.getPeriodStart(14), this.getPeriodStart(7),
        undefined) : [];

    const sorted: IDiaper[] = [];
    for (let i = 0; i < allDiapers.length; i++) {
      sorted.push(allDiapers[i]);
    }
    for (let i = 0; i < sorted.length; i++) {
      for (let j = i + 1; j < sorted.length; j++) {
        if (sorted[i].timestamp.getTime() > sorted[j].timestamp.getTime()) {
          const tmp = sorted[i];
          sorted[i] = sorted[j];
          sorted[j] = tmp;
        }
      }
    }

    let peeCount = 0;
    let pooCount = 0;
    for (let i = 0; i < allDiapers.length; i++) {
      if (allDiapers[i].type === 'pee') {
        peeCount++;
      } else {
        pooCount++;
      }
    }

    let dominantType: 'pee' | 'poo' | 'equal' | null = null;
    if (peeCount > 0 || pooCount > 0) {
      dominantType = peeCount > pooCount ? 'pee' : pooCount > peeCount ? 'poo' : 'equal';
    }

    let averageIntervalMinutes: number | null = null;
    if (sorted.length >= 2) {
      let totalMs = 0;
      for (let i = 1; i < sorted.length; i++) {
        totalMs += sorted[i].timestamp.getTime() - sorted[i - 1].timestamp.getTime();
      }
      averageIntervalMinutes = Math.round(totalMs / (sorted.length - 1) / (1000 * 60));
    }

    const dailyCounts: DailyCount[] = [];
    for (let i = 2; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const dayStart = new Date(d.getFullYear(), d.getMonth(), d.getDate(), 0, 0, 0, 0).getTime();
      const dayEnd = new Date(d.getFullYear(), d.getMonth(), d.getDate(), 23, 59, 59, 999).getTime();
      let count = 0;
      for (let j = 0; j < allDiapers.length; j++) {
        const ts = allDiapers[j].timestamp.getTime();
        if (ts >= dayStart && ts <= dayEnd) {
          count++;
        }
      }
      dailyCounts.push({ date: this.getDateLabel(dayStart), count });
    }

    const thisWeekCount = weekDiapers.length;
    const lastWeekCount = lastWeekDiapers.length;
    let weekOverWeekChange: number | null = null;
    if (lastWeekCount > 0) {
      weekOverWeekChange = Math.round(((thisWeekCount - lastWeekCount) / lastWeekCount) * 100);
    }

    let avgDaily: number | null = null;
    if (dailyCounts.length > 0) {
      let sum = 0;
      for (let i = 0; i < dailyCounts.length; i++) {
        sum += dailyCounts[i].count;
      }
      avgDaily = Math.round(sum / dailyCounts.length * 10) / 10;
    }

    const lastChange: Date | null = sorted.length > 0 ? sorted[sorted.length - 1].timestamp : null;

    return {
      totalLogs: allDiapers.length,
      todayCount: todayDiapers.length,
      weekCount: thisWeekCount,
      monthCount: monthDiapers.length,
      peeCount,
      pooCount,
      averageIntervalMinutes,
      averageDailyCount: avgDaily,
      dailyCounts,
      weekOverWeekChange,
      lastChange,
      isOverdue: isOverdue(lastChange ?? undefined, 4),
      dominantType
    };
  }

  private getPeriodStart(days: number): number {
    const d = new Date();
    d.setDate(d.getDate() - days);
    d.setHours(0, 0, 0, 0);
    return d.getTime();
  }

  private getDateLabel(ts: number): string {
    const d = new Date(ts);
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
}
