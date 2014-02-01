require 'feedzirra'
require 'pry'

get '/' do

  uri = 'https://www.fanfiction.net/atom/l/?&cid1=10896&r=103&s=1'

  if params['feed']
    feed = params.delete 'feed'
    uri = feed + params.to_query
  end

  puts "Feed uri: #{uri}"

  @feed = Feedzirra::Feed.fetch_and_parse(uri)
  haml :index
end

generate_file = lambda do
  story = FanficStory.new(params['url'])
  story.load_details
  story.load_chapters

  gen = Generator.new
  gen.build(story)

  content_type 'application/epub+zip'
  attachment "#{story.title.gsub(' ', '_')}.epub"
  gen.result_stream.string
end

get '/story.epub', &generate_file
post '/story.epub', &generate_file
