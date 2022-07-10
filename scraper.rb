require 'nokogiri'
require 'faker'
require 'rest-client'

class Scraper
  attr_accessor :main_link, :user_agent, :base_ball_cards

  def initialize
    @main_link = 'https://www.ebay.com/b/Baseball-Trading-Card-Singles/261328/bn_7114821133?rt=nc&mag=1&LH_Sold=1'
    @user_agent = Faker::Internet.user_agent(:chrome)
    @base_ball_cards = []
  end

  def scrape
    @doc = fetch(main_link)

    base_ball_ul =  @doc.css("ul.b-list__items_nofooter.srp-results.srp-grid")
    base_ball_ul.css("li.s-item.s-item--large").each do |list_item|
      heading_link = list_item.css("a.s-item__link").first["href"]
      details = listing_details(heading_link)
      head_line = list_item.css("h3.s-item__title.s-item__title--has-tags").text
      price = list_item.css("div.s-item__detail.s-item__detail--primary > span.s-item__price").text
      date_sold = list_item.css("div.s-item__title-tag").text

      base_ball_cards.push({ head_line: head_line, price: price, date: date_sold, seller_name: details[:s_name], images: details[:images] })
    end

    base_ball_cards.to_json
  end

  private

  def fetch(link)
    begin
      html_page = RestClient.get link, user_agent: user_agent
      parsed_page = Nokogiri::HTML(html_page)
    rescue RestClient::Exceptions::ReadTimeout => e
      puts "Retring..."
      retry
    end
  end

  def listing_details(link)
    parsed_page = fetch(link)
    s_name = parsed_page.css("div.mbg.vi-VR-margBtm3 span.mbg-nw").text
    if !parsed_page.css("ul#vertical-align-items-viewport img").empty?
      images = parsed_page.css("ul#vertical-align-items-viewport img").map{ |node| node["src"]}.reject!{ |src| src.start_with?("//") }
    elsif parsed_page.css("div#mainImgHldr img#icImg")&.first&.[]("src")
      images = parsed_page.css("div#mainImgHldr img#icImg").first["src"]
    else
      images = parsed_page.css("div.img.img140 img#icImg")&.first&.[]("src")
    end

    { s_name: s_name, images: images }
  end
end

