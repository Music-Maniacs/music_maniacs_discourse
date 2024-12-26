# frozen_string_literal: true

ActiveMusicbrainz::Model::Base.establish_connection(:music_brainz)
ActiveMusicbrainz.init

class ActiveMusicbrainz::Model::Artist
  LINK_GIDS = [
      '99429741-f3f6-484b-84f8-23af51991770',  # social network
      'fe33d22f-c3b0-4d68-bd53-a856badf2b15',  # official homepage
      '689870a4-a1e4-4912-b17f-7b2664215698',  # wikidata
      '93883cf6-e818-4938-990e-75863f8db2d3',  # crowdfunding
      '6f77d54e-1d81-4e1a-9ea5-37947577151b',  # patronage
      'e4d73442-3762-45a8-905c-401da65544ed',  # lyrics
      '611b1862-67af-4253-a64f-34adba305d1d',  # purchase for mail-order
      'f8319a2f-f824-4617-81c8-be6560b3b203',  # purchase for download
      '34ae77fe-defb-43ea-95d4-63c7540bac78',  # download for free
      '769085a1-c2f7-4c24-a532-2375a77693bd',  # free streaming
      '63cc5d1f-f096-4c94-a43f-ecb32ea94161',  # streaming
      '6a540e5b-58c6-4192-b6ba-dbc71ec8fcf0'   # youtube
  ].freeze

  has_many :artist_tags, foreign_key: :artist

  def tags_list
    artist_tags.joins(:tag).joins('LEFT JOIN genre g ON tag.name = g.name').map do |at|
      { name: at.tag.name, count: at.count, genre: at.tag.genre.gid }
    end
  end

  def rels
    l_artist_urls.joins({ link: :link_type })
                 .joins(:url)
                 .where(link_type: { gid: LINK_GIDS })
                 .where('link.ended = ?', false)
                 .map do |lau|
                  { name: lau.link.link_type.name, url: lau.url.url }
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
