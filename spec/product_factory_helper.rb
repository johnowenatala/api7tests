require 'faker'
require 'giphy'
require 'digest'

module ProductFactoryHelper

  def create_product(args = {})

    # normalize args keys for these symbols
    [:id,:name,:description,:image,:price].each do |k|
      k_s = k.to_s
      args[k] = args[k_s] if args.has_key?(k_s) && !args.has_key?(k)
    end

    {
      id:          args[:id]          || "#{config.products_url}/#{Digest::MD5.hexdigest(Faker::Lorem.characters)}",
      name:        args[:name]        || Faker::Commerce.product_name,
      description: args[:description] || Faker::Lorem.sentence(rand(3..6),true),
      image:       args[:image]       || Giphy.random(:simpsons).image_url.to_s,
      price:       args[:price]       || (rand(10..1000)*100 + 90)
    }
  end

end