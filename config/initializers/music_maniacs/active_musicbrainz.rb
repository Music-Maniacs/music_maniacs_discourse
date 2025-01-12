# frozen_string_literal: true

ActiveMusicbrainz::Model::Base.establish_connection(:music_brainz)
ActiveMusicbrainz.init
AMBM = ActiveMusicbrainz::Model

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
      { name: at.tag.name, count: at.count, genre: at.tag&.genre&.gid }
    end
  end

  def only_tags
    artist_tags.joins(:tag).joins('LEFT JOIN genre g ON tag.name = g.name').where('g.gid IS NULL')
  end

  def only_genres
    artist_tags.joins(:tag).joins('LEFT JOIN genre g ON tag.name = g.name').where('g.gid IS NOT NULL')
  end

  def rels
    l_artist_urls.joins({ link: :link_type })
                 .joins(:url)
                 .where('link.ended = ?', false)
                 .map do |lau|
                  { name: lau.link.link_type.name, url: lau.url.url }
                 end
  end

  def recordings_with_first_release_date

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

class ActiveMusicbrainz::Model::LinkType
end

class ActiveMusicbrainz::Model::ReleaseGroup
  has_one :release_group_meta, foreign_key: :id
end

class ActiveMusicbrainz::Model::Recording
  def self.releases_for_artist(artist_id, direction = 'ASC')
    subquery = base_query(artist_id)

    select('recording_id, recording_name, first_release_date').from("(#{subquery.to_sql}) AS ranked_releases")
      .where('rn = 1')
  end

  private

  def self.base_query(artist_id, direction)
    select([
      'recordings.id AS recording_id',
      'recordings.name AS recording_name',
      'release_groups.id AS release_group_id',
      'release_groups.gid AS release_group_gid',
      'release_groups.name AS release_group_name',
      'release_groups.type AS primary_type_id',
      'release_groups.artist_credit AS artist_credit_id',
      release_date_sql,
      row_number_sql
    ])
    .from('recording recordings')
    .joins('JOIN track tracks ON tracks.recording = recording.id')
    .joins('JOIN medium mediums ON mediums.id = tracks.medium')
    .joins('JOIN release releases ON releases.id = mediums.release')
    .joins('JOIN release_group release_groups ON release_groups.id = releases.release_group')
    .joins('JOIN release_group_meta release_group_meta ON release_group_meta.id = release_groups.id')
    .joins('JOIN artist_credit_name artist_credit_names ON artist_credit_names.artist_credit = recording.artist_credit')
    .where('artist_credit_names.artist = ?', artist_id)
  end

  def self.release_date_sql
    <<-SQL
      CASE
        WHEN release_group_meta.first_release_date_year IS NOT NULL
             AND release_group_meta.first_release_date_month IS NOT NULL
             AND release_group_meta.first_release_date_day IS NOT NULL
        THEN make_date(
            release_group_meta.first_release_date_year,
            release_group_meta.first_release_date_month,
            release_group_meta.first_release_date_day
        )
        WHEN release_group_meta.first_release_date_year IS NOT NULL
             AND release_group_meta.first_release_date_month IS NOT NULL
        THEN make_date(
            release_group_meta.first_release_date_year,
            release_group_meta.first_release_date_month,
            1
        )
        WHEN release_group_meta.first_release_date_year IS NOT NULL
        THEN make_date(
            release_group_meta.first_release_date_year,
            1,
            1
        )
      END as first_release_date
    SQL
  end

  def self.row_number_sql(direction)
    <<-SQL
      ROW_NUMBER() OVER (
        PARTITION BY recordings.id
        ORDER BY
          release_group_meta.first_release_date_year #{direction} NULLS LAST,
          release_group_meta.first_release_date_month #{direction} NULLS LAST,
          release_group_meta.first_release_date_day #{direction} NULLS LAST
      ) as rn
    SQL
  end


  class ActiveMusicbrainz::Model::Artist
    def recordings_with_release_date
      ActiveMusicbrainz::Model::Recording.releases_for_artist(id)
    end
  end

  class ActiveMusicbrainz::Model::Recording
    def self.with_first_release_date
      select('recording.id as recording_id, RECORDINGS_FIRST_RELEASE_DATE.first_release_date as frd').joins("INNER JOIN (#{with_first_release_date_subquery.to_sql}) RECORDINGS_FIRST_RELEASE_DATE ON RECORDINGS_FIRST_RELEASE_DATE.RECORDING_ID = recording.id")
    end

    def self.with_first_release_date_subquery
      select('recording.id AS recording_id, MIN(
        CASE
          WHEN release_group_meta.first_release_date_month IS NOT NULL
              AND release_group_meta.first_release_date_day IS NOT NULL THEN make_date(
            release_group_meta.first_release_date_year,
            release_group_meta.first_release_date_month,
            release_group_meta.first_release_date_day
          )
          WHEN release_group_meta.first_release_date_month IS NOT NULL THEN make_date(
            release_group_meta.first_release_date_year,
            release_group_meta.first_release_date_month,
            1
          )
          WHEN release_group_meta.first_release_date_year IS NOT NULL THEN make_date(release_group_meta.first_release_date_year, 1, 1)
        END
      ) AS first_release_date')
      .joins(tracks: { medium: { release: { release_group: :release_group_meta } } })
      .joins(:artist_credit_names)
      .where('release_group_meta.first_release_date_year IS NOT NULL')
      .group('recording.id')
    end
  end
end
