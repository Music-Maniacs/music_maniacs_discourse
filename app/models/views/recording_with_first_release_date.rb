class Views::RecordingWithFirstReleaseDate < Musicbrainz
  self.primary_key = 'recording_id'

  belongs_to :recording, class_name: 'ActiveMusicbrainz::Model::Recording', foreign_key: :recording_id
end
