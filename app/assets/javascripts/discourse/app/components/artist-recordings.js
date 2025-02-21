import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { inject as service } from '@ember/service';

export default class ArtistRecordingsComponent extends Component {
  @service store;
  @tracked recordings = [];

  constructor() {
    super(...arguments);
    console.log('ArtistRecordingsComponent initialized');
    this.loadRecordings();
  }

  @action
  async loadRecordings() {
    const artistId = this.args.artistId;
    console.log(`Fetching recordings for artist ID: ${artistId}`);
    try {
      const response = await fetch(`/artists/${artistId}/top_recordings.json`);
      if (!response.ok) {
        throw new Error(`Failed to fetch recordings: ${response.statusText}`);
      }
      const data = await response.json();
      console.log('Recordings data:', data);
      this.recordings = data;
    } catch (error) {
      console.error('Error fetching recordings:', error);
    }
  }
}
