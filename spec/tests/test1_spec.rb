
describe 'test 1' do

  before :all do
    puts '' if logger.info?
    info '----------------- Test 1 (total: 5 pasos) -----------------'
  end

  let(:products_list) { get_products_list }


  it 'list products' do
    if logger.debug?
      products_list
      d "First 300 characters of response body: #{body[0..300].inspect}"
    end
    expect(products_list).to be_a(Array).and all( be_an(String) )
    info '----------------------- * Listado: OK'
  end

  it 'gets a random product' do
    sample_url = products_list.sample
    d "getting product: ", sample_url

    # GET

    authorized_get sample_url
    d "headers:", headers
    d "body:", body
    expect_json_types(id: :string,
                      name: :string,
                      description: :string,
                      image: :string,
                      price: :integer)
    # el id debe ser la misma url
    expect_json(id: sample_url, image: config.url_regex)
    info '----------------------- * Obtencion: OK'
  end

  it 'gets a random product (HEAD)' do
    sample_url = products_list.sample
    d "getting by HEAD a product: ", sample_url

    # HEAD

    authorized_head sample_url

    d "headers:", headers
    d "body:", body

    expect(body).to be_empty
    info '----------------------- * Encabezado: OK'

  end

  it 'gets two diferent random products' do
    sample_url = products_list.sample

    # GET

    d "getting first product", sample_url
    authorized_get sample_url

    first_body = json_body

    # otro producto
    if products_list.length > 1
      sample_url2 = products_list.reject{|p| p == sample_url }.sample

      d "getting product 2: ", sample_url2
      authorized_get sample_url2

      second_body = json_body
      d "expect products to be different (at least its ids):", first_body, second_body

      expect(second_body).not_to be == first_body


      info '----------------------- * Obtencion 2: OK'
      info '----------------------- * Encabezado 2: OK'

    else
      logger.warn "No puedo pedir 2 productos distintos: no hay tantos"
    end

  end

  # No voy a hacer la prueba de un segundo head, pues no le veo ningun sentido

end