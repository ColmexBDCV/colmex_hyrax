require 'rails_helper'

RSpec.describe User, type: :model do
  # Pruebas de validaciones básicas
  describe "validations" do
    it "is valid with valid attributes" do
      user = User.new(email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
      expect(user).to be_valid
    end

    it "is not valid without an email" do
      user = User.new(password: 'password123', password_confirmation: 'password123')
      expect(user).to_not be_valid
    end

    it "is not valid without a password" do
      user = User.new(email: 'test@example.com')
      expect(user).to_not be_valid
    end

    it "is not valid with a mismatched password confirmation" do
      user = User.new(email: 'test@example.com', password: 'password123', password_confirmation: 'wrongpassword')
      expect(user).to_not be_valid
    end
  end

  # Prueba para el método personalizado to_s
  describe "#to_s" do
    it "returns the user email as a string" do
      user = User.create(email: 'user@example.com', password: 'password123', password_confirmation: 'password123')
      expect(user.to_s).to eq 'user@example.com'
    end
  end

  # Pruebas para verificar la inclusión de módulos
  describe "module inclusion" do
    it "includes Hydra::User behaviors" do
      expect(User.included_modules.include?(Hydra::User)).to be true
    end

    it "includes Hydra::RoleManagement::UserRoles" do
      expect(User.included_modules.include?(Hydra::RoleManagement::UserRoles)).to be true
    end

    it "includes Hyrax::User" do
      expect(User.included_modules.include?(Hyrax::User)).to be true
    end

    it "includes Hyrax::UserUsageStats" do
      expect(User.included_modules.include?(Hyrax::UserUsageStats)).to be true
    end

    it "includes Blacklight::User" do
      expect(User.included_modules.include?(Blacklight::User)).to be true
    end

    it "includes Devise modules" do
      # As Devise includes multiple modules, just check for one or two key ones
      expect(User.included_modules.include?(Devise::Models::DatabaseAuthenticatable)).to be true
      expect(User.included_modules.include?(Devise::Models::Trackable)).to be true
    end
  end
end
