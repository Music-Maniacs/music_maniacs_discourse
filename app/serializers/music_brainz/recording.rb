# frozen_string_literal: true

module MusicBrainz
  class Recording < ApplicationSerializer
    attributes :name, :length
  end
end
