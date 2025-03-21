# frozen_string_literal: true

module MusicBrainz
  class Recording < ApplicationSerializer
    attributes :name, :length, :canonical_release_mbid, :artist_name, :artist_credits

    def artist_name
      "the beatles"
    end

    def artist_credits
     [{"artist_mbid"=>"d770374d-05e9-4ed3-a068-3fbd4e6e4dd6", "artist_credit_name"=>"Wiener Philharmoniker", "join_phrase"=>""},
     {"artist_mbid"=>"e38bb7a2-c3e5-4be2-894b-7078c40b9955", "artist_credit_name"=>"Lorin Maazel", "join_phrase"=>" "}]
    end
  end
end
