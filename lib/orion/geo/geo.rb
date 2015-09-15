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
    # long = Longitude
    # lat = latitude
    def create(type,id,long,lat)
      action = '/ngsi10/updateContext'
      @options[:body] = self.build_body(type, id, 'APPEND', false, [self.build_geo_attribute(lat, long)])
      self.call_orion(action, @options)
    end

    # type = type of data E.g: 'City'
    # id = id of the element
    # long = Longitude
    # lat = latitude
    def update(type,id,long,lat)
      action = '/ngsi10/updateContext'
      @options[:body] = self.build_body(type, id, 'UPDATE', false, [self.build_geo_attribute(lat, long)])
      self.call_orion(action, @options)
    end

    # type = type of data E.g: 'City'
    # id = id of the object
    def delete(type, id)
      action = '/ngsi10/updateContext'
      @options[:body] = self.build_body(type, id, 'DELETE')
      self.call_orion(action, @options)
    end

    def get(type, id)
      action = '/ngsi10/queryContext'
      @options[:body] = self.build_query(type)
      self.call_orion(action, @options)
    end

    def get_all(type)
      action = "/ngsi10/contextEntities?entity::type=#{type}&details=on"
      self.call_orion(action, {})
    end

    # type = type of data E.g: 'City'
    # type_area = 'circle' || 'polygon'
    #   - polygon: array_point = ['lat, long','lat, long','lat, long'] ----- infinite number of points
    #   - circle: array_point = ['lat, long, radius'] ----- radius in meters
    def get_by_position(type, type_area, array_point, limit = 999999)
      action = "/ngsi10/queryContext?limit=#{limit}&details=on"
      @options[:body] = self.build_query(type, get_area(type_area, array_point))
      self.call_orion(action, @options)
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

    def call_orion(action, options)
      HTTParty.post(@url + action, options)
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
      json[:contextElements].first[:attributes] = attributes unless attributes.nil?
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

  end
end