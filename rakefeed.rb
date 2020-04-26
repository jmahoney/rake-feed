require "nokogiri"
require "httparty"
require "sinatra"
require "date"

items = []
last_fetched = Date.today - 7

get "/" do
  if  items.empty? || last_fetched < DateTime.now - 0.5
    items = fetch_and_parse
    last_fetched = DateTime.now
  end

  feed = {
    version: "https://jsonfeed.org/version/1",
    title: "Rake Editorial Feed",
    home_page_url: "https://therake.com/category/stories/",
    feed_url: "http://rake-feed.cheerschopper.com",
    items: items
  }

  content_type "application/json"
  feed.to_json
end

def fetch_and_parse
  response = HTTParty.get("https://therake.com/category/stories/")

  if response.success?
    doc = Nokogiri.HTML(response.body)

    feed = []

    rows = doc.css("ul[class='list list'] li")

    rows.each do |row|
      anchor = row.css("a").first
      permalink="https://therake.com#{anchor['href']}"
      hero_image = anchor.css("img").first
      hero_image_src = hero_image['data-src']
      title = hero_image['alt']
      date = anchor.css("p[class='heading'] span").first

      puts date
      html = "<a href='#{permalink}'><img src='#{hero_image_src}' /></a>"
      feed << {id: permalink, url: permalink, content_html: html, title: title, date_published: DateTime.parse(date.text).to_s}
    end

    return feed
  end


end




