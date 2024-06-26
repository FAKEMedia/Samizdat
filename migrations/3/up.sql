-- Diff code generated with pgModeler (PostgreSQL Database Modeler)
-- pgModeler version: 0.9.4
-- Diff date: 2024-05-23 21:48:53
-- Source model: samizdat
-- Database: samizdat
-- PostgreSQL version: 13.0

-- [ Diff summary ]
-- Dropped objects: 0
-- Created objects: 37
-- Changed objects: 0

SET search_path = public,pg_catalog,web;
-- ddl-end --


-- [ Created objects ] --
-- object: web | type: SCHEMA --
-- DROP SCHEMA IF EXISTS web CASCADE;
CREATE SCHEMA web;
-- ddl-end --
ALTER SCHEMA web OWNER TO samizdat;
-- ddl-end --

-- object: web.resources | type: TABLE --
-- DROP TABLE IF EXISTS web.resources CASCADE;
CREATE TABLE web.resources
(
  resourceid    BIGINT                   NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  alias         CHARACTER VARYING        NOT NULL DEFAULT '',
  title         CHARACTER VARYING(191)   NOT NULL DEFAULT '',
  description   CHARACTER VARYING        NOT NULL DEFAULT '',
  content       TEXT                     NOT NULL DEFAULT '',
  owner         BIGINT                   NOT NULL,
  creator       BIGINT,
  publisher     BIGINT,
  parentid      BIGINT,
  resourcealias BIGINT,
  contenttype   INTEGER                  NOT NULL DEFAULT 1,
  languageid    INTEGER                  NOT NULL,
  created       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  modified      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  published     TIMESTAMP WITH TIME ZONE,
  comments      INTEGER                  NOT NULL DEFAULT 0,
  templateid    INTEGER                  NOT NULL,
  webserviceid  BIGINT                   NOT NULL,
  CONSTRAINT resources_pk PRIMARY KEY (resourceid)
);
-- ddl-end --
COMMENT ON COLUMN web.resources.resourcealias IS E'Självreferens';
-- ddl-end --
ALTER TABLE web.resources
  OWNER TO samizdat;
-- ddl-end --

-- object: web.menuitems | type: TABLE --
-- DROP TABLE IF EXISTS web.menuitems CASCADE;
CREATE TABLE web.menuitems
(
  menuitemid INTEGER  NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  parentid   INTEGER,
  "position" SMALLINT NOT NULL DEFAULT 0,
  uriid      INTEGER,
  menuid     INTEGER  NOT NULL,
  children   INTEGER  NOT NULL DEFAULT 0,
  CONSTRAINT menuitems_pk PRIMARY KEY (menuitemid)
);
-- ddl-end --
ALTER TABLE web.menuitems
  OWNER TO samizdat;
-- ddl-end --

-- object: web.contenttypes | type: TABLE --
-- DROP TABLE IF EXISTS web.contenttypes CASCADE;
CREATE TABLE web.contenttypes
(
  contenttypeid INTEGER               NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  name          CHARACTER VARYING     NOT NULL,
  mimetype      CHARACTER VARYING(31) NOT NULL,
  CONSTRAINT contenttypes_pk PRIMARY KEY (contenttypeid),
  CONSTRAINT mimetype_uq UNIQUE (mimetype)
);
-- ddl-end --
ALTER TABLE web.contenttypes
  OWNER TO samizdat;
-- ddl-end --

-- object: web.comments | type: TABLE --
-- DROP TABLE IF EXISTS web.comments CASCADE;
CREATE TABLE web.comments
(
  commentid  BIGINT                   NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  parentid   BIGINT,
  resourceid BIGINT                   NOT NULL,
  created    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  CONSTRAINT comments_pk PRIMARY KEY (commentid)
);
-- ddl-end --
ALTER TABLE web.comments
  OWNER TO samizdat;
-- ddl-end --

