import { DiaperRepository, GlobalContext } from 'feature_store';
import { Diaper, DiaperType } from '../models/Diaper';

export type HistoryPeriod = 'today' | '7days' | '30days' | 'all';

export type HistoryTypeFilter = 'all' | 'pee' | 'poo';

export interface GroupedDiapers {
  label: string;
  data: Diaper[];
  todayStr: string;
}

interface DateRange {
  start?: number;
  end?: number;
}

@Observed
export default class HistoryViewModel {
  @Track
  isLoading: boolean = false;
  @Track
  isEmpty: boolean = true;
  @Track
  groupedDiapers: GroupedDiapers[] = [];
  @Track
  selectedPeriod: HistoryPeriod = '7days';
  @Track
  selectedType: HistoryTypeFilter = 'all';
  private diaperRepository?: DiaperRepository;
  private diaperRepositoryPromise?: Promise<DiaperRepository>;

  constructor() {
    const context = GlobalContext.getInstance().getSavedContext();
    if (context) {
      this.diaperRepositoryPromise = DiaperRepository.getInstance(context).then((repo) => {
        this.diaperRepository = repo;
        return repo;
      });
    }
  }

  async loadHistory(babyId: number) {
    this.isLoading = true;
    this.isEmpty = true;
    this.groupedDiapers = [];

    const repository = this.diaperRepository ?? await this.diaperRepositoryPromise;
    if (!repository) {
      this.isLoading = false;
      return;
    }

    const range = this.getDateRange(this.selectedPeriod);
    const typeFilter = this.selectedType === 'all' ? undefined : this.selectedType;

    const iDiapers = await repository.getDiaperListByBabyIdFiltered(
      babyId,
      range.start,
      range.end,
      typeFilter,
    );

    const diapers: Diaper[] = [];
    for (let i = 0; i < (iDiapers ?? []).length; i++) {
      const d = iDiapers[i];
      const type = d.type === 'pee' ? DiaperType.pee : DiaperType.poo;
      diapers.push(new Diaper(d.babyId, type, d.id, d.timestamp, d.note, d.intensity, d.condition, d.manualTimestamp));
    }

    this.groupedDiapers = this.groupByDate(diapers);
    this.isEmpty = this.groupedDiapers.length === 0;
    this.isLoading = false;
  }

  setPeriod(period: HistoryPeriod, babyId: number) {
    this.selectedPeriod = period;
    this.loadHistory(babyId);
  }

  setType(type: HistoryTypeFilter, babyId: number) {
    this.selectedType = type;
    this.loadHistory(babyId);
  }

  private getDateRange(period: HistoryPeriod): DateRange {
    const now = new Date();
    const endOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999).getTime();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0).getTime();

    switch (period) {
      case 'today': {
        const result: DateRange = { start: startOfToday, end: endOfToday };
        return result;
      }
      case '7days': {
        const d = new Date(now);
        d.setDate(d.getDate() - 7);
        const result: DateRange = { start: d.getTime(), end: endOfToday };
        return result;
      }
      case '30days': {
        const d = new Date(now);
        d.setDate(d.getDate() - 30);
        const result: DateRange = { start: d.getTime(), end: endOfToday };
        return result;
      }
      case 'all':
      default: {
        const result: DateRange = { start: undefined, end: undefined };
        return result;
      }
    }
  }

  private groupByDate(diapers: Diaper[]): GroupedDiapers[] {
    const groups = new Map<string, Diaper[]>();
    const today = new Date();
    const todayStr = new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime();
    const yesterday = todayStr - 24 * 60 * 60 * 1000;

    for (let i = 0; i < diapers.length; i++) {
      const diaper = diapers[i];
      const d = new Date(diaper.timestamp);
      const dateStart = new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime();
      let label: string;
      if (dateStart === todayStr) {
        label = 'Today';
      } else if (dateStart === yesterday) {
        label = 'Yesterday';
      } else {
        label = new Intl.DateTimeFormat('en-GB', { day: 'numeric', month: 'short' }).format(d);
      }
      if (!groups.has(label)) {
        groups.set(label, []);
      }
      const arr = groups.get(label)!;
      arr.push(diaper);
    }
    const result: GroupedDiapers[] = [];
    const keys = Array.from(groups.keys());
    for (let i = 0; i < keys.length; i++) {
      const label = keys[i];
      const data = groups.get(label)!;
      result.push({ label, data, todayStr: `${todayStr}${this.selectedType}` });
    }
    return result;
  }
}
