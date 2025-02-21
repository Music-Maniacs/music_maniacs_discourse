const generateAlbumArtThumbnailLink = (id, releaseMBID) => {
  return `https://archive.org/download/mbid-${releaseMBID}/mbid-${releaseMBID}-${id}_thumb.jpg`;
};

const getThumbnailFromCAAResponse = (body, size = 250) => {
  if (!body.images?.length) {
    return undefined;
  }
  const { release } = body;
  const regexp = /musicbrainz.org\/release\/(?<mbid>[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12})/g;
  const releaseMBID = regexp.exec(release)?.groups?.mbid;

  const frontImage = body.images.find((image) => image.front);

  if (frontImage?.id && releaseMBID) {
    const { id } = frontImage;
    return generateAlbumArtThumbnailLink(id, releaseMBID);
  }

  const { thumbnails, image } = body.images[0];
  return thumbnails[size] ?? thumbnails.small ?? image;
};

export const getAlbumArtFromReleaseMBID = async (userSubmittedReleaseMBID, optionalSize) => {
  try {
    if (!userSubmittedReleaseMBID) {
      return undefined;
    }

    console.log("Fetching cover art for release MBID:", userSubmittedReleaseMBID);
    const response = await fetch(`https://coverartarchive.org/release/${userSubmittedReleaseMBID}`);
    if (response.ok) {
      const body = await response.json();
      console.log("Cover Art Archive response:", body);
      const coverArt = getThumbnailFromCAAResponse(body, optionalSize);
      if (coverArt) {
        return coverArt;
      }
    }
  } catch (error) {
    console.warn(`Couldn't fetch Cover Art Archive entry for ${userSubmittedReleaseMBID}`, error);
  }
  return undefined;
};
