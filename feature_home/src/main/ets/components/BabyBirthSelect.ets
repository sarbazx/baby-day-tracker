export interface SelectOption {
  value: string
}

interface BabyBirthSelectParams {
  readonly currentIndex: number;
  readonly options: SelectOption[],
  readonly label: string;
  readonly onClick: Callback<number>;
}

@Builder
export function BabyBirthSelect(params: BabyBirthSelectParams) {
  Select(params.options)
    .selected(params.currentIndex === -1 ? 1 : params.currentIndex)
    .value(params.currentIndex === -1 ? params.label : params.options[params.currentIndex].value)
    .width('90%')
    .arrowPosition(ArrowPosition.END)
    .menuAlign(MenuAlignType.CENTER, { dx: 0, dy: 0 })
    .margin({ bottom: 10 })
    .onSelect(params.onClick)
}