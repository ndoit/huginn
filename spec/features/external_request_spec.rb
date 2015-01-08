require 'spec_helper'

describe 'External request' do
  it 'has access to muninn api' do
    uri = URI('http://localhost:3000/')

    response = Net::HTTP.get(uri)

    expect(response).to be_an_instance_of(String)
  end

  it 'can grab datasets from muninn' do
    uri = URI('http://localhost:3000/datasets')
    response = Net::HTTP.get(uri)
    expect(response).to be_an_instance_of(String)
  end


end