
describe 'test 2' do

  before :all do
    puts '' if logger.info?
    info '----------------- Test 2 (total: 7 pasos) -----------------'
  end

  let(:products_list) { get_products_list }

  let(:new_product) { create_product }

  it 'creates a new product' do
    all_original_products = products_list
    info '----------------------- * Listado: OK'

    d "new product that will be put: ", new_product
    authorized_put new_product[:id], new_product

    d 'new product response:', response.code, headers, body

    expect_status 201 # created
    info '----------------------- * Creacion: OK'

    # now I can't use the let <products_list> variable
    all_current_products = get_products_list

    # lets see...
    # deberia haber uno mas - si, a veces comento en ingles y a veces me da lata
    d "before was #{all_original_products.length} products. Now: #{all_current_products.length}"
    expect(all_current_products.length).to be(all_original_products.length + 1)

    d "products diference: ", all_current_products - all_original_products
    expect(all_current_products).to include(new_product[:id])
    info '----------------------- * Listado con el nuevo producto: OK'

    # y... estara?
    d "buscando si esta el producto creado: #{new_product[:id]}"

    authorized_get new_product[:id]
    expect_json(new_product)
    info '----------------------- * Obtencion del nuevo producto: OK'

  end

  it 'doesnt change for PUT with same content' do
    product_url = products_list.sample

    # el producto

    authorized_get product_url
    product = json_body

    d "Sample product for PUT without changes: ", product

    # la cabecera

    authorized_head product_url
    before_headers = expiration_headers!
    d "Expiration headers before PUT: ", before_headers

    info '----------------------- * Encabezado: OK'

    authorized_put product_url, product
    d 'unchanged PUT response:', response.code, headers, body

    expect_success

    info '----------------------- * Actualizacion PUT sin cambios: OK'


    authorized_head product_url
    after_headers = expiration_headers!
    d "Expiration headers after PUT: ", after_headers

    # expiration headers shuould not be changed
    expect(before_headers).to be == after_headers

    info '----------------------- * Encabezado sin cambios: OK'
  end

end