# frozen_string_literal: true
class ArtistsController < ApplicationController
  def show
    @mb_artist = ActiveMusicbrainz::Model::Artist.find_by(gid: params[:id])
    raise Discourse::NotFound unless @mb_artist

    render json: MusicBrainz::Artist.new(@mb_artist)
  end

  def recordings
    @mb_artist = ActiveMusicbrainz::Model::Artist.find_by(gid: params[:id])
    raise Discourse::NotFound unless @mb_artist

    render json: ActiveModel::ArraySerializer.new(@mb_artist.recordings, each_serializer: MusicBrainz::Recording)
  end
end
