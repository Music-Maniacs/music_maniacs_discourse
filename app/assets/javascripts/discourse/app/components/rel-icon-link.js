import Component from '@glimmer/component';

const ICON_MAP = {
  wikidata: 'wikipedia-w',
  discogs: 'discogs',
  allmusic: 'allmusic',
  // Add more mappings as needed
};

export default class RelIconLink extends Component {
  get icon() {
    return ICON_MAP[this.args.relName] || 'far-square';
  }
}
