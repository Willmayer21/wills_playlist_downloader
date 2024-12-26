class PlaylistsController < ApplicationController
  require 'csv'
  require 'rspotify'
  require 'open3'
  require 'fileutils'
  require 'shellwords'
  require 'mp3info'
  require 'open-uri'

  def new
  end

  def download
    @playlist_id = params[:playlist_id]

    # Initialize Spotify API
    RSpotify.authenticate("e50546d4ba114f9ca823624fdfac627f", "929f6368e8d7478ebc5a7394f0653cb6")

    begin
      @playlist = RSpotify::Playlist.find_by_id(@playlist_id)
      raise "Playlist not found" unless @playlist

      # Create downloads directory
      download_dir = Rails.root.join('public', 'downloads', "spotify_downloads_#{sanitize_filename(@playlist.name)}")
      FileUtils.mkdir_p(download_dir)

      # Create CSV file
      csv_path = download_dir.join("#{@playlist.name.gsub(' ', '_')}_tracks.csv")
      @tracks_info = []

      CSV.open(csv_path, 'w') do |csv|
        csv << ['Track Name', 'Artist']
        @playlist.tracks.each do |track|
          artwork_url = track.album.images.max_by { |img| img['height'].to_i }&.fetch('url')
          track_info = [track.name, track.artists.first.name, artwork_url]
          @tracks_info << track_info
          csv << track_info[0..1]
        end
      end

      # Download tracks
      @tracks_info.each do |track_name, artist_name, artwork_url|
        artwork_data = get_artwork_data(artwork_url)
        download_track(track_name, artist_name, artwork_data, download_dir)
      end

      @success = true
      @download_path = "/downloads/spotify_downloads_#{sanitize_filename(@playlist.name)}"
    rescue => e
      @error = e.message
    end

    render :new
  end

  private

  def sanitize_filename(filename)
    filename.gsub(/[\x00\/\\:*?"<>|]/, '_')
  end

  def get_artwork_data(url)
    return nil unless url
    begin
      URI.open(url, &:read)
    rescue
      nil
    end
  end

  def download_track(track_name, artist_name, artwork_data, output_dir)
    search_query = "#{track_name} #{artist_name}"
    filename = sanitize_filename("#{artist_name} - #{track_name}")
    output_path = "#{output_dir}/#{filename}.mp3"

    command = [
      'yt-dlp',
      '--extract-audio',
      '--audio-format', 'mp3',
      '--audio-quality', '0',
      '--output', output_path,
      '--no-playlist',
      '--no-warnings',
      "ytsearch1:#{search_query}"
    ]

    success = system(*command)

    if success && File.exist?(output_path)
      begin
        Mp3Info.open(output_path) do |mp3|
          mp3.tag.title = track_name
          mp3.tag.artist = artist_name
          mp3.tag2.add_picture(artwork_data) if artwork_data
        end
      rescue => e
        logger.warn "Could not set metadata: #{e.message}"
      end
    else
      logger.warn "Download failed for #{track_name}"
    end
  end
end
