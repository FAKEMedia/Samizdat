CREATE SCHEMA stats;
ALTER SCHEMA stats OWNER TO samizdat;
CREATE TABLE stats.counter
(
    id integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
    CONSTRAINT counter_pk PRIMARY KEY (id)

);
ALTER TABLE stats.counter
    OWNER TO samizdat;
CREATE TABLE stats.referrers
(
    id integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
    CONSTRAINT referrers_pk PRIMARY KEY (id)

);
ALTER TABLE stats.referrers
    OWNER TO samizdat;
CREATE TABLE stats.visitcache
(
    id integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
    CONSTRAINT visitcache_pk PRIMARY KEY (id)

);
ALTER TABLE stats.visitcache
    OWNER TO samizdat;