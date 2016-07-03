require 'base64'
require 'logger'
require 'yaml'
require 'singleton'
require 'products_list_mapper'



class Config
  include Singleton

  attr_reader :logger, :url_regex,
              :group, :products_url, :user, :pass,
              :products_list_mapper, :expiration_header_names

  def initialize
    load_config_from_file
    init_logger
    init_group_data
    init_other_options

    logger.info "==================== Testing group #{'%3s' % group} ===================="

  end

  def auth_header_value
    @basic_auth_header_value
  end

  def content_type_header_value
    'application/json'
  end


  private

  DEFAULTS = {
    config_file: 'config.yml',
    log_level: :info,
    # regex muy simple que solo verifica que algo inicie con http:// o https://
    url_regex: /^(http|https):\/{2}.+/,
    # Mapear el listado de productos?
    products_list_mapper: false,
    expiration_header_names: ['Last-Modified', 'ETag']
  }



  def load_config_from_file
    @config_source = YAML.load_file(DEFAULTS[:config_file])
  end

  def source
    @config_source
  end

  # init logger with one of these levels
  # :unknown - :debug - :info - :warn - :error - :fatal
  # defaults to unknown (logs ALL)
  def init_logger
    level = ENV['LOG_LEVEL'] || source['log_level'] || DEFAULTS[:log_level]

    i_level = case level.downcase.to_s
      when 'fatal' then Logger::FATAL
      when 'error' then Logger::ERROR
      when 'warn' then Logger::WARN
      when 'info' then Logger::INFO
      when 'debug' then Logger::DEBUG
      else Logger::UNKNOWN
    end
    @logger = Logger.new(STDOUT).tap{|logger| logger.level = i_level }
  end


  def group_data
    @group_data
  end

  def find_and_set_group_data
    group_number = (ENV['GROUP'] || source['group']).to_s

    if !group_number.empty?
      # busquemos el grupo en la lista de grupos
      group_data = source['groups'].find{|g| g['group'].to_s == group_number }
    end

    if group_data.nil?
      msg = "Group #{group_number} not found. Please check 'config.yml' file."
      logger.fatal msg
      raise msg
    end

    @group_data = group_data
  end

  def normalized_products_url
    normalized_products_url = group_data['products_url']
    if normalized_products_url.end_with? '/'
      # we need to remove trailing /
      normalized_products_url = normalized_products_url.chop
    end
    normalized_products_url
  end

  def init_group_data
    find_and_set_group_data

    @group = group_data['group']
    @products_url = normalized_products_url
    @user = group_data['user']
    @pass = group_data['pass']

    @basic_auth_header_value = "Basic #{Base64.strict_encode64("#{user}:#{pass}")}"


    set_expiration_header_names

    set_products_list_mapper

  end

  def set_expiration_header_names
    expiration_header_names = group_data['expiration_header_names'] || DEFAULTS[:expiration_header_names]
    expiration_header_names = expiration_header_names.map{|name| name.downcase }
    @expiration_header_names = expiration_header_names
  end

  def set_products_list_mapper
    products_list_mapper = group_data['products_list_mapper'] || DEFAULTS[:products_list_mapper]


    if products_list_mapper != false

      mapper_name = products_list_mapper == true ? 'default' : products_list_mapper.downcase

      mapper = ProductsListMapper::MAPPERS[mapper_name]

      if mapper.nil?
        msg = "Error configurando grupo #{group}: products_list_mapper '#{products_list_mapper}' desconocido"
        logger.fatal msg
        raise msg
      end

      @products_list_mapper = mapper


      logger.warn do
        es_mapper_name = if products_list_mapper == true
          'predeterminado - no descuenta puntaje'
        else
          "'#{products_list_mapper}' - APLICA DESCUENTO"
        end
        "Atencion: permitiendo la transformacion del listado de productos (transformador #{es_mapper_name})"
      end
    end


  end

  def init_other_options
    @url_regex = source['url_regex'] || DEFAULTS[:url_regex]

  end

end