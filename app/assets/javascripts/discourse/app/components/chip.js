import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';

export default class Chip extends Component {
  @tracked count = 1;
  @tracked showControls = false;

  get genre() {
    return this.args.genre || 'post-rock';
  }

  @action
  toggleControls() {
    this.showControls = !this.showControls;
  }

  @action
  incrementCount() {
    this.count++;
  }

  @action
  decrementCount() {
    if (this.count > 0) {
      this.count--;
    }
  }
}