-- object: web.menus | type: TABLE --
-- DROP TABLE IF EXISTS web.menus CASCADE;
CREATE TABLE web.menus
(
  menuid       INTEGER           NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  name         CHARACTER VARYING NOT NULL DEFAULT '',
  webserviceid BIGINT            NOT NULL,
  CONSTRAINT menus_pk PRIMARY KEY (menuid),
  CONSTRAINT menu_name_uq UNIQUE (name)
);
-- ddl-end --
ALTER TABLE web.menus
  OWNER TO samizdat;
-- ddl-end --

-- object: web.uris | type: TABLE --
-- DROP TABLE IF EXISTS web.uris CASCADE;
CREATE TABLE web.uris
(
  uriid      BIGINT            NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  path       CHARACTER VARYING NOT NULL DEFAULT '',
  resourceid BIGINT,
  CONSTRAINT uris_pk PRIMARY KEY (uriid),
  CONSTRAINT uri_path_uq UNIQUE (path)
);
-- ddl-end --
ALTER TABLE web.uris
  OWNER TO samizdat;
-- ddl-end --

-- object: web.contexts | type: TABLE --
-- DROP TABLE IF EXISTS web.contexts CASCADE;
CREATE TABLE web.contexts
(
  contextid INTEGER           NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  name      CHARACTER VARYING NOT NULL,
  CONSTRAINT contexts_pk PRIMARY KEY (contextid),
  CONSTRAINT context_name_uq UNIQUE (name)
);
-- ddl-end --
ALTER TABLE web.contexts
  OWNER TO samizdat;
-- ddl-end --

-- object: web.settings | type: TABLE --
-- DROP TABLE IF EXISTS web.settings CASCADE;
CREATE TABLE web.settings
(
  settingid INTEGER           NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  key       CHARACTER VARYING NOT NULL,
  value     CHARACTER VARYING NOT NULL,
  title     VARCHAR(191)      NOT NULL,
  CONSTRAINT settings_pk PRIMARY KEY (settingid),
  CONSTRAINT setting_key_uq UNIQUE (key)
);
-- ddl-end --
ALTER TABLE web.settings
  OWNER TO samizdat;
-- ddl-end --

-- object: web.templates | type: TABLE --
-- DROP TABLE IF EXISTS web.templates CASCADE;
CREATE TABLE web.templates
(
  templateid INTEGER           NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  path       CHARACTER VARYING NOT NULL DEFAULT 'default.html.ep',
  CONSTRAINT templates_pk PRIMARY KEY (templateid),
  CONSTRAINT template_path_uq UNIQUE (path)
);
-- ddl-end --
ALTER TABLE web.templates
  OWNER TO samizdat;
-- ddl-end --

-- object: web.menuitemtitles | type: TABLE --
-- DROP TABLE IF EXISTS web.menuitemtitles CASCADE;
CREATE TABLE web.menuitemtitles
(
  menuitemtitles INTEGER      NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  title          VARCHAR(191) NOT NULL,
  menuitemid     INTEGER,
  languageid     INTEGER      NOT NULL DEFAULT 1,
  CONSTRAINT menuitemtitles_pk PRIMARY KEY (menuitemtitles)
);
-- ddl-end --
ALTER TABLE web.menuitemtitles
  OWNER TO samizdat;
-- ddl-end --

-- object: web.webservices | type: TABLE --
-- DROP TABLE IF EXISTS web.webservices CASCADE;
CREATE TABLE web.webservices
(
  webserviceid  BIGINT NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  path          TEXT   NOT NULL,
  primarydomain BIGINT,
  CONSTRAINT webservices_pk PRIMARY KEY (webserviceid)
);
-- ddl-end --
ALTER TABLE web.webservices
  OWNER TO samizdat;
-- ddl-end --

