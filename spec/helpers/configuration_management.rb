require 'rest-client'

module Helpers
  module ConfigurationManagement
    class << self
      def invoke_ruby(ruby_string)
        request = RestClient::Request.new(
          method: :post,
          url: Capybara.app_host +
            '/configuration_management_backdoor/invoke',
          user: 'management',
          password: 'secret',
          verify_ssl: false,
          payload: ruby_string,
          headers: { content_type:  'application/ruby' })
        request.execute
      end

      def invoke_sql(sql_string)
        request = RestClient::Request.new(
          method: :post,
          url: Capybara.app_host +
            '/configuration_management_backdoor/invoke',
          user: 'management',
          password: 'secret',
          verify_ssl: false,
          payload: sql_string,
          headers: { content_type:  'application/sql' })
        request.execute
      end

      def execute_sql(sql_string)
        response = invoke_sql(sql_string)
        JSON.parse(response.body).deep_symbolize_keys[:result]
      end
    end
  end
end
