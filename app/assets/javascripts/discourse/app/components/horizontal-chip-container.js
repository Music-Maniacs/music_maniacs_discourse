import Component from '@glimmer/component';

export default class HorizontalChipContainer extends Component {
  constructor() {
    super(...arguments);
    console.log('HorizontalChipContainer initialized');
    console.log('Genres:', this.genres);
  }

  get genres() {
    return this.args.genres || 'post-rock';
  }
}
