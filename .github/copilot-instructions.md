# What is this project about?

An open-source online community for music lovers. Combining [music brainz's](https://github.com/metabrainz/musicbrainz-server) public database, and the all mighty open source discussion platform [discourse](https://github.com/discourse/discourse), we aim to create the place every music maniac has only dare to dream of.

Mission: The go-to platform for *discussing* everything about music.

Vission: The ultimate platform for music exploration and discovery.

# Instructions for generating ember components

components files go in app/assets/javascripts/discourse/app/components

they consist of a template: component-name.hbs and a js file component-name.js

js file always starts with:

export default class ArtistRecordings extends Component {
  // reactive properties if needed
  @tracked reactive_properti1 = var;
  @tracked reactive_properti2 = var;
  @tracked reactive_properti3 = var;
  chageReactiveProperty() {
      console.log('property:', this.property1);
      this.property1 = newData;
  }

  constructor() {
    super(...arguments);
    console.log('ComponentName initialized');
  }
}

styles files go under: app/assets/stylesheets/common/components/component-name.scss

and should be imported in app/assets/stylesheets/common/components/_index.scss:

@import "component-name";
