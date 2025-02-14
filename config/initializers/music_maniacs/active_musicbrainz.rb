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

class ActiveMusicbrainz::Model::Artist
  def recordings_with_release_date
    recordings.with_first_release_date
  end
end

class ActiveMusicbrainz::Model::RecordingFirstReleaseDate
  belongs_to :recording, foreign_key: :recording
end

class ActiveMusicbrainz::Model::RecordingMeta
  belongs_to :recording, foreign_key: :id
end

class ActiveMusicbrainz::Model::Recording
  has_one :recording_first_release_date, foreign_key: :recording
  has_one :recording_meta, foreign_key: :id

  scope :order_by_first_release_date, -> (direction = :desc) {
    joins(:recording_first_release_date)
      .order("recording_first_release_date.year #{direction} NULLS LAST, recording_first_release_date.month #{direction} NULLS LAST, recording_first_release_date.day #{direction} NULLS LAST")
  }

  scope :order_by_rating, -> (direction = :desc) {
    joins(:recording_meta).order("recording_meta.rating #{direction} nulls last")
  }

  def self.bayessian_rating_average
    m = all.average(:rating)
    c = 100
  end

  scope :order_by_bayesian_average, -> (direction = :desc) {
    overall_avg_rating = ActiveMusicbrainz::Model::RecordingMeta.average(:rating)
    avg_num_votes = ActiveMusicbrainz::Model::RecordingMeta.average(:rating_count)
    joins(:recording_meta)
      .select('recordings.*, recording_meta.*, ((? * ?) + (recording_meta.rating * recording_meta.rating_count)) / (? + recording_meta.rating_count) AS bayesian_average', avg_num_votes, overall_avg_rating, avg_num_votes)
      .order("bayesian_average #{direction} NULLS LAST")
  }

  def first_release_date
    return recording_first_release_date if recording_first_release_date.present?

    first_release_date_query.first
  end

  def first_release_date_query
    ActiveMusicbrainz::Model::Track.select('DISTINCT ON (track.recording) track.recording, rd.date_year AS year, rd.date_month AS month, rd.date_day AS day')
                                   .joins(:medium)
                                   .joins("LEFT JOIN (
                                     SELECT release, date_year, date_month, date_day FROM release_country
                                     UNION ALL
                                     SELECT release, date_year, date_month, date_day FROM release_unknown_country
                                   ) rd ON rd.release = medium.release")
                                   .where(recording: id)
                                   .order('track.recording, rd.date_year NULLS LAST, rd.date_month NULLS LAST, rd.date_day NULLS LAST')
  end

  # def self.with_first_release_date_selected
  #   select('recording.*, RECORDINGS_FIRST_RELEASE_DATE.first_release_date as frd')
  #   .joins("INNER JOIN (#{with_first_release_date_subquery.to_sql}) RECORDINGS_FIRST_RELEASE_DATE ON RECORDINGS_FIRST_RELEASE_DATE.RECORDING_ID = recording.id")
  # end
  #
  # def self.with_first_release_date
  #   joins("INNER JOIN (#{with_first_release_date_subquery.to_sql}) RECORDINGS_FIRST_RELEASE_DATE ON RECORDINGS_FIRST_RELEASE_DATE.RECORDING_ID = recording.id")
  #   .order('RECORDINGS_FIRST_RELEASE_DATE.first_release_date desc')
  # end
  #
  # def self.with_first_release_date_subquery
  #   select('recording.id AS recording_id, MIN(
  #     CASE
  #       WHEN release_group_meta.first_release_date_month IS NOT NULL
  #           AND release_group_meta.first_release_date_day IS NOT NULL THEN make_date(
  #         release_group_meta.first_release_date_year,
  #         release_group_meta.first_release_date_month,
  #         release_group_meta.first_release_date_day
  #       )
  #       WHEN release_group_meta.first_release_date_month IS NOT NULL THEN make_date(
  #         release_group_meta.first_release_date_year,
  #         release_group_meta.first_release_date_month,
  #         1
  #       )
  #       WHEN release_group_meta.first_release_date_year IS NOT NULL THEN make_date(release_group_meta.first_release_date_year, 1, 1)
  #     END
  #   ) AS first_release_date')
  #   .joins(tracks: { medium: { release: { release_group: :release_group_meta } } })
  #   .joins(:artist_credit_names)
  #   .where('release_group_meta.first_release_date_year IS NOT NULL')
  #   .group('recording.id')
  # end
end
