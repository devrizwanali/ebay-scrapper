require './scraper'

class Main
  scraper = Scraper.new
  data = scraper.scrape

  puts "========= Baseball Trading Card Singles Data ==========\n\n\n\n"
  puts data
end
