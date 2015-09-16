require 'bundler/setup'
Bundler.setup

require 'fiware-orion-geo'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end
end

def parse_orion_response(body)
  body_parsed = JSON.parse(body)
  body_parsed['contextResponses']
end

def create_test_notes(notes_data)
  notes_data.each do |data|
    options = {
      headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'  },
      body: {
        contextElements: [
          {
            type: 'testnotes',
            isPattern: false,
            id: data[:id],
            attributes: [
              {
                name: 'position',
                type: 'coords',
                value: "#{data[:lat]}, #{data[:long]}",
                metadatas: [
                  {
                    name: 'location',
                    type: 'string',
                    value: 'WGS84'
                  }
                ]
              }
            ]
          }
        ],
        updateAction: 'APPEND'
      }.to_json
    }
    HTTParty.post('http://test02.notegraphy.com:1026/v1/updateContext', options)
  end
end

def delete_test_notes(notes_ids)
  notes_ids.each do |id|
    options = {
      headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'  },
      body: {
        contextElements: [
          {
            type: 'testnotes',
            isPattern: false,
            id: id,
          }
        ],
        updateAction: 'DELETE'
      }.to_json
    }
    HTTParty.post('http://test02.notegraphy.com:1026/v1/updateContext', options)
  end
end