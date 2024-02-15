---- Base app schema


-- User
CREATE TYPE user_typ AS ENUM ('Sys', 'User');

CREATE TABLE "user" (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

  username varchar(128) NOT NULL UNIQUE,
  typ user_typ NOT NULL DEFAULT 'User',

  -- Auth
  pwd varchar(256),
  pwd_salt uuid NOT NULL DEFAULT gen_random_uuid(),
  token_salt uuid NOT NULL DEFAULT gen_random_uuid(),

  -- Timestamps
  cid bigint NOT NULL,
  ctime timestamp with time zone NOT NULL,
  mid bigint NOT NULL,
  mtime timestamp with time zone NOT NULL  
);

-- Agent

CREATE TABLE agent (
  -- PK
  id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

  -- FKs
  owner_id BIGINT NOT NULL,

  -- Properties
  name varchar(256) NOT NULL,
  ai_provider varchar(256) NOT NULL default 'dev', -- For now only support 'dev' provider
  ai_model varchar(256) NOT NULL default 'parrot', -- For now only support 'parrot' model

  -- Timestamps
  cid bigint NOT NULL,
  ctime timestamp with time zone NOT NULL,
  mid bigint NOT NULL,
  mtime timestamp with time zone NOT NULL  
);

-- Conv
CREATE TYPE conv_kind AS ENUM ('OwnerOnly', 'MultiUsers');

CREATE TYPE conv_state AS ENUM ('Active', 'Archived');

CREATE TABLE conv (
  -- PK
  id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

  -- FKs
  owner_id BIGINT NOT NULL,
  agent_id BIGINT NOT NULL,

  -- Properties
  title varchar(256),
  kind conv_kind NOT NULL default 'OwnerOnly',
  state conv_state NOT NULL default 'Active',

  -- Timestamps
  cid bigint NOT NULL,
  ctime timestamp with time zone NOT NULL,
  mid bigint NOT NULL,
  mtime timestamp with time zone NOT NULL  
);

ALTER TABLE conv ADD CONSTRAINT fk_conv_agent
  FOREIGN KEY (agent_id) REFERENCES "agent"(id)
  ON DELETE CASCADE;


-- Conv Participants
CREATE TABLE conv_user (
  -- PK
  id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

  -- Properties / FKs
  conv_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL, 

  -- Machine User Properties
  auto_respond BOOLEAN NOT NULL DEFAULT false,

  -- Timestamps
  cid bigint NOT NULL,
  ctime timestamp with time zone NOT NULL,
  mid bigint NOT NULL,
  mtime timestamp with time zone NOT NULL    
);

-- Conv Messages
CREATE TABLE conv_msg (
  -- PK
  id BIGINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1000) PRIMARY KEY,

  -- FKs
  conv_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL, -- should be came as cid

  -- Properties
  content varchar(1024) NOT NULL,

  -- Timestamps
  cid bigint NOT NULL,
  ctime timestamp with time zone NOT NULL,
  mid bigint NOT NULL,
  mtime timestamp with time zone NOT NULL
);

ALTER TABLE conv_msg ADD CONSTRAINT fk_conv_msg_conv
  FOREIGN KEY (conv_id) REFERENCES "conv"(id)
  ON DELETE CASCADE;

ALTER TABLE conv_user ADD CONSTRAINT fk_conv_user_conv
  FOREIGN KEY (user_id) REFERENCES "user"(id)
  ON DELETE CASCADE;