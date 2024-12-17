ListenBrainz query:

      WITH  artist_rels AS (
              SELECT a.gid AS artist_mbid
                   , array_agg(distinct(ARRAY[lt.name, url])) AS artist_links
                FROM musicbrainz.artist a
                JOIN musicbrainz.l_artist_url lau
                  ON lau.entity0 = a.id
                JOIN musicbrainz.url u
                  ON lau.entity1 = u.id
                JOIN musicbrainz.link l
                  ON lau.link = l.id
                JOIN musicbrainz.link_type lt
                  ON l.link_type = lt.id
                
               WHERE lt.gid IN ('99429741-f3f6-484b-84f8-23af51991770', 'fe33d22f-c3b0-4d68-bd53-a856badf2b15', '689870a4-a1e4-4912-b17f-7b2664215698', '93883cf6-e818-4938-990e-75863f8db2d3', '6f77d54e-1d81-4e1a-9ea5-37947577151b', 'e4d73442-3762-45a8-905c-401da65544ed', '611b1862-67af-4253-a64f-34adba305d1d', 'f8319a2f-f824-4617-81c8-be6560b3b203', '34ae77fe-defb-43ea-95d4-63c7540bac78', '769085a1-c2f7-4c24-a532-2375a77693bd', '63cc5d1f-f096-4c94-a43f-ecb32ea94161', '6a540e5b-58c6-4192-b6ba-dbc71ec8fcf0')
                 AND NOT l.ended
            GROUP BY a.gid
     ), artist_tags AS (
              SELECT a.gid AS artist_mbid
                   , array_agg(jsonb_build_array(t.name, count, a.gid, g.gid)) AS artist_tags
                FROM musicbrainz.artist a
                JOIN musicbrainz.artist_tag at
                  ON at.artist = a.id
                JOIN musicbrainz.tag t
                  ON at.tag = t.id
           LEFT JOIN musicbrainz.genre g
                  ON t.name = g.name
                
               WHERE count > 0
            GROUP BY a.gid
     ), rg_cover_art AS (
              SELECT DISTINCT ON(rg.id)
                     rg.id AS release_group
                   , caa_rel.gid::TEXT AS caa_release_mbid
                   , caa.id AS caa_id
                FROM musicbrainz.artist a
                JOIN musicbrainz.artist_credit_name acn
                  ON a.id = acn.artist
                JOIN musicbrainz.release_group rg
                  ON acn.artist_credit = rg.artist_credit
                JOIN musicbrainz.release caa_rel
                  ON rg.id = caa_rel.release_group
           LEFT JOIN (
                    SELECT release, date_year, date_month, date_day
                      FROM musicbrainz.release_country
                 UNION ALL
                    SELECT release, date_year, date_month, date_day
                      FROM musicbrainz.release_unknown_country
                   ) re
                  ON (re.release = caa_rel.id)
           FULL JOIN cover_art_archive.release_group_cover_art rgca
                  ON rgca.release = caa_rel.id
           LEFT JOIN cover_art_archive.cover_art caa
                  ON caa.release = caa_rel.id
           LEFT JOIN cover_art_archive.cover_art_type cat
                  ON cat.id = caa.id
                
               WHERE type_id = 1
                 AND mime_type != 'application/pdf'
            ORDER BY rg.id
                   , rgca.release
                   , re.date_year
                   , re.date_month
                   , re.date_day
                   , caa.ordering
     ), release_group_data AS (
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
          -- need a second join to artist_credit_name/artist to gather other release group artists' names
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
              SELECT a.gid::TEXT AS artist_mbid
                   , a.name AS artist_name
                   , a.begin_date_year
                   , a.end_date_year
                   , at.name AS artist_type
                   , ag.name AS gender
                   , ar.name AS area
                   , artist_links
                   , artist_tags
                   , array_agg(
                          jsonb_build_array(
                              rgd.release_group_mbid,
                              rgd.release_group_name,
                              rgd.artist_credit_name,
                              rgd.date,
                              rgd.type,
                              rgd.release_group_artists,
                              rgd.caa_id,
                              rgd.caa_release_mbid
                          ) ORDER BY rgd.date
                     )
                      -- if the artist has no release groups, left join will cause a NULL row to be
                      -- added to the array, filter ensures that it is removed
                      FILTER (WHERE rgd.release_group_mbid IS NOTNULL) AS release_groups
                FROM musicbrainz.artist a
           LEFT JOIN musicbrainz.artist_type at
                  ON a.type = at.id
           LEFT JOIN musicbrainz.gender ag
                  ON a.gender = ag.id
           LEFT JOIN musicbrainz.area ar
                  ON a.area = ar.id
           LEFT JOIN artist_rels arl
                  ON arl.artist_mbid = a.gid
           LEFT JOIN artist_tags ats
                  ON ats.artist_mbid = a.gid
           LEFT JOIN release_group_data rgd
                  ON rgd.artist_mbid = a.gid
                
            GROUP BY a.gid
                   , a.name
                   , a.begin_date_year
                   , a.end_date_year
                   , at.name
                   , ag.name
                   , ar.name
                   , artist_links
                   , artist_tags
rows: 
[x] "artist_mbid" -> artist.gid
[x] "artist_name" -> artist.name
[x] "begin_date_year" -> artist.begin_date_year
[x] "end_date_year" -> artist.end_date_year
[x] "artist_type" -> artist.type.name
[x] "gender" -> artist.gender.name
,"area"
,"artist_links"
,"artist_tags"
,"release_groups"



