FROM ruby:3.2

# Set environment variables
ENV RAILS_ENV=development
ENV BUNDLER_VERSION=2.4.22

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client yarn

# Set working directory
WORKDIR /app

# Install gems
COPY Gemfile* ./
RUN gem install bundler -v $BUNDLER_VERSION
RUN bundle install

# Copy project files
COPY . .

# Precompile assets if needed (for non-API apps)
# RUN bundle exec rake assets:precompile

# Expose port
EXPOSE 3000

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails db:create db:migrate && bundle exec rails s -b '0.0.0.0'"]
