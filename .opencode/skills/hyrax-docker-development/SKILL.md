---
name: hyrax-docker-development
description: Develop this Hyrax application with Docker, Solr, Fedora, Redis, and TDD.
---

# Hyrax Docker Development

Use this skill for development, debugging, testing, and local administration of this repository. Run Ruby, Bundler, Rails, RSpec, Redis, Solr, and Fedora through Docker so contributors do not need Ruby 2.7 or the application dependencies installed on the host.

## Automatic bootstrap

The app image uses `/app/bin/docker-entrypoint` before starting Rails. Unless `SKIP_BOOTSTRAP=1`, it idempotently:

1. Runs `DISABLE_SPRING=1 bundle exec rails db:create db:migrate`.
2. Reads and logs worktypes registered in `config/initializers/hyrax.rb` through `Hyrax.config.registered_curation_concern_types`.
3. Creates or reuses the default and AdminSet `Hyrax::CollectionType` records.
4. Runs `DISABLE_SPRING=1 bundle exec rails hyrax:default_admin_set:create`, which creates or reuses the default AdminSet and workflows.
5. Starts the command passed to the entrypoint.

Idempotent means repeated container starts reuse existing databases, CollectionTypes, and AdminSets instead of duplicating them. The bootstrap runs on every app start so worktypes added to the code are detected automatically.

Normal startup:

```bash
docker compose up -d app
```

Skip the bootstrap only for a specific invocation:

```bash
SKIP_BOOTSTRAP=1 docker compose up -d app
```

`SKIP_BOOTSTRAP=1` does not delete or undo data; it only skips the checks for that container invocation. Omit it for normal development. Use `DISABLE_SPRING=1` for standalone Rails commands when the `mutex_m`/Spring conflict occurs.

## Project constraints

- Hyrax: `3.6.0`
- Rails: `5.2.8.1`
- Ruby: `2.7.8`
- Bundler: `2.4.22`
- Solr: `7.1.0`
- Fedora Commons: `samvera/fcrepo4:4.7.5`
- Database: SQLite for development and test
- JavaScript: Yarn 1.x and Node.js >=14

Do not install Ruby 2.7 on the host unless the user explicitly requests it. Do not use `sudo` for Docker commands when the current user already has Docker access.

## Required workflow

1. Inspect the relevant files before editing: `Gemfile`, `Gemfile.lock`, `package.json`, `yarn.lock`, `.env.example`, `.solr_wrapper.yml`, `.fcrepo_wrapper`, `config/database.yml`, and `spec/`.
2. Preserve unrelated worktree changes.
3. Use TDD for behavior changes: write a focused failing test, run it and confirm the expected failure, implement the smallest change, run the test again, then run relevant regression tests.
4. Use the existing Docker Compose environment instead of running Ruby or Rails directly on the host.
5. Verify the result with real command output; do not report success based only on file contents.

## Docker requirements

The application service must bind the repository source into the container and listen on all interfaces:

```yaml
volumes:
  - .:/app
  - bundle:/usr/local/bundle
  - node_modules:/app/node_modules
ports:
  - "0.0.0.0:3000:3000"
```

The development stack publishes these ports:

- Rails: `0.0.0.0:3000`
- Redis: `0.0.0.0:6379`
- Solr: `0.0.0.0:8983`
- Fedora: `0.0.0.0:8984` mapped to container port `8080`

Use `docker compose ps` and `docker compose port <service> <port>` to verify the bindings.

## Common commands

Run commands from the repository root:

```bash
docker compose config --quiet
docker compose build app
docker compose up -d
docker compose ps
docker compose logs --no-color --tail=100 app

docker compose run --rm app bundle check
docker compose run --rm app bundle exec rails db:create db:migrate
docker compose run --rm app bundle exec rspec spec/models/user_spec.rb
docker compose run --rm app bundle exec rspec
docker compose run --rm app bundle exec rails assets:precompile
```

For a shell inside the application container:

```bash
docker compose exec app bash
```

For a non-interactive command, use `-T`:

```bash
docker compose exec -T app bundle exec rails runner 'puts Rails.env'
```

## Solr configuration

Never create `hydra-development` from Solr's `_default` configset. Hyrax requires the repository's `solr/config` configuration, including dynamic fields used by the application such as `has_model_ssim` and `visibility_ssi`.

