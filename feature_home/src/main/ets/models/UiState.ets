/**
 * Shared UI async state model for use across view models and views.
 * Covers the lifecycle of any async data fetch.
 */
export enum UiState {
  LOADING = 'loading',
  EMPTY = 'empty',
  CONTENT = 'content',
  ERROR = 'error'
}

export interface UiStateContext<T> {
  state: UiState;
  data?: T;
  errorMessage?: string;
}

export const DEFAULT_EMPTY_MESSAGE = 'No data to display';

export const DEFAULT_ERROR_MESSAGE = 'Something went wrong';

export const DEFAULT_RETRY_LABEL = 'Retry';
