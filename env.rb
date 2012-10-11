=begin
    
    This env.rb will use capybara-mechanize by default and capybara's normal selenium 2 (webdriver) driver for
    cucumber tests tagged with @javascript.
    
    It also helps you pass your tests on to a selenium 2 grid, with some extra bits specifically for SauceLabs
    (which it uses as a remote selenium 2 grid).

    
    Environment variables you can set:

    MHT_HOST=domain.com ... the host to test, default is WWW.YOURDOMAIN.COM
    MHT_DRIVER='mechanize' ... default capybara driver to use, valid values are:
        mechanize,
        celerity,
        chrome,
        culerity,
        selenium,
        rack_test
    MHT_JAVASCRIPT_DRIVER='selenium' ... javascript capybara driver to use, valid values are:
        selenium [selenium server]
        webkit [uses headless webkit]
        webdriver [remote webdriver, aka Sauce Labs]
    MHT_WAIT_TIME=6 ... the number of seconds to wait for things to load
    MHT_OS='ANY' ... OS to use for remote webdriver, valid values are:
        ANDROID
        ANY
        LINUX
        MAC
        UNIX
        VISTA
        WINDOWS
        XP
    MHT_BROWSER=browser_name ... the browser driver to use, default is firefox, valid values are:
        firefox
        iexplore
        chrome
        android
    MHT_BROWSER_VERSION='5' ... browser version to use for remote webdriver, defaults to '5'
        (nb, if you specify something other than MHT_BROWSER='firefox' you will want to set this too!)
    MHT_REMOTE_WEBDRIVER=false ... URL of the remote webdriver hub, valid values are:
        false
        http://wd.com:80/wd/hub
        sauce [i.e. use Sauce Labs]
    MHT_SAUCE_USERNAME='SACELABS_USERNAME' ... Sauce Labs username
    MHT_SAUCE_ACCESS_KEY='SAUCELABS_KEY' ... Sauce Labs API Key
    MHT_SAUCE_JOB_NAME='SAUCELABS_JOBNAME' ... custom job name for Sauce Labs


    You have 3 options for setting environment variables (higher numbers below take precedence):
        1. System level (i.e. in "Computer -> Properties" on Windows, or in the terminal in Linux/OS X)
        2. Config level (i.e. by setting up a profile in cucumber.yml)
        3. Run level (i.e. by running "$ cucumber MHT_BROWSER=chrome")
=end



########### Global Requirements

require 'capybara/mechanize'
require 'capybara'
require 'capybara/cucumber'
require 'rspec'





########### Get Configuration

config = {
    'mht_host'              => ENV['MHT_HOST']              || 'sysdev/devroot/alexa/library/about/events/admin2',
    'mht_driver'            => ENV['MHT_DRIVER']            || 'mechanize',
    'mht_javascript_driver' => ENV['MHT_JAVASCRIPT_DRIVER'] || 'selenium',
    'mht_wait_time'         => ENV['MHT_WAIT_TIME']         || 6,
    'mht_os'                => ENV['MHT_OS']                || 'ANY',
    'mht_browser'           => ENV['MHT_BROWSER']           || 'firefox',
    'mht_browser_version'   => ENV['MHT_BROWSER_VERSION']   || '5',
    'mht_remote_webdriver'  => ENV['MHT_REMOTE_WEBDRIVER']  || 'http://127.0.0.1:4444/wd/hub',
    'mht_sauce_username'    => ENV['MHT_SAUCE_USERNAME']    || 'SAUCELABS_USERNAME',
    'mht_sauce_access_key'  => ENV['MHT_SAUCE_ACCESS_KEY']  || 'SAUCELABS_PASSWORD',
    'mht_sauce_job_name'    => ENV['MHT_SAUCE_JOB_NAME']    || 'SAUCELABS_JOBNAME'
}




########### Configure Capybara

# Create a "chrome" driver
Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
end
# Use the "chrome" driver if we specified "chrome" through the browser name
if ( config['mht_browser'] == 'chrome' && config['mht_driver'] == 'selenium' ) then
    config['mht_driver'] = 'chrome'
end

if ( config['mht_javascript_driver'] == 'webkit' )
    require 'capybara-webkit'
end

if config['mht_remote_webdriver'] then
    Capybara.register_driver :webdriver do |app|
        ## are we providing a remote webdriver URL or using Sauce Labs?
        if config['mht_remote_webdriver'] == 'sauce' then
            un = config['mht_sauce_username']
            ak = config['mht_sauce_access_key']
            remote_url = 'http://'+un+':'+ak+'@ondemand.saucelabs.com:80/wd/hub'
        else
            remote_url = config['mht_remote_webdriver']
        end
        ## create the options for the new Remote Capabilities object
        capabilities_opts = {
            :platform => config['mht_os'],
            :version => config['mht_browser_version'],
            :javascript_enabled => true,
            :css_selectors_enabled => true,
            :name => config['mht_sauce_job_name']
        }
        capabilities_opts[:browser_name] = config['mht_browser'] if config['mht_browser']
        capabilities_opts[:version] = config['mht_browser_version'] if config['mht_browser_version']
        # make the new Remote Capabilities object
        capabilities = Selenium::WebDriver::Remote::Capabilities.new(capabilities_opts)

        ## make the actual client
        client = Selenium::WebDriver::Remote::Http::Default.new

        ## make the opts for the new driver
        opts = {
            :url => remote_url,
            :desired_capabilities => capabilities,
            :http_client => client,
            :browser => :remote
        }

        ## make the new driver
        Capybara::Selenium::Driver.new(app,opts)
    end
end


Capybara.app_host = 'http://' + config['mht_host']
Capybara.default_driver = config['mht_driver'].to_sym
Capybara.javascript_driver = config['mht_javascript_driver'].to_sym
Capybara.default_wait_time = config['mht_wait_time']




########### Cucumber World

class TestserverWorld
  include RSpec::Expectations
  include RSpec::Matchers
end

World do
  TestserverWorld.new
end



