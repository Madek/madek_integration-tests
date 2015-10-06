module Helpers
  module Misc
    def api_click_on_relation_method(rel_name, method_name)
      find('tr.relation-row .rel-name', text: /^\s*#{rel_name}\s*$/) \
        .find(:xpath, '..').find('a', text: method_name).click
    end
  end
end
