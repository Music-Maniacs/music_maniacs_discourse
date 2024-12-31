import Controller from '@ember/controller';
import { tracked } from "@glimmer/tracking";
import { computed } from '@ember/object';

// import { getPromiseState } from '@warp-drive/ember';

export default class ArtistController extends Controller {
  @tracked wikipediaData;
  @tracked reviewsData;

  @computed('model.tags.[]')
  get formattedTags() {
    return this.model.tags.map(tag => ({
      count: tag.count,
      label: tag.name
    }));
  }

  @computed('model.genres.[]')
  get formattedGenres() {
    return this.model.genres.map(genre => ({
      count: genre.count,
      label: genre.name
    }));
  }
}
