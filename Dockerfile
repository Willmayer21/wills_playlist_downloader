FROM ruby:3.1.2

# Install required packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    zip \
    nodejs \
    npm

# Install yt-dlp via pip
RUN pip3 install yt-dlp

# Create app directory
WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy app files
COPY . .

# Start Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
