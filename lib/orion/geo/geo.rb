require 'httparty'

module Orion
  class Geo

    def initialize(server_ip, limit = nil)
      config = Orion::Config::load_config(server_ip, limit)
      @url = config[:orion_url]
      @options = {
          body: nil,
          headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'  }
      }
    end

    # type = type of data E.g: 'City'
    # id = id of the element
    # attr = array of hashes with the following structure [{ :type => coord | attr, :data => {} }]
    # If the type is corrd :attr_data follows this format { :long, :lat }
    # If the type is attr :attr_data follows this format { :name, :type, :value }
    def create(type, id, attr)
      action = '/v1/updateContext'
      @options[:body] = build_body(type, id, 'APPEND', false, build_attributes(attr))
      call_orion('post', action, @options)
    end

    # type = type of data E.g: 'City'
    # id = id of the element
    # attr = array of hashes with the following structure [{ :type => coord | attr, :data => {} }]
    # If the type is corrd :attr_data follows this format { :long, :lat }
    # If the type is attr :attr_data follows this format { :name, :type, :value }
    def update(type, id, attr)
      action = '/v1/updateContext'
      @options[:body] = build_body(type, id, 'UPDATE', false, build_attributes(attr))
      call_orion('post', action, @options)
    end

    # type = type of data E.g: 'City'
    # id = id of the object
    def delete(type, id)
      action = '/v1/updateContext'
      @options[:body] = build_body(type, id, 'DELETE')
      call_orion('post', action, @options)
    end

    def get(type, id)
      action = '/v1/queryContext?details=on'
      @options[:body] = build_query(type, nil, id)
      call_orion('post', action, @options)
    end

    def get_all(type)
      action = "/v1/contextEntityTypes/#{type}?details=on"
      opt = { headers: { 'Accept' => 'application/json' } }
      call_orion('get', action, opt)
    end

    # type = type of data E.g: 'City'
    # type_area = 'circle' || 'polygon'
    #   - polygon: array_point = ['lat, long','lat, long','lat, long'] ----- infinite number of points
    #   - circle: array_point = ['lat, long, radius'] ----- radius in meters
    def get_by_position(type, type_area, array_point, limit = 1000)
      action = "/v1/queryContext?limit=#{limit}&details=on"
      @options[:body] = build_query(type, get_area(type_area, array_point))
      call_orion('post', action, @options)
    end

    private

    # type_area = 'circle' || 'polygon'
    #   - polygon: array_point = ['lat, long','lat, long','lat, long'] ----- infinite number of points
    #   - polygon: array_point = [lat, long, radius] ----- radius in meters
    def get_area(type_area, array_point)
      if type_area == 'circle'
        area = { circle: { centerLatitude: array_point[0],  centerLongitude: array_point[1],  radius: array_point[2] } }
      else
        points = []
        array_point.each do |c|
          c = c.split(',')
          points << { latitude: c[0], longitude: c[1] }
        end
        area = { polygon: { vertices: points } }
      end
      area
    end

    def call_orion(http_action, action, options)
      if http_action == 'get'
        HTTParty.get(@url + action, options)
      elsif http_action == 'post'
        HTTParty.post(@url + action, options)
      end
    end

    def build_body(type, id, action, pattern = false, attributes = nil)
      json = {
        contextElements: [
          {
            type: type,
            isPattern: pattern,
            id: id,
          }
        ],
        updateAction: action
      }
      json[:contextElements].first[:attributes] = attributes unless attributes.nil? || attributes.empty?
      json.to_json
    end

    def build_query(type, area = nil, id = nil)
      pattern, id = (id.nil?) ? %w(true .*) : ['false', id]
      json = { entities: [ { type: type, isPattern: pattern, id: id } ] }
      json[:restriction] = { scopes: [ { type: 'FIWARE::Location', value: area } ] } unless area.nil?
      json.to_json
    end

    def build_geo_attribute(lat, long)
      { name: 'position', type: 'coords',
        value: "#{lat}, #{long}", metadatas: [ { name: 'location', type: 'string', value: 'WSG84' } ]
      }
    end

    def build_default_attribute(name, type, value)
      { name: name, type: type, value: value }
    end

    def build_attributes(attr_data)
      attr = []
      attr_data.each do |a|
        data = a[:data]
        if a[:type] == 'coord'
          attr.push(build_geo_attribute(data[:lat], data[:long]))
        else
          attr.push(build_default_attribute(data[:name], data[:type], data[:value]))
        end
      end
      attr
    end

  end
end