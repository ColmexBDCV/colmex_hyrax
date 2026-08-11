FROM ruby:2.7.8-bullseye

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    BUNDLE_WITHOUT="" \
    RAILS_ENV=development

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       ca-certificates \
       curl \
       default-jre-headless \
       ffmpeg \
       gnupg \
       imagemagick \
       libreoffice \
       libsqlite3-dev \
       sqlite3 \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install --global yarn \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install bundler -v 2.4.22

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

COPY package.json yarn.lock ./
COPY config/uv ./config/uv
RUN mkdir -p public/uv
RUN yarn install --frozen-lockfile

COPY . .

EXPOSE 3000

CMD ["bash", "-lc", "bundle exec rails server -b 0.0.0.0 -p 3000"]
