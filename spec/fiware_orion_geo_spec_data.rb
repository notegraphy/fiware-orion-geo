class FiwareOrionGeoSpecData

  def get_circle
    {
      circle: {
        centerLatitude: 2,
        centerLongitude: 3,
        radius: 2
      }
    }
  end

  def get_polygon
    {
      polygon: {
        vertices: [
          {
            latitude: '1',
            longitude: '2'
          },
          {
            latitude: '4',
            longitude: '5'
          },
          {
            latitude: '3',
            longitude: '2'
          }
        ]
      }
    }
  end

  def note_response(attr=true, coords=nil)
    json = {
      type: 'testnotes',
      isPattern: 'false',
      id: '1'
    }
    if attr === true
      value = coords.nil? ? '': coords
      json[:attributes] = [
        {
          name: 'position',
          type: 'coords',
          value: value,
          metadatas:[
            {
              name: 'location',
              type: 'string',
              value: 'WSG84'
            }
          ]
        }
      ]
    end
    json.to_json
  end

  def get_list_note_data(id)
    [
      { id: id, lat: 2.1589760, long: 41.3888000},
      { id: id + 1, lat: 2.1589760, long: 41.3888000},
      { id: id + 2, lat: 2.1589760, long: 41.3888000}
    ]
  end
end