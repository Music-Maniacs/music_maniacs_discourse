# frozen_string_literal: true

module MusicBrainz
  class Artist < ApplicationSerializer
    class Link < ApplicationSerializer

      attributes :name, :url
      def name
        object.link.link_type.name
      end

      def url
        object.url.url
      end
    end

    attributes :name,
               :begin_year,
               :end_year,
               :area

    has_many :rels, serializer: Link, embed: :objects

    def area
      object.area&.name
    end

    def begin_year
      object.begin_date_year
    end

    def end_year
      object.begin_date_year
    end

    def rels
      object.l_artist_urls.joins({ link: :link_type }).joins(:url)
    end
  end
end
