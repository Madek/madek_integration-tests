require 'nrepl'

module Helpers
  module Misc
    def api_click_on_relation_method(rel_name, method_name)
      wait_until(10){first("[data-relation-name=\"#{rel_name}\"]")}
      find("[data-relation-name=\"#{rel_name}\"]")
        .find('.methods').find('a, button', text: method_name).click
    end

    def login_as_database_user(login: 'adam', password: 'password')
      fill_in 'email-or-login', with: login
      click_on "Anmelden"
      fill_in 'password', with: password
      click_on "Anmelden"
    end

    def wait_until(wait_time = 60)
      Timeout.timeout(wait_time) do
        sleep(0.1) until value = yield
        value
      end
    end

    def api_nrepl(code)
      port = Integer(ENV['API_NREPL_PORT'].presence || 7802)
      _eval_clj_via_nrepl(port, code)
    end

    def extract_uuid(str)
      uuid_regex = /\b[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\b/
      str[uuid_regex]
    end
  end
end

private

def _eval_clj_via_nrepl(port, code)
  repl = Nrepl::Repl.connect(port)
  res = repl.eval code
  res.select{|r| r["ex"].present?}.map{|err| raise err["ex"]} # if failed
  res.map {|o| o['value']}.compact.first # if ok
end
