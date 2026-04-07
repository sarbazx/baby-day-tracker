
export interface EditBabyParams {
  babyId: number;
}

export interface HistoryParams {
  babyId: number;
}

export interface InsightsParams {
  babyId: number;
}

export interface SettingsParams {
  // no-op entry
}

export interface OnboardingParams {
  // no-op entry
}

export interface HomePageParams {
  // no-op entry
}

export interface BabyPageParams {
  babyId: number;
}

export interface AddBabyPageParams {
  // no-op entry
}

export interface AddBabyLogPageParams {
  babyId: number;
}

export interface DiaperDetailParams {
  diaperId: number;
  babyId: number;
}

export type PageParams =
  | EditBabyParams
    | HistoryParams
    | InsightsParams
    | SettingsParams
    | OnboardingParams
    | HomePageParams
    | BabyPageParams
    | AddBabyPageParams
    | AddBabyLogPageParams
    | DiaperDetailParams;
