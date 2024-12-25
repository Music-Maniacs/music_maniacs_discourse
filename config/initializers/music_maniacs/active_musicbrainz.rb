ActiveMusicbrainz::Model::Base.establish_connection(:music_brainz)
ActiveMusicbrainz.init

class ActiveMusicbrainz::Model::Artist
  has_many :artist_tags, foreign_key: :artist

  def tags_list
    artist_tags.joins(:tag).joins('LEFT JOIN genre g ON tag.name = g.name').map do |at|
      { name: at.tag.name, count: at.count, genre: at.tag.genre.gid }
    end
  end
end

class ActiveMusicbrainz::Model::ArtistTag
  belongs_to :artist, foreign_key: :artist
  belongs_to :tag, foreign_key: :tag
end

class ActiveMusicbrainz::Model::Tag
  def genre
    ActiveMusicbrainz::Model::Genre.find_by(name:)
  end
end

class ActiveMusicbrainz::Model::Genre
end


class ActiveMusicbrainz::Model::LArtistUrl
  belongs_to :link, foreign_key: :link
end

class ActiveMusicbrainz::Model::Link
  belongs_to :link_type, foreign_key: :link_type
end
