# frozen_string_literal: true

class FetchLatestTendersService
  BASE_URL = 'https://icetrade.by/search/auctions?search_text=&search=%D0%9D%D0%B0%D0%B9%D1%82%D0%B8&zakup_type[1]=1&zakup_type[2]=1&auc_num=&okrb=&company_title=&establishment=0&period=&created_from=&created_to=&request_end_from=&request_end_to=&t[Trade]=1&t[eTrade]=1&t[Request]=1&t[singleSource]=1&t[Auction]=1&t[Other]=1&t[contractingTrades]=1&t[socialOrder]=1&t[negotiations]=1&r[1]=1&r[2]=2&r[7]=7&r[3]=3&r[4]=4&r[6]=6&r[5]=5&sort=num%3Adesc&onPage=20'
  attr_reader :client

  def initialize
    @client = HTTPClient.new
  end

  def call
    return unless last_page_tenders_urls.any?

    new_tenders_urls = last_page_tenders_urls - last_db_tenders_urls
    tenders = parse_tenders_pages(new_tenders_urls).compact
    create_tenders(tenders)
  end

  private

  def page_body(url)
    response = client.get(url)
    raise "Bad request #{response.status}: #{url}" unless response.status.between?(200, 300)

    Nokogiri::HTML(response.body)
  end

  def parse_tenders_pages(urls)
    urls.map { |url| parse_tender_page(url) }
  end

  def parse_tender_page(url)
    body = page_body(url)
    table = body.at_css('#auctBlockCont table')
    tender = {}

    tender[:url] = url
    tender[:header] = table.css('.af.af-title td').last.text.squish

    fields = {}
    fields[:industry] = table.css('.af.af-industry td').last.text.squish
    tender[:fields] = fields

    tender
  rescue StandardError => e
    nil
  end

  def last_db_tenders_urls
    @last_db_tenders_urls ||= Tender.order(id: :desc)
                                    .limit(last_page_tenders_urls.size)
                                    .pluck(:url)
  end

  def last_page_tenders_urls
    @last_page_tenders_urls ||= page_body(BASE_URL).at_css('#auctions-list')
                                                   .css('tr a')
                                                   .map { |a| a.attr('href') }
  rescue StandardError => e
    []
  end

  def create_tenders(tenders)
    Tender.create(tenders)
  end
end
