class Musicbrainz < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :music_brainz, reading: :music_brainz }
end
