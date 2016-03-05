module Helpers
  module Misc
    def api_click_on_relation_method(rel_name, method_name)
      find("[data-relation-name=\"#{rel_name}\"]")
        .find('.methods').find('a, button', text: method_name).click
    end

    def wait_until(wait_time = 60)
      Timeout.timeout(wait_time) do
        sleep(0.1) until value = yield
        value
      end
    end
  end
end
