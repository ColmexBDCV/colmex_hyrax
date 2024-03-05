# Generated via
#  `rails generate hyrax:work BookChapter`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a BookChapter', js: true do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    before do
      # Create a single action that can be taken
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

      # Grant the user access to deposit into the admin set.
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'user',
        agent_id: user.user_key,
        access: 'deposit'
      )
      login_as user
          end

    scenario do
      visit '/dashboard'
      click_link "Works"
      click_link "Add New Work"

      # If you generate more than one work uncomment these lines
      choose "payload_concern", option: "BookChapter"
      click_button "Create work"
      
      expect(page).to have_content "Add New Book Chapter"
      click_link "Files" # switch tab
      expect(page).to have_content "Add Files"
      expect(page).to have_content "Add Folder"
      within('span#addfiles') do
        attach_file("files[]", "./spec/fixtures/image.jp2", visible: false)
        attach_file("files[]", "./spec/fixtures/jp2_fits.xml", visible: false)
      end
      click_link "Descriptions" # switch tab
      fill_in('Title', with: 'My Test Book Chapter')
      # fill_in('Creator', with: 'Doe, Jane')
      # fill_in('Keyword', with: 'testing')
      # select('In Copyright', from: 'Rights statement')

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can't find
      # its element
      find('body').click
      choose('book_chapter_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      check('agreement')

      click_on('Save')
      sleep 30
      
      expect(page).to have_content('My Test Book Chapter')
      expect(page).to have_content "Your files are being processed"
      
    end
  end
end
