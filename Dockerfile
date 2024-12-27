FROM ruby:3.1.2

# Install required packages
RUN apt-get update && apt-get install -y \
   yt-dlp \
   zip \
   nodejs \
   npm

# Create app directory
WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy app files
COPY . .

# Start Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
