# frozen_string_literal: true

module MusicBrainz
  class Recording < ApplicationSerializer
    attributes :name, :length, :canonical_release_mbid
  end
end
