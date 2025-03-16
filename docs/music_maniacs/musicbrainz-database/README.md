object explorer:

musicbrainz
  musicbrainz
    musicbrainz_db
      schemas: musicbrainz


data dumps:

https://data.metabrainz.org/pub/musicbrainz/data/


materialized tables:

for example for first recording recording release
    4.  Build materialized tables (optional but recommended)
        <a name="build-materialized-tables"></a>

        MusicBrainz Server makes use of materialized (or denormalized) tables in
        production to improve the performance of certain pages and features. These
        tables duplicate primary table data and can take up several additional
        gigabytes of space, so they're optional but recommended. If you don't populate
        these tables, we'll generally fall back to slower queries in their place.

        In order to build them initially, run the following script:

            ./admin/BuildMaterializedTables --database=MAINTENANCE all

        Once this is done, the tables will be kept up-to-date automatically via
        triggers. (This is true even on replicated mirrors. Generally, triggers
        are not created on mirrors, but since these materialized tables aren't
        replicated, we install a set of mirror-only triggers to manage them.)

