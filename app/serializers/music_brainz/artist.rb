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

    class Tag < ApplicationSerializer
      attributes :name, :count

      def name
        object.tag.name
      end

      def count
        object.count
      end
    end

    class Genre < Tag
      attributes :genre_id

      def genre_id
        object.tag.genre.gid
      end
    end

    attributes :id,
               :name,
               :begin_year,
               :end_year,
               :area

    has_many :rels, serializer: Link, embed: :objects
    has_many :tags, serializer: Tag, embed: :objects
    has_many :genres, serializer: Genre, embed: :objects

    def id
      object.gid
    end

    def area
      object.area&.name
    end

    def begin_year
      object.begin_date_year
    end

    def end_year
      object.end_date_year
    end

    def rels
      object.l_artist_urls.joins({ link: :link_type }).joins(:url)
    end

    def tags
      object.only_tags
    end

    def genres
      object.only_genres
    end
  end
end
