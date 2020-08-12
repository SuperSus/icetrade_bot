class IceTradeService
  BASE_URL = 'https://icetrade.by/search/auctions?search_text=&search=%D0%9D%D0%B0%D0%B9%D1%82%D0%B8&zakup_type[1]=1&zakup_type[2]=1&auc_num=&okrb=&company_title=&establishment=0&period=&created_from=&created_to=&request_end_from=&request_end_to=&t[Trade]=1&t[eTrade]=1&t[Request]=1&t[singleSource]=1&t[Auction]=1&t[Other]=1&t[contractingTrades]=1&t[socialOrder]=1&t[negotiations]=1&r[1]=1&r[2]=2&r[7]=7&r[3]=3&r[4]=4&r[6]=6&r[5]=5&sort=num%3Adesc&onPage=20'
  attr_reader :client

  def initialize
    @client = HTTPClient.new
  end

  def call
    response = client.get(BASE_URL)
    # response.status == 200
    body = Nokogiri::HTML(response.body)
    last_tender_nodes = body.at_css('#auctions-list').css('tr')[1..-1]
    parse(last_tender_nodes.first)
  end

  private

  def parse(node)
    link = node.at_css('a').attr('href')
    header = node.at_css('a').text.squish
    field_info = node.css('td')[1..-1].map(&:text).map(&:squish)
    field_names = %w(Заказчик Страна Номер Стоимость Действует)

    rest_info = field_names.zip(field_info).map { |key, value| "#{key}: #{value}" }
    <<~MSG
      *#{header}*

      #{rest_info.join("\n")}

      #{link}
    MSG
  end
end
