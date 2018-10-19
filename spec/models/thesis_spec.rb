# Generated via
#  `rails generate hyrax:work Thesis`
require 'rails_helper'

RSpec.describe Thesis do
  # it "has tests" do
  #   skip "Add your tests here"
  # end
  describe "the object's properties for conacyt" do
    subject { Thesis.new }
    it { is_expected.to respond_to(:creator_conacyt) }
    it { is_expected.to respond_to(:contributor_conacyt) }
    it { is_expected.to respond_to(:subject_conacyt) }
    it { is_expected.to respond_to(:pub_conacyt) }
  end
end
