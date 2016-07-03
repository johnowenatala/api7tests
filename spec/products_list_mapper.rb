module ProductsListMapper

  MAPPERS = {
    'default' => lambda do |source_list|
      source_list.map do |object|
        if object.length > 1
          msg = "La lista de productos no puede ser mapeada por mapper default. Se esperan solo objetos de un par (clave,valor), pero hay esto: #{object.to_s}"
          raise msg
        end
        object.values.first
      end
    end,
    'id' => lambda do |source_list|
      source_list.map{|p| p[:id]}
    end
  }

end