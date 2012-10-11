require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'date'
require 'rspec'

Capybara.run_server     = false
Capybara.current_driver = :selenium
Capybara.app_host       = 'http://sysdev/devroot/alexa/library/about/events/admin2'

module MyCapybaraTest
  class Test
    include Capybara


    def sign_in
      visit('/')
      fill_in 'Username', with: 'alexa'
      fill_in 'Password', with: 'alexa10'
      click_button 'Login'
    end

    def user_gogromat
      page.execute_script("$('#host_id').val('915');");
    end

    def fill_in_event_fields
      fill_in 'event_name',      with: 'Selenium'
      fill_in 'description',     with: 'Automated test'
      fill_in 'notes',           with: 'Automated test'
      select '1', from: 'participants'
      page.choose('Yes')
      page.execute_script("$('#public_categories_label').click();");
      check 'Academic Events'
    end

    def fill_in_recurrence_fields
      fill_in 'recurrence_name', with: 'Selenium'       
    end

    def fill_in_days_of_the_week 
      Date::ABBR_DAYNAMES.each do |day|
        check "#{day}"
      end 
    end

    def submit_and_wait
      click_on 'Save'
      sleep(3000)
    end

    def add_recurrence
      sign_in
      visit ('?view=recurrences')
      click_button 'Add Recurrence Event'  
      user_gogromat
      fill_in_event_fields
      fill_in_recurrence_fields
      fill_in_days_of_the_week
      submit_and_wait
    end

    def add_event
      sign_in
      visit ('?view=events')
      click_button 'Add Event'
      user_gogromat  
      fill_in_event_fields
      submit_and_wait
    end

    def add_block
      sign_in
      visit ('?view=blocks')
      click_button 'Block a Room'
      #todo: fill in rooms
      #      fill in time
      fill_in 'Label', with: 'Automated test'
      fill_in 'notes', with: 'Automated test'
      fill_in_days_of_the_week
      submit_and_wait
    end

  end
end


t = MyCapybaraTest::Test.new
t.add_recurrence