
test6_storage = []

describe 'test 6' do

  before :all do
    puts '' if logger.info?
    info '----------------- Test 6 (total: 13 pasos) ----------------'

  end

  let(:products_list) { get_products_list }
  let(:sample_product_url) { products_list.sample }
  let(:sample_product) { authorized_get sample_product_url; json_body }
  let(:new_product) { create_product }
  let(:another_product_url) { create_product[:id] }

  # lo voy a dejar aparte, porque es como "rudo"
  # este test para basar el resto del codigo
  context 'before other tests' do
    it 'full listing' do
      test6_storage.clear
      products_list.map do |product_url|
        authorized_get product_url
        test6_storage << json_body
      end
      info '----------------------- * 1 Full listing y obtencion random: OK'
    end
  end

  context 'without auth' do

    it 'should require auth' do
      d "Producto a usar para no-auth: ", sample_product

      # listado
      get config.products_url, api_base_headers
      d "Listado s/a: ", response.code, headers, body
      expect_unauthorized

      # get
      get sample_product_url, api_base_headers
      d "Obtencion s/a: ", response.code, headers, body
      expect_unauthorized

      # crear
      put new_product[:id], new_product, api_base_headers
      d "Crear s/a: ", response.code, headers, body
      expect_unauthorized

      # actualizar patch
      patch sample_product_url, {name: Faker::Name.name}, api_base_headers
      d "Actualizar patch s/a: ", response.code, headers, body
      expect_unauthorized

      # actualizar put
      put sample_product_url, sample_product.merge(price: rand(10000)), api_base_headers
      d "Actualizar put s/a: ", response.code, headers, body
      expect_unauthorized

      # delete
      delete sample_product_url, nil, api_base_headers
      d "Delete s/a: ", response.code, headers, body
      expect_unauthorized

      info '----------------------- * 2 Operaciones sin auth: OK'
    end

    it 'should not do anything' do

      d 'Producto antes:', sample_product

      # listado
      get config.products_url, api_base_headers
      # get
      get sample_product_url, api_base_headers
      # crear
      put new_product[:id], new_product, api_base_headers
      # actualizar patch
      patch sample_product_url, {name: Faker::Name.name}, api_base_headers
      # actualizar put
      put sample_product_url, sample_product.merge(price: rand(10000)), api_base_headers
      # delete
      delete sample_product_url, nil, api_base_headers

      authorized_get sample_product_url
      d 'Producto despues:', json_body
      expect_json(sample_product)

      info '----------------------- * 3 Luego de operaciones sin auth: sample product sin cambios'

    end

  end

  context 'with wrong auth' do
    it 'should also fail as no auth' do
      d "Producto a usar para auth erronea: ", sample_product

      user = "no_#{config.user}"
      pass = "#{Digest::MD5.hexdigest(config.pass)[0..12]}"
      wrong_credentials_headers = api_base_headers.merge({
        'Authorization' => "Basic #{Base64.strict_encode64("#{user}:#{pass}")}"
      })


      # si alguno se cae, podria estar retornando 403, lo que puede ser valido en este caso

      # listado
      get config.products_url, wrong_credentials_headers
      d "Listado w/a: ", response.code, headers, body
      expect_unauthorized(true)

      # get
      get sample_product_url, wrong_credentials_headers
      d "Obtencion w/a: ", response.code, headers, body
      expect_unauthorized(true)

      # crear
      put new_product[:id], new_product, wrong_credentials_headers
      d "Crear w/a: ", response.code, headers, body
      expect_unauthorized(true)

      # actualizar patch
      patch sample_product_url, {name: Faker::Name.name}, wrong_credentials_headers
      d "Actualizar patch w/a: ", response.code, headers, body
      expect_unauthorized(true)

      # actualizar put
      put sample_product_url, sample_product.merge(price: rand(10000)), wrong_credentials_headers
      d "Actualizar put w/a: ", response.code, headers, body
      expect_unauthorized(true)

      # delete
      delete sample_product_url, nil, wrong_credentials_headers
      d "Delete w/a: ", response.code, headers, body
      expect_unauthorized(true)


      info '----------------------- * 4 Operaciones con auth, pero erronea: OK'
    end
  end

  context 'without auth and unexistent url' do
    it 'should fail as unauthorized' do
      not_found_url = another_product_url

      get not_found_url, api_base_headers
      d "Obtener s/a 404: ", response.code, headers, body
      expect_unauthorized

      patch not_found_url, api_base_headers
      d "Actualizar s/a 404: ", response.code, headers, body
      expect_unauthorized

      delete not_found_url, api_base_headers
      d "Eliminar s/a 404: ", response.code, headers, body
      expect_unauthorized

      info '----------------------- * 5 Operaciones sin auth, en urls no existentes: OK'
    end
  end

  context 'with incomplete product data' do
    it 'fails to create' do
      new_product.delete(:name)
      authorized_put new_product[:id], new_product
      d "Put incompleto: ", response.code, headers, body
      expect(response.code).to be_between(400,499)
      info '----------------------- * 6 Falla creacion con producto incompleto: OK'
    end
  end

  context 'with different product id' do
    it 'fails to create' do
      authorized_put another_product_url, new_product
      d "Put wrong url:", response.code, headers, body
      expect(response.code).to be_between(400,499)
      info '----------------------- * 7 Falla creacion con id incorrecto: OK'
    end

    it 'fails to update via patch' do
      authorized_patch sample_product_url, {id: another_product_url}
      d "change id patch:", response.code, headers, body
      expect(response.code).to be_between(400,499)
      info '----------------------- * 8 Falla actualizacion de id via PATCH: OK'
    end
  end

  context 'with partial body content' do
    it 'fails to PUT update' do
      authorized_put sample_product_url, {name: sample_product_url, description: Faker::Name.name}
      d "partial PUT change:", response.code, headers, body
      expect(response.code).to be_between(400,499)
      info '----------------------- * 9 Falla PUT parcial de actualizacion: OK'
    end
  end

  context 'with unexistent product url' do
    it 'fails to get with 404' do
      authorized_get another_product_url
      d "get not found:", response.code, headers, body
      expect_status 404
      info '----------------------- * 10 Falla GET no existente: OK'
    end

    it 'fails to update with 404' do
      authorized_patch new_product[:id], new_product
      d "update not found:", response.code, headers, body
      expect_status 404
      info '----------------------- * 11 Falla PATCH no existente: OK'
    end

    it 'fails to delete with 404' do
      authorized_delete new_product[:id]
      d "delete not found:", response.code, headers, body
      expect_status 404
      info '----------------------- * 12 Falla DELETE no existente: OK'
    end
  end

  context 'after other tests' do
    it 'full listing again' do
      final_storage = []
      products_list.map do |product_url|
        authorized_get product_url
        final_storage << json_body
      end

      d "storage initial vs final (length): #{test6_storage.length} vs #{final_storage.length}"
      expect(final_storage).to match_array(test6_storage)

      info '----------------------- * 13 Full listing final sin cambios: OK'
    end
  end

end