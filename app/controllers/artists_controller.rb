# frozen_string_literal: true
class ArtistsController < ApplicationController
  def show
    @mb_artist = ActiveMusicbrainz::Model::Artist.find_by!(gid: params[:id])
    raise Discourse::NotFound unless @mb_artist

    render json: MusicBrainz::Artist.new(@mb_artist)
  end

  # release_group: name, data, cover_art, listens?
  def new_show

  end
end