-- object: web.domains | type: TABLE --
-- DROP TABLE IF EXISTS web.domains CASCADE;
CREATE TABLE web.domains
(
  domainid     BIGINT       NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  webserviceid BIGINT       NOT NULL,
  domainname   VARCHAR(191) NOT NULL,
  CONSTRAINT domains_pk PRIMARY KEY (domainid),
  CONSTRAINT domainname_uq UNIQUE (domainname)
);
-- ddl-end --
ALTER TABLE web.domains
  OWNER TO samizdat;
-- ddl-end --

-- object: resources_webserviceid_idx | type: INDEX --
-- DROP INDEX IF EXISTS web.resources_webserviceid_idx CASCADE;
CREATE INDEX resources_webserviceid_idx ON web.resources
  USING btree
  (
   webserviceid
    )
  INCLUDE (webserviceid);
-- ddl-end --

-- object: menuitems_menuid_idx | type: INDEX --
-- DROP INDEX IF EXISTS web.menuitems_menuid_idx CASCADE;
CREATE INDEX menuitems_menuid_idx ON web.menuitems
  USING btree
  (
   menuid
    )
  INCLUDE (menuid);
-- ddl-end --

-- object: comments_resourceid_idx | type: INDEX --
-- DROP INDEX IF EXISTS web.comments_resourceid_idx CASCADE;
CREATE INDEX comments_resourceid_idx ON web.comments
  USING btree
  (
   resourceid
    )
  INCLUDE (resourceid);
-- ddl-end --

-- object: resources_languageid_idx | type: INDEX --
-- DROP INDEX IF EXISTS web.resources_languageid_idx CASCADE;
CREATE INDEX resources_languageid_idx ON web.resources
  USING btree
  (
   languageid
    )
  INCLUDE (languageid);
-- ddl-end --


-- [ Created foreign keys ] --
-- object: languages_fk | type: CONSTRAINT --
-- ALTER TABLE web.resources DROP CONSTRAINT IF EXISTS languages_fk CASCADE;
ALTER TABLE web.resources
  ADD CONSTRAINT languages_fk FOREIGN KEY (languageid)
    REFERENCES public.languages (languageid) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: templates_fk | type: CONSTRAINT --
-- ALTER TABLE web.resources DROP CONSTRAINT IF EXISTS templates_fk CASCADE;
ALTER TABLE web.resources
  ADD CONSTRAINT templates_fk FOREIGN KEY (templateid)
    REFERENCES web.templates (templateid) MATCH FULL
    ON DELETE RESTRICT ON UPDATE RESTRICT;
-- ddl-end --

-- object: parent_fk | type: CONSTRAINT --
-- ALTER TABLE web.resources DROP CONSTRAINT IF EXISTS parent_fk CASCADE;
ALTER TABLE web.resources
  ADD CONSTRAINT parent_fk FOREIGN KEY (parentid)
    REFERENCES web.resources (resourceid) MATCH FULL
    ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: resourcealias_fk | type: CONSTRAINT --
-- ALTER TABLE web.resources DROP CONSTRAINT IF EXISTS resourcealias_fk CASCADE;
ALTER TABLE web.resources
  ADD CONSTRAINT resourcealias_fk FOREIGN KEY (resourcealias)
    REFERENCES web.resources (resourceid) MATCH FULL
    ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: contenttypes_fk | type: CONSTRAINT --
-- ALTER TABLE web.resources DROP CONSTRAINT IF EXISTS contenttypes_fk CASCADE;
ALTER TABLE web.resources
  ADD CONSTRAINT contenttypes_fk FOREIGN KEY (contenttype)
    REFERENCES web.contenttypes (contenttypeid) MATCH FULL
    ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: owner_fk | type: CONSTRAINT --
-- ALTER TABLE web.resources DROP CONSTRAINT IF EXISTS owner_fk CASCADE;
ALTER TABLE web.resources
  ADD CONSTRAINT owner_fk FOREIGN KEY (owner)
    REFERENCES account.users (userid) MATCH FULL
    ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: creator_fk | type: CONSTRAINT --
