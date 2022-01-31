## -*- mode: ruby; -*-
# https://github.com/pry/pry/wiki/Custom-commands
#
# general pry config

if defined? Rails

  # Expects Pry::Slop or a hash
  def  open_url(url)
    system "open #{url}"
  end

  def set_env(env)
    if env[:p] || env[:prod]
      'www'
    elsif env[:s] || env[:staging]
      'staging'
    elsif env[:a] || env[:admin]
      'admin'
    else
      'mydev'
    end
  end
  # Commands
  #
  #
  def maybe_product(product)
    product.is_a?(Legacy::Product) ? product : Legacy::Product.find(product)
  end

  Pry::Commands.create_command "random_product_go" do
    description "Go to a random product in my dev"

    def options(opt)
      opt.on :p, :prod,    'Go to a random porduct on prod'
      opt.on :s, :staging, 'Go to a random porduct on staging'
    end

    def process
      product = Legacy::Product.ripe.order("RAND()").limit(1).first
      url = "https://#{set_env opts}.1000bulbs.com/product/#{product.id}/#{product.catalog_code}.html"
      open_url url
    end
  end

  Pry::Commands.block_command 'go-to-product', 'Pass a product or product id to go to that product' do |product, env|
    env = env.nil? ? 'dev' : env.gsub!(':', '')
    product = maybe_product product

    url = "https://#{set_env({env.to_sym => env})}.1000bulbs.com/product/#{product.id}/#{product.catalog_code}.html"
    open_url url
  end

  Pry::Commands.block_command 'go-to-product-admin', 'Pass a product or product id to go to that product page. \n Pass p to go to the prod page' do |product, env|
    env = env.nil? ? 'dev' : env.gsub!(':', '')
    product = maybe_product product


    url = "https://#{set_env({env.to_sym => env})}.1000bulbs.com/fil/admin/products/#{product.id}/edit/#fndtn-pricing"
    open_url url
  end

  Pry::Commands.block_command 'go-to-admin', 'Go to the admin page' do |product, env|
    url = "https://admin.1000bulbs.com/admin"
    open_url url
  end

  Pry::Commands.create_command "random-product-cart" do
    description "Random prouct to cart"

    def process
      # cart = Cart.last
      # cart.update(cart_params)
      # cart.refresh_product_prices!

      # cart.apply_pricing_agreements!

      # apply_promotion!

      # cart.update_shipping!
      # cart.apply_discounts!
      puts "Not implemented"
    end
  end

  puts "require factory bot"
  require "factory_bot"
  include FactoryBot::Syntax::Methods
  puts 'You can now use factory bot methods.'
end

def get_invoice(id)
  Invoice.find_by(syspro_order_id: id). tap do |i|
    puts  i.order.orderable.credit_limit.to_i
    puts i.order.total.to_i
    puts i.order.order_exception_log&.messages
  end
end

Pry.commands.alias_command 'q', 'exit'
# Pry.commands.alias_command 'c', 'continue'
# Pry.commands.alias_command 's', 'step'
# Pry.commands.alias_command 'n', 'next'
