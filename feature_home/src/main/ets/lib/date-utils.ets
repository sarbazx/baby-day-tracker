export function formatTimestamp(timestamp: number) {
  const MS_PER_SECOND = 1000;
  const MS_PER_MINUTE = 60 * MS_PER_SECOND;
  const MS_PER_HOUR = 60 * MS_PER_MINUTE;
  const MS_PER_DAY = 24 * MS_PER_HOUR;

  const days = Math.floor(timestamp / MS_PER_DAY);
  const hours = Math.floor((timestamp % MS_PER_DAY) / MS_PER_HOUR);
  const minutes = Math.floor((timestamp % MS_PER_HOUR) / MS_PER_MINUTE);

  const daysStr = days > 0 ? `${days} days` : '';
  const hoursStr = hours > 0 ? `${hours} hours` : '';
  const minutesStr = minutes > 0 ? `${minutes} minutes` : '';

  return `${daysStr} ${hoursStr} ${minutesStr}`
}

export function getMonthNames() {
  return Array.from<number, string>({ length: 12 }, (_, monthIndex) => {
    const formatter = new Intl.DateTimeFormat(undefined, { month: 'long' });
    return formatter.format(new Date(2000, monthIndex, 1));
  })
}

export function getMonthDays(year: number, month: number): number[] {
  const days: number = new Date(year, month + 1, 0).getDate();
  return Array.from<number, number>({ length: days }, (_, index): number => index + 1);
}

export function formatAge(timestamp: number) {
  const from = new Date(timestamp);
  const to = new Date();

  let years = to.getFullYear() - from.getFullYear();
  let months = to.getMonth() - from.getMonth();
  let days = to.getDate() - from.getDate();

  if (days < 0) {
    const prevMonthLastDay = new Date(to.getFullYear(), to.getMonth(), 0).getDate();
    days = prevMonthLastDay - from.getDate() + to.getDate();
    months--;
  }

  if (months < 0) {
    months += 12;
    years--;
  }

  const ageParts: string[] = [];

  if (years > 0) {
    ageParts.push(`${years}y`);
  }
  if (months > 0) {
    ageParts.push(`${months}m`);
  }
  if (days > 0) {
    ageParts.push(`${days}d`);
  }

  return ageParts.length > 0 ? ageParts.join(' ') : '0 days';
}


export const formatDate = (date: Date): string => {
  const options: Intl.DateTimeFormatOptions = {
    day: 'numeric',
    month: 'short',
    hour: 'numeric',
    minute: '2-digit',
    hour12: false
  }
  const formatter = new Intl.DateTimeFormat('en-GB', options);
  return formatter.format(date).replace(',', '');
}
