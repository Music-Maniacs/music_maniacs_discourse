import DiscourseRoute from "discourse/routes/discourse";
import { hash } from "rsvp";
import { isEmpty } from "@ember/utils";
import { ajax } from "discourse/lib/ajax";
import dIcon from "discourse-common/helpers/d-icon";

export default class Artists extends DiscourseRoute{
  async model(params) {
    // return RSVP.hash({
    //   artist: artistData,
    //   reviews: reviewsJson.reviews,
    //   wikipediaExtract: wikipediaJson.wikipediaExtract
    // });
    return this.store.find('artist', params.id);
  }

  afterModel(model, transition) {
    const reviewsURL = `https://critiquebrainz.org/ws/1/review/?limit=5&entity_id=${model.id}&entity_type=artist`;
    const wikipediaURL = `https://musicbrainz.org/artist/${model.id}/wikipedia-extract`;

    const reviewsData = fetch(reviewsURL).then(
      (result) => {
        this.reviewsData = result.json();
      }
    );

    const wikipediaData = fetch(wikipediaURL)
      .then(response => response.json())
      .then(data => this.wikipediaData = data.wikipediaExtract);

    const promises = {
      reviewsData,
      wikipediaData,
    };

    return hash(promises);
  }

  setupController(controller, model) {
    controller.set("model", model);
    controller.set("reviewsData", this.reviewsData);
    controller.set("wikipediaData", this.wikipediaData);
  }
}
