export interface DailyCount {
  date: string;
  count: number;
}

export interface InsightsSummary {
  totalLogs: number;
  todayCount: number;
  weekCount: number;
  monthCount: number;
  peeCount: number;
  pooCount: number;
  averageIntervalMinutes: number | null;
  averageDailyCount: number | null;
  dailyCounts: DailyCount[];
  weekOverWeekChange: number | null;
  lastChange: Date | null;
  isOverdue: boolean;
  dominantType: 'pee' | 'poo' | 'equal' | null;
}
