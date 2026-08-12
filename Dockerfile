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
       ant \
       imagemagick \
       libreoffice \
       libsqlite3-dev \
       sqlite3 \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install --global yarn \
    && curl -fsSL https://github.com/fitstool/fits/archive/refs/tags/1.0.5.tar.gz \
       | tar -xzf - -C /opt \
    && mv /opt/fits-1.0.5 /opt/fits \
    && cd /opt/fits \
    && ant clean compile-create-jar \
    && ln -s /opt/fits/lib-fits/fits-1.0.5.jar /opt/fits/lib/fits-1.0.5.jar \
    && chmod +x /opt/fits/fits.sh \
    && ln -s /opt/fits/fits.sh /usr/local/bin/fits.sh \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install bundler -v 2.4.22

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

RUN ruby -0pi -e 'gsub(/  end\n\s*\n  if respond_to\?\(:register_engine\)/, "  elsif respond_to?(:register_engine)")' /usr/local/bundle/ruby/2.7.0/gems/sprockets-es6-0.9.2/lib/sprockets/es6.rb

COPY package.json yarn.lock ./
COPY config/uv ./config/uv
RUN mkdir -p public/uv
RUN yarn install --frozen-lockfile

COPY . .

RUN chmod +x bin/docker-entrypoint

EXPOSE 3000

ENTRYPOINT ["/app/bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
