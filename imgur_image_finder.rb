#! /usr/bin/ruby
require 'faraday'
require 'launchy'
require 'colorize'
require 'json'
# Enter your client ID and secret here.
# TODO: Move these to a separate file and encrypt
CLIENT_ID = ""
CLIENT_SECRET = ""

URL_STUB = "https://api.imgur.com/3/"

# Searches for galleries, and returns the JSON
def gallery_search(q, advanced=nil, sort="top", window='all',page=0)
  if advanced
    puts "Sorry, advanced mode not implemented yet!"
  else
    data = {"q" => "#{q}"}
  end
  response = make_request("GET", "gallery/search/#{sort}/#{window}/#{page}", data)
  b = response
  # the above is essentially legacy code, but I'm leaving it incase it will serve a purpose in the future
  return b
end

# Uses an album hash to get the images from a gallery
def get_album_images(hash)
  response = make_request("GET", "album/#{hash}/images")
  return response
end

# Makes a request with the imgur REST API
def make_request(method, route, data=nil, force_anon=false)
  url = URL_STUB + route

  # Organizes the data of the request
  if data
    if data["q"]
      url = url + "?q=#{data["q"]}"
    end
  end
  puts "url: #{url}"

  # Establishes a connection and autenticates with Oauth2
  conn = Faraday.new(url, headers: { "Client-ID" => CLIENT_ID})
  conn.authorization("Client-ID", CLIENT_ID)
  req = conn.get
  return req
end




# Only runs if the file is run, and not if it is imported
if __FILE__ == $0
  puts "enter word to search"
  word = gets.chomp
  
  g = gallery_search(word)
  body_json = JSON.parse(g.body)["data"]

  puts "success?:   #{g.success?}\n".red
  puts "number of galleries:\n#{body_json.length}"

  # Randomly selects a gallery
  chosen_index = rand(body_json.length)
  puts "selected index: #{chosen_index}"
  puts "link to gallery: #{body_json[chosen_index]["link"]}"
  gallery_id = body_json[chosen_index]["id"]
  album_response = get_album_images(gallery_id)
  if album_response.success?
    album = JSON.parse(album_response.body)["data"]
    puts "Number of images: #{album.length}"

    # Randomly selects an image
    chosen_index = rand(album.length)
    puts "chosen index: #{chosen_index}"
    image_link = album[chosen_index]
  #  puts "album:\n#{album}"
  #  puts "/nimage link:".red
  #  puts image_link
    lonk = image_link["link"]
    puts lonk
  else
    # Usually is the response is not a success, it's because the album only has one image, and therefore there is only one possibility. Thus, it is chosen.
    puts "Number of images: 1"
    link = body_json[chosen_index]["link"]
    puts link
  end

  # Opens a browser to the image
  Launchy.open(link)
end
