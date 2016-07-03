
describe 'test 5' do

  before :all do
    puts '' if logger.info?
    info '----------------- Test 5 (total: 6 pasos) -----------------'
  end

  ##
  # Esta prueba deberia separarse en 2, pero debido a que es destructiva
  # y su contraparte - la creacion exitosa - en pruebas preliminares ha
  # sido un tanto "esquiva" (dicese que  pocos de mis grupos de prueba
  # la completan bien), preferi reducirlo al minimo posible
  it 'deletes a product - and only one time' do
    product_url = get_products_list.sample
    info '----------------------- * Listado: OK'

    # el producto

    authorized_get product_url
    product = json_body
    info '----------------------- * Producto: OK'

    d "Sample product for be deleted: ", product

    authorized_delete product_url
    d 'delete response:', response.code, headers, body

    expect_success
    info '----------------------- * Eliminacion: OK'

    updated_product_list = get_products_list

    expect(updated_product_list).not_to include(product_url)

    info '----------------------- * Nuevo listado sin el producto eliminado: OK'



    # chequeo de idempotencia

    authorized_delete product_url
    d 'delete again response:', response.code, headers, body

    expect_success
    info '----------------------- * Nuevo DELETE (idempotencia): OK'

    again_updated_product_list = get_products_list

    d "quantity of products on idempotent delete (should be the same): #{updated_product_list.length} -> #{again_updated_product_list.length}"
    expect(again_updated_product_list).to match_array(updated_product_list)

    info '----------------------- * Listado (chequeo de idempotencia): OK'
  end

end