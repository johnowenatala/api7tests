
describe 'test 3' do

  before :all do
    puts '' if logger.info?
    info '----------------- Test 3 (total: 6 pasos) -----------------'
  end

  let(:products_list) { get_products_list }

  it 'changes header information on update via PATCH' do
    product_url = products_list.sample
    info '----------------------- * Listado: OK'

    # el producto

    authorized_get product_url
    product = json_body
    info '----------------------- * Obtencion: OK'

    d "Sample product for be changed via PATCH: ", product

    # la cabecera

    authorized_head product_url
    before_headers = expiration_headers!
    d "Expiration headers before PATCH: ", before_headers
    info '----------------------- * Encabezado: OK'

    new_price = (rand(10..1000)*100 + 90)

    authorized_patch product_url, {price: new_price}
    d 'changed PATCH response:', response.code, headers, body

    expect_success

    info '----------------------- * Actualizacion PATCH: OK'

    authorized_head product_url
    after_headers = expiration_headers!
    d "Expiration headers after PATCH: ", after_headers

    # expiration headers shuould be changed
    expect(before_headers).not_to be == after_headers

    info '----------------------- * Encabezado dice que hay cambios: OK'

  end

  it 'changes data information on update via PATCH' do
    product_url = products_list.sample

    # el producto

    authorized_get product_url
    product = json_body

    d "Other sample product for be changed via PATCH: ", product

    new_price = (rand(10..1000)*100 + 90)

    authorized_patch product_url, {price: new_price}
    d 'changed PATCH response:', response.code, headers, body

    authorized_get product_url

    expect_json(price: new_price)

    info '----------------------- * Obtencion con cambios: OK'

  end

end