Compose should use:

```yaml
command: solr-precreate hydra-development /opt/solr/server/solr/configsets/hydra-development
volumes:
  - ./solr/config:/opt/solr/server/solr/configsets/hydra-development:ro
```

If the application reports `RSolr::Error::Http` for `has_model_ssim` or `visibility_ssi`:

1. Check the Solr logs and confirm the loaded schema is not `_default`.
2. Check that `solr/config/schema.xml` and `solr/config/solrconfig.xml` exist.
3. Recreate the Solr container so the collection is created with the correct config:

```bash
docker compose up -d --force-recreate solr
```

4. Re-run the exact failing query and require HTTP 200:

```bash
curl --get \
  --data-urlencode 'q=_query_:"{!raw f=has_model_ssim}Collection" AND _query_:"{!field f=visibility_ssi}open"' \
  --data-urlencode 'rows=0' \
  http://127.0.0.1:8983/solr/hydra-development/select
```

`numFound: 0` is valid; HTTP 400 is not.

## JavaScript dependencies

If `yarn install --frozen-lockfile` fails with `Host key verification failed`, inspect `package.json` and `yarn.lock` for Git SSH URLs. Replace matching `git+ssh://` URLs with HTTPS in both files and rerun the install. Do not add SSH keys to the image.

The Docker image must create the Universal Viewer destination before installing packages because the package scripts copy files into `public/uv`:

```dockerfile
COPY package.json yarn.lock ./
COPY config/uv ./config/uv
RUN mkdir -p public/uv
RUN yarn install --frozen-lockfile
```

Use Node.js >=14. Node 18 is compatible with the current lockfile; Node 12 is not.

## Rails 5.2 and Spring

This project may fail before Rails starts because Spring activates an incompatible default `mutex_m` gem. Disable Spring inside the container:

```bash
docker compose exec -T -e DISABLE_SPRING=1 app bundle exec rails runner 'puts Rails.env'
```

Use the same environment option for Rails console or other Rails commands when the error mentions `mutex_m`.

Rails 5.2 may not provide `db:prepare`; use:

```bash
docker compose run --rm app bundle exec rails db:create db:migrate
```

The non-interactive Rails console can print `Errno::ENOTTY` because IRB cannot measure terminal dimensions. If the database operations and an independent verification command succeed, treat that message as an IRB/TTY warning rather than a failed transaction.

## Rails console and administrator users

When the user explicitly requests a local administrator, use Rails console through Docker. The `User` model requires `firstname`, and administrator status is provided by the `admin` role:

```bash
printf '%s\n' \
  'user = User.find_or_initialize_by(email: "user@example.com")' \
  'user.firstname = "Name"' \
  'user.password = "PASSWORD"' \
  'user.password_confirmation = "PASSWORD"' \
  'user.save!' \
  'role = Role.find_or_create_by!(name: "admin")' \
  'user.roles << role unless user.roles.include?(role)' \
  'puts({id: user.id, admin: user.reload.admin?, password_valid: user.valid_password?("PASSWORD"), roles: user.roles.pluck(:name)}.inspect)' \
  'exit' | docker compose exec -T -e DISABLE_SPRING=1 app bundle exec rails console
```

Do not commit credentials to the repository. Avoid printing passwords in logs or final reports; report only the account email, administrator status, and verification result.

Verify independently:

```bash
docker compose exec -T -e DISABLE_SPRING=1 app bundle exec rails runner \
  'u = User.find_by!(email: "user@example.com"); puts({id: u.id, admin: u.admin?, roles: u.roles.pluck(:name)}.inspect)'
```

## Verification checklist

Before claiming the environment or a fix works, verify:

- `docker compose config --quiet` exits successfully.
- `docker compose ps` shows Redis, Solr, and Fedora healthy and the app running.
- Rails is published on `0.0.0.0:3000`.
- Redis returns `PONG`.
- Solr `/admin/ping` succeeds.
- Fedora `/rest/` responds.
- Rails `/` returns HTTP 200.
- Hyrax's minimal Solr query returns HTTP 200.
- The focused test passes after the RED-GREEN cycle.
- Existing test failures are reported separately from infrastructure failures.
