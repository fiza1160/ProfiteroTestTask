require "minitest/autorun"
require "curb"
require "nokogiri"
require_relative 'script.rb'

class TestScript < Minitest::Test

  def test_get_main_pages
    link = "https://www.petsonic.com/hobbit-half/"
    html = Nokogiri::HTML(Curl.get(link).body_str)
    result = get_main_pages(html, link)

    assert_equal 3, result.length
    assert_instance_of Nokogiri::HTML::Document, result[0]
  end

  def test_parse_main_pages
    http = Curl.get("https://www.petsonic.com/hobbit-half/")
    pages = [Nokogiri::HTML(http.body_str)]

    result = [
      "https://www.petsonic.com/hobbit-alf-barritas-redonda-ternera-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-barritas-redonda-cordero-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-barritas-redonda-pollo-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-mini-huesitos-tiernos-mix-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-hueso-piel-sabor-barbacoa-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-hueso-piel-sabor-chocolate-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-hueso-piel-fluor-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-nudillo-ternera-calcio-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-nudillo-ternera-ahumado-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-canailla-jamon-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-hueso-jamon-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-hueso-calcio-corto-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-hueso-ternera-calcio-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-rosco-piel-fluor-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-hueso-ternera-ahumado-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-orejas-cerda-extra-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-oreja-vaca-deshidratada-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-pezuna-ternera-rellena-para-perros.html",
      "https://www.petsonic.com/trixie-zapato-piel-masticable-10-unidades-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-oreja-cerdo-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-tendon-cuero-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-puntas-nervio-toro-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-tendon-extra-20cm-para-perros.html",
      "https://www.petsonic.com/hobbit-alf-tira-tendon-para-perros.html"
    ]

    assert_equal result, parse_main_pages(pages)

  end

  def test_get_product_pages
    links = ["https://www.petsonic.com/hobbit-alf-tira-tendon-para-perros.html"]

    assert_instance_of Nokogiri::HTML::Document, get_product_pages(links)[0]
  end

  def test_parse_product_pages_three_products

    http = Curl.get("https://www.petsonic.com/hobbit-alf-galletas-puppy-para-perros.html")
    pages = [Nokogiri::HTML(http.body_str)]

    result = {
        "Hobbit alf galletas puppy para perro - 100 Gr." => {
            :prise => "0.89 €/u",
            :image => "https://img1.petsonic.com/14110-large_default/hobbit-alf-galletas-puppy-para-perros.jpg"
        },
        "Hobbit alf galletas puppy para perro - 200 Gr." => {
          :prise => "1.79 €/u",
          :image => "https://img1.petsonic.com/14110-large_default/hobbit-alf-galletas-puppy-para-perros.jpg"
        },
        "Hobbit alf galletas puppy para perro - 430 gr" => {
          :prise => "2.84 €/u",
          :image => "https://img1.petsonic.com/14110-large_default/hobbit-alf-galletas-puppy-para-perros.jpg"
        }
    }
    assert_equal result, parse_product_pages(pages)
  end

  def test_parse_product_pages_one_product

    http = Curl.get("https://www.petsonic.com/hobbit-alf-muslitos-pollo-calcio-para-perros.html")
    pages = [Nokogiri::HTML(http.body_str)]

    result = {
        "Hobbit alf muslitos de pollo y calcio para perro - 100 Gr." => {
            :prise => "2.49 €/u",
            :image => "https://img3.petsonic.com/11056-large_default/hobbit-alf-muslitos-pollo-calcio-para-perros.jpg"
        },
    }
    assert_equal result, parse_product_pages(pages)
  end

  def test_save_in_csv

    file_name = "test_data.csv"
    data = {
      "Hobbit alf galletas puppy para perro - 100 Gr." => {
          :prise => "0.89 €/u",
          :image => "https://img1.petsonic.com/14110-large_default/hobbit-alf-galletas-puppy-para-perros.jpg"
      },
      "Hobbit alf galletas puppy para perro - 200 Gr." => {
        :prise => "1.79 €/u",
        :image => "https://img1.petsonic.com/14110-large_default/hobbit-alf-galletas-puppy-para-perros.jpg"
      },
      "Hobbit alf galletas puppy para perro - 430 gr" => {
        :prise => "2.84 €/u",
        :image => "https://img1.petsonic.com/14110-large_default/hobbit-alf-galletas-puppy-para-perros.jpg"
      }
    }

    save_in_csv(file_name, data)

    result = CSV.read(file_name)
    
    expected_result = [
      ["Name", "Prise", "Image"], 
      ["Hobbit alf galletas puppy para perro - 100 Gr.", 
        "0.89 €/u", 
        "https://img1.petsonic.com/14110-large_default/hobbit-alf-galletas-puppy-para-perros.jpg"], 
      ["Hobbit alf galletas puppy para perro - 200 Gr.", 
        "1.79 €/u", 
        "https://img1.petsonic.com/14110-large_default/hobbit-alf-galletas-puppy-para-perros.jpg"], 
      ["Hobbit alf galletas puppy para perro - 430 gr", 
        "2.84 €/u", 
        "https://img1.petsonic.com/14110-large_default/hobbit-alf-galletas-puppy-para-perros.jpg"]
      ]

    assert_equal result, expected_result

  end

end
