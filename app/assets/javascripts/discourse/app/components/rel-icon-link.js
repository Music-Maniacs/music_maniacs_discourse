import Component from '@glimmer/component';

export default class RelIconLink extends Component {
  iconName(relName, relValue) {
    console.log(relName, relValue);
    switch(relName) {
      case "streaming":
      case "free streaming":
        return "music";  // fa-music

      case "lyrics":
        return "microphone";  // fa-microphone

      case "wikidata":
        return "barcode";  // fa-barcode

      case "youtube":
      case "youtube music":
        return "fab-youtube";  // fa-youtube

      case "soundcloud":
        return "fab-soundcloud";  // fa-soundcloud

      case "official homepage":
        return "home";  // fa-home

      case "bandcamp":
        return "fab-bandcamp";  // fa-bandcamp

      case "last.fm":
        return "fab-lastfm";  // fa-lastfm

      case "apple music":
        return "fab-apple";  // fa-apple

      case "get the music":
      case "purchase for mail-order":
      case "purchase for download":
      case "download for free":
        return "compact-disc";  // fa-compact-disc

      case "social network":
      case "online community":
        if (/instagram/.test(relValue)) {
          return "fab-instagram";
        } else if (/facebook/.test(relValue)) {
          return "fab-facebook";
        } else if (/twitter/.test(relValue) || /x.com/.test(relValue)) {
          return "fab-twitter";
        } else if (/soundcloud/.test(relValue)) {
          return "fab-soundcloud";
        } else {
          return "circle-nodes";  // fa-circle-nodes
        }

      default:
        return "link";  // fa-link
    }
  }
}
