import Helper from '@ember/component/helper';

export default class FormatNumber extends Helper {
  compute([number], { compact = false }) {
    if (!compact) {
      return number.toLocaleString();
    }

    const suffixes = ['', 'K', 'M', 'B', 'T'];
    let suffixIndex = 0;
    let value = number;

    while (value >= 1000 && suffixIndex < suffixes.length - 1) {
      value /= 1000;
      suffixIndex++;
    }

    // Round to 1 decimal place if there's a decimal
    value = Math.round(value * 10) / 10;

    return `${value}${suffixes[suffixIndex]}`;
  }
}
