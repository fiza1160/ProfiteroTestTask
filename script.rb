require 'curb'
require 'nokogiri'
require 'optimist'
require 'csv'

def get_args()
    args = Optimist::options do
        opt :file_name, "Results file name (full name with path)", :type => :string
        opt :link, "Link to site category", :type => :string
    end
    
    return args
end


def get_main_pages(html, link)
    pages = []
    pages << html

    counter = 1
    while next_page_exists?(html) do
        counter += 1
        http = Curl.get(link, {:p => counter})
        html = Nokogiri::HTML(http.body_str)
        pages << html
    end
    return pages
end


def parse_main_pages(pages)
    links = []
    pages.each do |page|
        page.xpath("//ul[@id='product_list']//a[@class='product_img_link product-list-category-img']/@href").each do |href|
            links << href.value
        end
    end
    return links
end


def next_page_exists?(page)
    if page.xpath("//li[@id='pagination_next_bottom']/@class")[0].value == "disabled pagination_next"
        return false
    end
    return true
end

def get_product_pages(links)
    pages = []
    links.each do |link|
        http = Curl.get(link)
        pages << Nokogiri::HTML(http.body_str)
    end
    return pages
end

def parse_product_pages(pages)
    product_data = {}
    pages.each do |page|

        main_name = page.xpath("//p[@class='product_main_name']").text.strip.capitalize
        image = page.xpath("//img[@id='bigpic']/@src").to_s

        product_list = page.xpath("//div[@class='attribute_list']//li//label")
        if product_list.length > 0 
            index = 0
            product_list.length.times do
                size = page.xpath("//div[@class='attribute_list']//li//label//span[@class='radio_label']")[index].text.strip
                prise = page.xpath("//div[@class='attribute_list']//li//label//span[@class='price_comb']")[index].text.strip
                full_name = "#{main_name} - #{size}"
                product_data[full_name] = {
                    :prise => prise,
                    :image => image
                }
                index += 1
            end
        else
            prise = page.xpath("//span[@id='our_price_display']/@content").to_s
            
            unless main_name == "" || image == "" || prise == ""
                product_data[main_name] = {
                    :prise => prise,
                    :image => image
                }
            end
        end
    end

    return product_data 
end


def save_in_csv(file_name, data)
    CSV.open(file_name, "w") do |csv|
        csv << ["Name", "Prise", "Image"]
        
        data.each do |key, val|
            csv << [key, val[:prise], val[:image]]
        end
    end
end


if __FILE__ == $0
    
    args = get_args()
    file_name = args[:file_name]
    link = args[:link]
    if link[-1] != '/'
        link += '/'
    end

    puts "Download main page..."

    http = Curl.get(link)
    html = Nokogiri::HTML(http.body_str)

    puts "Expend pagination..."
    main_pages = get_main_pages(html, link)

    puts "Get links to pages with products..."
    product_links = parse_main_pages(main_pages)

    puts "Download product pages..."
    product_pages = get_product_pages(product_links)

    puts "Get information about products..."
    product_data = parse_product_pages(product_pages)

    puts "Save results to file..."
    save_in_csv(file_name, product_data)

    puts "Ready! Info about products was saved in #{file_name}"

end
