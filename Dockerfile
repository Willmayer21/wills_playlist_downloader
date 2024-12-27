FROM ruby:3.3.5

# Install required packages
RUN apt-get update && apt-get install -y \
    python3 \
    curl \
    zip \
    nodejs \
    npm

# Install yt-dlp directly
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
    chmod a+rx /usr/local/bin/yt-dlp

# Create app directory
WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy app files
COPY . .

# Set Rails environment
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true

# Precompile assets
RUN bundle exec rails assets:precompile

# Create downloads directory with proper permissions
RUN mkdir -p public/downloads && chmod 777 public/downloads

# Expose port
EXPOSE 3000

# Start Rails server
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]
