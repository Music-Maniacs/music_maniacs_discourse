# frozen_string_literal: true
class ArtistsController < ApplicationController
  def show
    @mb_artist = ActiveMusicbrainz::Model::Artist.find_by(gid: params[:id])
    raise Discourse::NotFound unless @mb_artist

    render json: MusicBrainz::Artist.new(@mb_artist)
  end

  def top_recordings
    @mb_artist = ActiveMusicbrainz::Model::Artist.find_by(gid: params[:id])
    raise Discourse::NotFound unless @mb_artist

    recordings = @mb_artist.recordings
    recordings = apply_ordering(recordings)
    render json: ActiveModel::ArraySerializer.new(@mb_artist.recordings, each_serializer: MusicBrainz::Recording)
  end

  def recordings
    @mb_artist = ActiveMusicbrainz::Model::Artist.find_by(gid: params[:id])
    raise Discourse::NotFound unless @mb_artist

    render json: ActiveModel::ArraySerializer.new(@mb_artist.recordings, each_serializer: MusicBrainz::Recording)
  end

  private

  def apply_ordering(recordings)
    case params[:order_by]
    when 'first_release_date'
      recordings.order_by_first_release_date
    when 'rating'
      recordings.order_by_rating
    # when 'listen_count'
    #   recordings.order_by_listen_count(direction)
    else
      recordings.order_by_first_release_date
    end
  end
end
