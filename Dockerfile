FROM ruby:3.3.5  # Changed from 3.1.2 to match your Gemfile

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

# Start Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
