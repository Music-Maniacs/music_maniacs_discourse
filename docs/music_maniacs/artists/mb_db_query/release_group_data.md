release_group_data AS (
              SELECT a.gid AS artist_mbid
                   , rg.gid::TEXT AS release_group_mbid
                   , rg.name AS release_group_name
                   , ac.name AS artist_credit_name
                   , rgca.caa_id AS caa_id
                   , rgca.caa_release_mbid::TEXT AS caa_release_mbid
                   , (rgm.first_release_date_year::TEXT || '-' ||
                       LPAD(rgm.first_release_date_month::TEXT, 2, '0') || '-' ||
                       LPAD(rgm.first_release_date_day::TEXT, 2, '0')) AS date
                   , rgpt.name AS type
                   , jsonb_agg(jsonb_build_object(
                          'artist_mbid', a2.gid::TEXT,
                          'artist_credit_name', a2.name,
                          'join_phrase', acn2.join_phrase
                     ) ORDER BY acn2.position) AS release_group_artists
                FROM musicbrainz.artist a
                JOIN musicbrainz.artist_credit_name acn
                  ON a.id = acn.artist
                JOIN musicbrainz.artist_credit ac
                  ON acn.artist_credit = ac.id
                JOIN musicbrainz.release_group rg
                  ON ac.id = rg.artist_credit
                JOIN musicbrainz.release_group_meta rgm
                  ON rgm.id = rg.id
           LEFT JOIN musicbrainz.release_group_primary_type rgpt
                  ON rg.type = rgpt.id
           LEFT JOIN rg_cover_art rgca
                  ON rgca.release_group = rg.id
                JOIN musicbrainz.artist_credit_name acn2
                  ON rg.artist_credit = acn2.artist_credit
                JOIN musicbrainz.artist a2
                  ON acn2.artist = a2.id
            GROUP BY a.gid
                   , rg.gid
                   , rg.name
                   , ac.name
                   , rgca.caa_id
                   , rgca.caa_release_mbid
                   , rgpt.name
                   , rgm.first_release_date_year
                   , rgm.first_release_date_month
                   , rgm.first_release_date_day
     )


rg = ReleaseGroup
a = Artist
acn = ArtistCreditName
ac = ArtistCredit
rgm = ReleaseGroupMeta
rgpt = ReleaseGroupPrimaryType
rgca = RG_CoverArt
j

release_group_data AS (
              SELECT a.gid AS artist_mbid
                   , rg.gid::TEXT AS release_group_mbid
                   , rg.name AS release_group_name
                   , ac.name AS artist_credit_name
                   , rgca.caa_id AS caa_id
                   , rgca.caa_release_mbid::TEXT AS caa_release_mbid
                   , (rgm.first_release_date_year::TEXT || '-' ||
                       LPAD(rgm.first_release_date_month::TEXT, 2, '0') || '-' ||
                       LPAD(rgm.first_release_date_day::TEXT, 2, '0')) AS date
                   , rgpt.name AS type
                   , jsonb_agg(jsonb_build_object(
                          'artist_mbid', a2.gid::TEXT,
                          'artist_credit_name', a2.name,
                          'join_phrase', acn2.join_phrase
                     ) ORDER BY acn2.position) AS release_group_artists
                FROM musicbrainz.artist a
                JOIN musicbrainz.artist_credit_name acn
                  ON a.id = acn.artist
                JOIN musicbrainz.artist_credit ac
                  ON acn.artist_credit = ac.id
                JOIN musicbrainz.release_group rg
                  ON ac.id = rg.artist_credit
                JOIN musicbrainz.release_group_meta rgm
                  ON rgm.id = rg.id
           LEFT JOIN musicbrainz.release_group_primary_type rgpt
                  ON rg.type = rgpt.id
           LEFT JOIN rg_cover_art rgca
                  ON rgca.release_group = rg.id
                JOIN musicbrainz.artist_credit_name acn2
                  ON rg.artist_credit = acn2.artist_credit
                JOIN musicbrainz.artist a2
                  ON acn2.artist = a2.id
            GROUP BY a.gid
                   , rg.gid
                   , rg.name
                   , ac.name
                   , rgca.caa_id
                   , rgca.caa_release_mbid
                   , rgpt.name
                   , rgm.first_release_date_year
                   , rgm.first_release_date_month
                   , rgm.first_release_date_day
     )


release_group_data = AMBM::Artist
.joins(artist_credit_name: { artist_credit: { release_groups: [:artist_credit_names]} })
.joins('LEFT JOIN release_group_primary_type rgpt ON release_group.type = rgpt.id')
.joins('JOIN release_group_meta rgm ON release_group.id = rgm.id')
.joins('JOIN artist_credit_name acn2 ON release_group.artist_credit = acn2.artist_credit')
.joins('JOIN musicbrainz.artist a2 ON acn2.artist = a2.id')
.select(selects.join(','))
.group(group_by)


selects = ["artist.gid as artist_mbid",
 "release_group.gid::TEXT AS release_group_mbid",
 "release_group.name AS release_group_name",
 "artist_credit.name AS artist_credit_name",
 "(rgm.first_release_date_year::TEXT || '-' ||\n                                     LPAD(rgm.first_release_date_month::TEXT, 2, '0')|| '-' ||\n                                     LPAD(rgm.first_release_date_day::TEXT, 2, '0')) AS date",
 "rgpt.name AS type",
 "jsonb_agg(jsonb_build_object(\n    'artist_mbid', a2.gid::TEXT,\n                                      'artist_credit_name', a2.name,\n                                      'join_phrase', acn2.join_phrase\n                                    ) ORDER BY acn2.position) AS release_group_artists"]

 group_by = "artist.gid,\n                                   release_group.gid,\n                                   release_group.name,\n                             artist_credit.name,\n                                   rgpt.name,\n                                   rgm.first_release_date_year,\n                                   rgm.first_release_date_month,\n                                   rgm.first_release_date_day"