-- ALTER TABLE web.resources DROP CONSTRAINT IF EXISTS creator_fk CASCADE;
ALTER TABLE web.resources
  ADD CONSTRAINT creator_fk FOREIGN KEY (creator)
    REFERENCES account.users (userid) MATCH FULL
    ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: publisher_fk | type: CONSTRAINT --
-- ALTER TABLE web.resources DROP CONSTRAINT IF EXISTS publisher_fk CASCADE;
ALTER TABLE web.resources
  ADD CONSTRAINT publisher_fk FOREIGN KEY (publisher)
    REFERENCES account.users (userid) MATCH FULL
    ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: uris_fk | type: CONSTRAINT --
-- ALTER TABLE web.menuitems DROP CONSTRAINT IF EXISTS uris_fk CASCADE;
ALTER TABLE web.menuitems
  ADD CONSTRAINT uris_fk FOREIGN KEY (uriid)
    REFERENCES web.uris (uriid) MATCH FULL
    ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: menus_fk | type: CONSTRAINT --
-- ALTER TABLE web.menuitems DROP CONSTRAINT IF EXISTS menus_fk CASCADE;
ALTER TABLE web.menuitems
  ADD CONSTRAINT menus_fk FOREIGN KEY (menuid)
    REFERENCES web.menus (menuid) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: parent_fk | type: CONSTRAINT --
-- ALTER TABLE web.menuitems DROP CONSTRAINT IF EXISTS parent_fk CASCADE;
ALTER TABLE web.menuitems
  ADD CONSTRAINT parent_fk FOREIGN KEY (parentid)
    REFERENCES web.menuitems (menuitemid) MATCH FULL
    ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: resources_fk | type: CONSTRAINT --
-- ALTER TABLE web.comments DROP CONSTRAINT IF EXISTS resources_fk CASCADE;
ALTER TABLE web.comments
  ADD CONSTRAINT resources_fk FOREIGN KEY (resourceid)
    REFERENCES web.resources (resourceid) MATCH FULL
    ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: parent_fk | type: CONSTRAINT --
-- ALTER TABLE web.comments DROP CONSTRAINT IF EXISTS parent_fk CASCADE;
ALTER TABLE web.comments
  ADD CONSTRAINT parent_fk FOREIGN KEY (parentid)
    REFERENCES web.comments (commentid) MATCH FULL
    ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: resources_fk | type: CONSTRAINT --
-- ALTER TABLE web.uris DROP CONSTRAINT IF EXISTS resources_fk CASCADE;
ALTER TABLE web.uris
  ADD CONSTRAINT resources_fk FOREIGN KEY (resourceid)
    REFERENCES web.resources (resourceid) MATCH FULL
    ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: menuitems_fk | type: CONSTRAINT --
-- ALTER TABLE web.menuitemtitles DROP CONSTRAINT IF EXISTS menuitems_fk CASCADE;
ALTER TABLE web.menuitemtitles
  ADD CONSTRAINT menuitems_fk FOREIGN KEY (menuitemid)
    REFERENCES web.menuitems (menuitemid) MATCH SIMPLE
    ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: languages_fk | type: CONSTRAINT --
-- ALTER TABLE web.menuitemtitles DROP CONSTRAINT IF EXISTS languages_fk CASCADE;
ALTER TABLE web.menuitemtitles
  ADD CONSTRAINT languages_fk FOREIGN KEY (languageid)
    REFERENCES public.languages (languageid) MATCH SIMPLE
    ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: webservices_fk | type: CONSTRAINT --
-- ALTER TABLE web.resources DROP CONSTRAINT IF EXISTS webservices_fk CASCADE;
ALTER TABLE web.resources
  ADD CONSTRAINT webservices_fk FOREIGN KEY (webserviceid)
    REFERENCES web.webservices (webserviceid) MATCH SIMPLE
    ON DELETE SET NULL ON UPDATE NO ACTION;
-- ddl-end --

