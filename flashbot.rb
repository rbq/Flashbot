#! /usr/bin/env ruby
# encoding: UTF-8
require 'rubygems'
require 'twitter'
require 'yaml'


# Config spezifizieren und auslesen
CONFIG_FILE = 'config.yaml'
CONFIG = YAML::load(File.open(File.join(File.dirname(__FILE__), CONFIG_FILE)))
SEARCH_FILE = 'search.yaml'
$search = YAML::load(File.open(File.join(File.dirname(__FILE__), SEARCH_FILE)))
$since_id = $search['suche']['since_id']

# Client konfigurieren und erzeugen
Twitter.configure do |config|
  config.consumer_key = CONFIG['oauth']['consumer_key']
  config.consumer_secret = CONFIG['oauth']['consumer_secret']
  config.oauth_token = CONFIG['oauth']['request_token']
  config.oauth_token_secret = CONFIG['oauth']['request_secret']
end

client = Twitter::Client.new

# Hole die letzten paar Tweets, die mit Hashtag "#piraten" geschrieben haben.
suchergebnisse = client.search('flash', {:since_id => $since_id})

# Neuen Such-Startpunkt auslesen und in die Config schreiben
$since_id = suchergebnisse[0].id unless (suchergebnisse.length == 0)
$search['suche']['since_id'] = $since_id
File.open(SEARCH_FILE, 'w') { |f| YAML.dump($search, f) }

suchergebnisse.each do |ergebnis|
    client.update("@#{ergebnis.from_user} FLASH! Aaaah - Savior of the Universe", {:in_reply_to_status_id => ergebnis.id})
end

