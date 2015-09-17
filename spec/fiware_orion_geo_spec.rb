require 'spec_helper'
require 'fiware_orion_geo_spec_data'

describe 'Endpoints Orion server' do

  before(:all) do
    @sut = Orion::Geo.new('http://test02.notegraphy.com:1026', 21)
    @data = FiwareOrionGeoSpecData.new
  end

  describe 'Create an entity' do

    before(:all) do
      @id = 1
      data = [
        { type: 'coord', data: {lat: 2.1589760, long: 41.3888000}},
        { type: 'attr', data: {name: 'name', type: 'string', value: 'Note test'}}
      ]
      @response = @sut.create('testnotes', @id, data)
      @context_response = parse_orion_response(@response.body).first
    end

    it 'should return the request' do
      expect(@context_response['contextElement'].to_json).to eq(@data.note_response)
    end

    it 'should return 200' do
      expect(@context_response['statusCode']['code']).to eq(200.to_s)
    end

    after(:all) do
      delete_test_notes([@id])
    end

  end

  describe 'Delete an entity' do

    before(:all) do
      @id = 1
      create_test_notes([{ id: @id, lat: 2.1589760, long: 41.3888000}])
      @response = @sut.delete('testnotes', @id)
      @context_response = parse_orion_response(@response.body).first
    end

    it 'should return the request' do
      expect(@context_response['contextElement'].to_json).to eq(@data.note_response(false))
    end

    it 'should return 200' do
      expect(@context_response['statusCode']['code']).to eq(200.to_s)
    end

    after(:all) do
      delete_test_notes([@id])
    end

  end


  describe 'Update an entity' do

    before(:all) do
      @id = 1
      data = [
        { type: 'coord', data: {lat: 2.1689760, long: 42.3888000}},
        { type: 'attr', data: {name: 'name', type: 'string', value: 'Note test'}}
      ]
      create_test_notes([{ id: @id, lat: 2.1589760, long: 41.3888000}])
      @response = @sut.update('testnotes', @id, data)
      @context_response = parse_orion_response(@response.body).first
    end

    it 'should return 200' do
      expect(@context_response['statusCode']['code']).to eq(200.to_s)
    end

    after(:all) do
      delete_test_notes([@id+1])
    end

  end

  describe 'Get an entity' do

    before(:all) do
      @id = '1'
      create_test_notes([{ id: @id, lat: 2.1589760, long: 41.3888000}])
      @response = @sut.get('testnotes', @id)
      @context_response = parse_orion_response(@response.body).first
    end

    it 'should return the entity' do
      expect(@context_response['contextElement'].size).to eq(4)
    end

    it 'should return 200' do
      expect(@context_response['statusCode']['code']).to eq(200.to_s)
    end

    after(:all) do
      delete_test_notes([@id])
    end

  end

  describe 'Get all the entities' do

    before(:all) do
      @id = 1
      @data_req = @data.get_list_note_data(@id)
      create_test_notes(@data_req)
      @response = @sut.get_all('testnotes')
      @context_response = parse_orion_response(@response.body)
    end

    it 'should return the entityes' do
      @context_response.each do |el|
        expect(el['contextElement'].size).to eq(4)
      end
    end

    it 'should return the length' do
      expect(@context_response.length).to eq(@data_req.length)
    end

    it 'should return 200' do
      @context_response.each do |el|
        expect(el['statusCode']['code']).to eq(200.to_s)
      end
    end

    after(:all) do
      delete_test_notes([@id, @id + 1,  @id + 2])
    end

  end

  describe 'Get all the entities by position' do

    before(:all) do
      @id = 1
      @data_req = @data.get_list_note_data(@id)
      create_test_notes(@data_req)
      @response = @sut.get_by_position('testnotes', 'circle', [2.1589760, 41.3888000, 10000])
      puts @response.inspect
      @context_response = parse_orion_response(@response.body)
    end

    it 'should return the entityes' do
      @context_response.each do |el|
        expect(el['contextElement'].size).to eq(4)
      end
    end

    it 'should return the length' do
      expect(@context_response.length).to eq(@data_req.length)
    end

    it 'should return 200' do
      @context_response.each do |el|
        expect(el['statusCode']['code']).to eq(200.to_s)
      end
    end

    after(:all) do
      delete_test_notes([@id, @id + 1,  @id + 2])
    end

  end

  describe 'Get area(private method)' do

    context 'build a area' do

      it 'should return circle' do
        actual = @sut.instance_eval{get_area('circle', [2,3,2])}
        expected = @data.get_circle
        expect(actual).to eq(expected)
      end

      it 'should return a polygon' do
        actual = @sut.instance_eval{get_area('polygon', %w(1,2 4,5 3,2))}
        expected = @data.get_polygon
        expect(actual).to eq(expected)
      end

    end

  end

end