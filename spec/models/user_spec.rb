# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(User) do
  it { should have_many(:issues) }
end
