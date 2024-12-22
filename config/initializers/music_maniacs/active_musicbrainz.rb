ActiveMusicbrainz::Model::Base.establish_connection(:music_brainz)
ActiveMusicbrainz.init

class ActiveMusicbrainz::Model::Artist
  has_many :artist_tag, foreing_key: :artist
end

class ActiveMusicbrainz::Model::ArtistTag
  belongs_to :artist, foreign_key: :artist
  belongs_to :tag, foreign_key: :tag
end

class ActiveMusicbrainz::Model::Tag
end


class ActiveMusicbrainz::Model::LArtistUrl
  belongs_to :link, foreign_key: :link
end

class ActiveMusicbrainz::Model::Link
  belongs_to :link_type, foreign_key: :link_type
end