-- object: webservices_fk | type: CONSTRAINT --
-- ALTER TABLE web.domains DROP CONSTRAINT IF EXISTS webservices_fk CASCADE;
ALTER TABLE web.domains
  ADD CONSTRAINT webservices_fk FOREIGN KEY (webserviceid)
    REFERENCES web.webservices (webserviceid) MATCH SIMPLE
    ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE INITIALLY DEFERRED;
-- ddl-end --

-- object: primarydomain_fk | type: CONSTRAINT --
-- ALTER TABLE web.webservices DROP CONSTRAINT IF EXISTS primarydomain_fk CASCADE;
ALTER TABLE web.webservices
  ADD CONSTRAINT primarydomain_fk FOREIGN KEY (primarydomain)
    REFERENCES web.domains (domainid) MATCH SIMPLE
    ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE INITIALLY DEFERRED;
-- ddl-end --

-- object: webservices_fk | type: CONSTRAINT --
-- ALTER TABLE web.menus DROP CONSTRAINT IF EXISTS webservices_fk CASCADE;
ALTER TABLE web.menus
  ADD CONSTRAINT webservices_fk FOREIGN KEY (webserviceid)
    REFERENCES web.webservices (webserviceid) MATCH SIMPLE
    ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE INITIALLY IMMEDIATE;
-- ddl-end --


INSERT INTO web.contenttypes(contenttypeid, name, mimetype)
VALUES
  (1, 'Document', 'text/html');
INSERT INTO web.templates (templateid, path)
VALUES
  (1, 'index.html.ep');
INSERT INTO web.domains (domainid, webserviceid, domainname) VALUES (1, 1, 'example.com');
INSERT INTO web.webservices (webserviceid, path, primarydomain) VALUES (1, '/tmp/example.com', 1);
INSERT INTO web.menus (menuid, webserviceid, name)
VALUES
  (1, 1, 'Default top navigation');
INSERT INTO web.uris (uriid, path)
VALUES
  (1, '');
INSERT INTO web.uris (uriid, path)
VALUES
  (2, '/contact');
INSERT INTO web.menuitems(menuitemid, parentid, position, uriid, menuid, children)
VALUES
  (1, NULL, 1, 1, 1, 0);
INSERT INTO web.menuitems(menuitemid, parentid, position, uriid, menuid, children)
VALUES
  (2, 1, 1, 2, 1, 0);
INSERT INTO web.menuitemtitles (title, menuitemid, languageid)
VALUES
  ('Home', 1, 1);
INSERT INTO web.menuitemtitles (title, menuitemid, languageid)
VALUES
  ('Contact', 2, 1);
INSERT INTO web.resources (resourceid, alias, title, description, content, owner, creator, publisher, parentid,
                           resourcealias, contenttype, languageid, published, comments, templateid, webserviceid)
VALUES
  (1, 'success', 'Success', 'The Samidat installation was a great success.',
   'See the documentation about how this works.', 0, 0, 0, NULL, NULL, 1, 1, NOW(), 0, 1, 1);

INSERT INTO web.resources (resourceid, alias, title, description, content, owner, creator, publisher, parentid,
                           resourcealias, contenttype, languageid, published, comments, templateid, webserviceid)
