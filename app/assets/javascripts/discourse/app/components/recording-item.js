import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { getAlbumArtFromReleaseMBID } from "../helpers/album-art";

export default class RecordingItemComponent extends Component {
  @tracked isFavorite = false;
  @tracked recording;

  constructor() {
    super(...arguments);
    this.recording = this.args.recording;
    this.loadCoverArt();
  }

  @action
  async loadCoverArt() {
    try {
      console.log(
        "Fetching cover art for release MBID:",
        this.recording
      )
      const coverArt = await getAlbumArtFromReleaseMBID(this.recording.canonical_release_mbid);
      this.recording = { ...this.recording, cover_art_url: coverArt };
    } catch (error) {
      console.error('Error fetching cover art for recording:', error);
    }
  }
}
