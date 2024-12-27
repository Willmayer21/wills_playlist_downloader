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
ENV SECRET_KEY_BASE=4dae70976fb93eff4b131b8f100f18fb42f2ae15d72cb505da2e87e31e62cbe594f8d6a3c072f97f0b79f95c57f0973b5c9e286c8d85afd828b98990f4b89639

# Precompile assets
RUN bundle exec rails assets:precompile

# Create downloads directory with proper permissions
RUN mkdir -p public/downloads && chmod 777 public/downloads
