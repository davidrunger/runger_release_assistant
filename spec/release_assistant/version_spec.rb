# frozen_string_literal: true

RSpec.describe 'ReleaseAssistant::VERSION' do
  it 'is not nil' do
    expect(ReleaseAssistant::VERSION).not_to eq(nil)
  end
end
