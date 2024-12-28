# frozen_string_literal: true

module MusicBrainz
  class Artist < ApplicationSerializer
    class LArtistUrl < ApplicationSerializer

      attributes :name, :url
      def name
        object.link.link_type.name
      end

      def url
        object.url.url
      end
    end

    attributes :name,
               :begin_date_year,
               :end_date_year

    has_many :rels, serializer: LArtistUrl, embed: :objects

    def area
      object.area&.name
    end

    def rels
      object.l_artist_urls.joins({ link: :link_type }).joins(:url)
    end
  end
end