VALUES
  (2, 'lorsita', 'Lorem Ipsum do lorsita', 'Some lore mips umdo lors, it am et', '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse porta ante eget purus tincidunt bibendum. Quisque sagittis elit arcu, ac imperdiet eros cursus vitae. Quisque ut semper turpis, vitae cursus sapien. Fusce bibendum aliquet felis vel convallis. Praesent purus nunc, ultricies id odio eget, rutrum placerat nunc. Nulla varius imperdiet hendrerit. Pellentesque lacinia purus vel ex pretium laoreet. Vivamus luctus, sapien sagittis volutpat vehicula, enim nunc laoreet ligula, quis hendrerit nisi eros convallis nibh. Nullam quis libero urna. Phasellus venenatis urna ac quam dapibus, vel faucibus tortor faucibus. Curabitur id rutrum ligula, eu rutrum arcu. Quisque imperdiet aliquet risus scelerisque fermentum. Fusce varius libero quis tempor suscipit. Mauris at interdum massa.</p>
<p>Aliquam erat volutpat. Donec gravida tellus nec vestibulum ultrices. Integer ac laoreet nunc. Donec mi augue, pellentesque et nisl sit amet, pellentesque bibendum urna. Curabitur iaculis dui neque, eu ultrices ante interdum ut. Nullam volutpat nisi ac nisi tempus facilisis. Fusce ut nisl euismod, aliquet velit in, maximus augue.</p>
<p>Nulla luctus est id mauris sagittis, et faucibus libero pretium. Nulla faucibus, orci vitae luctus euismod, massa nulla venenatis odio, a tempor erat ligula non leo. Ut bibendum imperdiet arcu nec pharetra. Aenean egestas mi scelerisque, porta lacus suscipit, interdum orci. Donec neque justo, lobortis at ultricies aliquam, ultricies at lorem. Praesent dignissim gravida diam, condimentum euismod ante ullamcorper blandit. Suspendisse at ante quis ipsum elementum rutrum. Aenean eget metus volutpat, aliquam felis eget, commodo augue.</p>
', 0, 0, 0, NULL, NULL, 1, 1, NOW(), 0, 1, 1);

INSERT INTO web.resources (resourceid, alias, title, description, content, owner, creator, publisher, parentid,
                           resourcealias, contenttype, languageid, published, comments, templateid, webserviceid)
VALUES
  (3, 'retake', 'Another retake', 'You can delete this',
   '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse porta ante eget purus tincidunt bibendum. Quisque sagittis elit arcu, ac imperdiet eros cursus vitae. Quisque ut semper turpis, vitae cursus sapien. Fusce bibendum aliquet felis vel convallis. Praesent purus nunc, ultricies id odio eget, rutrum placerat nunc. Nulla varius imperdiet hendrerit. Pellentesque lacinia purus vel ex pretium laoreet. Vivamus luctus, sapien sagittis volutpat vehicula, enim nunc laoreet ligula, quis hendrerit nisi eros convallis nibh. Nullam quis libero urna. Phasellus venenatis urna ac quam dapibus, vel faucibus tortor faucibus. Curabitur id rutrum ligula, eu rutrum arcu. Quisque imperdiet aliquet risus scelerisque fermentum. Fusce varius libero quis tempor suscipit. Mauris at interdum massa.</p>
<p>Aliquam erat volutpat. Donec gravida tellus nec vestibulum ultrices. Integer ac laoreet nunc. Donec mi augue, pellentesque et nisl sit amet, pellentesque bibendum urna. Curabitur iaculis dui neque, eu ultrices ante interdum ut. Nullam volutpat nisi ac nisi tempus facilisis. Fusce ut nisl euismod, aliquet velit in, maximus augue.</p>
<p>Nulla luctus est id mauris sagittis, et faucibus libero pretium. Nulla faucibus, orci vitae luctus euismod, massa nulla venenatis odio, a tempor erat ligula non leo. Ut bibendum imperdiet arcu nec pharetra. Aenean egestas mi scelerisque, porta lacus suscipit, interdum orci. Donec neque justo, lobortis at ultricies aliquam, ultricies at lorem. Praesent dignissim gravida diam, condimentum euismod ante ullamcorper blandit. Suspendisse at ante quis ipsum elementum rutrum. Aenean eget metus volutpat, aliquam felis eget, commodo augue.</p>
', 0, 0, 0, NULL, NULL, 1, 1, NOW(), 0, 1, 1);

INSERT INTO web.settings (key, value, title)
VALUES
  ('top_menu', 1, 'Top navigation menu');
INSERT INTO web.settings (key, value, title)
VALUES
  ('show_top_menu_root', 0, 'Show top navigation root');
