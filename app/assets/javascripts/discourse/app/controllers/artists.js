import Controller from '@ember/controller';
import { tracked, cached } from "@glimmer/tracking";
// import { getPromiseState } from '@warp-drive/ember';

export default class ArtistController extends Controller {
  @tracked wikipediaData;
  @tracked reviewsData;

  @cached
  get request() {
    let promise = fetch(this.args.url);

    return getPromiseState(promise);
  }
}
