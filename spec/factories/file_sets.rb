# spec/factories/file_sets.rb
FactoryBot.define do
    factory :file_set do
      # suponiendo que FileSet tiene los atributos `title` y `description`
      title { ["Example Title"] }
      description { ["Example description of the file set."] }
      # Agrega otros atributos necesarios para un objeto válido
    end
  end
  