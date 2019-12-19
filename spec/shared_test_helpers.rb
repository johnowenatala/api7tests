require 'config'

module SharedTestHelpers

  def config
    Config.instance
  end

  def logger
    config.logger
  end

  # shortcuts utils para log!

  def info(*args,&block)
    if args.length <= 1
      logger.info(*args,&block)
    else
      logger.info(args,&block)
    end
  end

  def debug(*args,&block)
    if logger.debug?
      puts # siempre imprimo un salto de linea para limpieza
      if args.length <= 1
        logger.debug(*args,&block)
      else
        logger.debug(args,&block)
      end
    end
  end
  alias :d :debug

  # ====== METODOS HTTP ======

  def authorized_get(url)
    get url, api_auth_base_headers
  end

  def authorized_head(url)
    head url, api_auth_base_headers
  end

  def authorized_put(url, content)
    put url, content, api_auth_base_headers
  end

  def authorized_patch(url, content)
    patch url, content, api_auth_base_headers
  end

  def authorized_delete(url)
    delete url, nil, api_auth_base_headers
  end

  # helpers de mas alto nivel

  def get_products_list
    authorized_get(config.products_url)
    mapped_products
  end

  def mapped_products
    all = json_body

    if ! config.products_list_mapper.nil?
      all = config.products_list_mapper.call(all)
    end

    all
  end

  def expiration_headers
    headers.select{|k,_| config.expiration_header_names.include?(k.downcase) }
  end

  def expiration_headers!
    filtered_headers = expiration_headers
    if filtered_headers.empty?
      msg = "No hay encabezados conocidos para confirmar cuando cambia el producto!"
      d msg, "encabezados disponibles:", headers
      raise msg
    end
    filtered_headers
  end

  def expect_success
    # s_20 = (200..204).to_a
    # if response.code.is_a? String
    #   s_20 = s_20.map(&:to_s)
    # end
    #
    # expect(response.code).to eq(s_20[0]).or eq(s_20[1]).or eq(s_20[2]).or eq(s_20[3]).or eq(s_20[4])
    if body.nil? || body.empty?
      expect_status 204 # no content
    else
      expect_status 200 # ok
    end
  end

  def expect_unauthorized(allow_403 = true)
    if !allow_403
      expect_status 401
      expect_header('WWW-Authenticate', 'Basic')
    else

      s_401 = 401
      s_403 = 403
      if response.code.is_a? String
        s_401 = s_401.to_s
        s_403 = s_403.to_s
      end

      expect(response.code).to eq(s_401).or eq(s_403)
    end
  end

  # customize!

  def custom_products_list_map(raw_products_list)
    raw_products_list.map{|e| e[:id]}
  end


  # headers

  def api_base_headers
    {
      'Accept' => config.content_type_header_value,
      'Content-Type' => config.content_type_header_value
    }
  end

  def api_auth_base_headers
    api_base_headers.merge({
      'Authorization' => config.auth_header_value
    })
  end


end