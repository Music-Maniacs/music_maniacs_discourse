import Controller from '@ember/controller';
import { tracked } from "@glimmer/tracking";
import { computed } from '@ember/object';

// import { getPromiseState } from '@warp-drive/ember';

export default class ArtistController extends Controller {
  @tracked wikipediaData;
  @tracked reviewsData;

  @computed('model.artist.tag.[]')
  get formattedTags() {
    console.log(this.model.artist.tag.artist);
    return this.model.artist.tag.artist.map(tag => ({
      count: tag.count,
      label: tag.tag
    }));
  }
}
