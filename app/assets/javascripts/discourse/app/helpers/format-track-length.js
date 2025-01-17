import { helper } from '@ember/component/helper';

export default helper(function formatDuration([milliseconds]) {
  let seconds = Math.floor(milliseconds / 1000);
  let minutes = Math.floor(seconds / 60);
  seconds = seconds % 60;
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
});