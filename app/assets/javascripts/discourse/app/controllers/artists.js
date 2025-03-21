import Controller from '@ember/controller';
import { tracked } from "@glimmer/tracking";
import { computed, action } from '@ember/object';

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

  @action
  async updateTagCount(tagName, newCount) {
    const tag = this.model.tags.find(t => t.name === tagName);
    if (tag) {
      tag.count = newCount;
      // Add your API call here to persist the change
      // await this.store.updateTag(tag.id, newCount);
    }
  }

  @action
  async updateGenreCount(genreName, newCount) {
    const genre = this.model.genres.find(g => g.name === genreName);
    if (genre) {
      genre.count = newCount;
      // Add your API call here to persist the change
      // await this.store.updateGenre(genre.id, newCount);
    }
  }
}
