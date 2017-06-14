require 'nrepl'

module Helpers
  module Misc
    def api_click_on_relation_method(rel_name, method_name)
      find("[data-relation-name=\"#{rel_name}\"]")
        .find('.methods').find('a, button', text: method_name).click
    end

    def login_as_database_user(login: 'adam', password: 'password')
      # if there are tabs, switch to system login
      if all('#login_menu [role="tablist"]').first
        click_link 'login_menu-tab-system'
      end
      within '#login_menu' do
        fill_in 'login', with: login
        fill_in 'password', with: password
        find('[type=submit]').click
      end
    end

    def wait_until(wait_time = 60)
      Timeout.timeout(wait_time) do
        sleep(0.1) until value = yield
        value
      end
    end

    def api_nrepl(code)
      port = Integer(ENV['EXECUTOR_NREPL_PORT'].presence || 7802)
      _eval_clj_via_nrepl(port, code)
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
