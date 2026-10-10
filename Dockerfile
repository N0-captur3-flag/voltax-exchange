FROM ruby:3.3.6-slim

ENV BUNDLE_DEPLOYMENT=true \
    BUNDLE_PATH=/usr/local/bundle \
    RACK_ENV=production

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential curl libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN chmod +x bin/entrypoint bin/server bin/migrate bin/matching-engine bin/market-simulator

EXPOSE 9292

ENTRYPOINT ["bin/entrypoint"]
CMD ["server"]
