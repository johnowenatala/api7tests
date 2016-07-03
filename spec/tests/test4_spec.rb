
describe 'test 4' do

  before :all do
    puts '' if logger.info?
    info '----------------- Test 4 (total: 6 pasos) -----------------'
  end

  let(:products_list) { get_products_list }

  it 'changes header information on update via PUT' do
    product_url = products_list.sample
    info '----------------------- * Listado: OK'

    # el producto

    authorized_get product_url
    product = json_body

    d "Sample product for be changed via PUT: ", product
    info '----------------------- * Obtencion: OK'

    # la cabecera

    authorized_head product_url
    before_headers = expiration_headers!
    d "Expiration headers before changing PUT: ", before_headers
    info '----------------------- * Encabezado: OK'

    new_price = (rand(10..1000)*100 + 90)
    product[:price] = new_price

    authorized_put product_url, product
    d 'changed PUT response:', response.code, headers, body

    expect_success

    info '----------------------- * Actualizacion PUT: OK'

    authorized_head product_url
    after_headers = expiration_headers!
    d "Expiration headers after changing PUT: ", after_headers

    # expiration headers shuould be changed
    expect(before_headers).not_to be == after_headers

    info '----------------------- * Encabezado tras actualizacion: OK'
  end

  it 'changes header information on update via PUT' do
    product_url = products_list.sample

    # el producto

    authorized_get product_url
    product = json_body

    d "Other sample product for be changed via PUT: ", product

    new_price = (rand(10..1000)*100 + 90)
    product[:price] = new_price

    authorized_put product_url, product
    d 'changed PUT response:', response.code, headers, body

    authorized_get product_url

    expect_json(price: new_price)

    info '----------------------- * Obtencion con cambios: OK'
  end

end