module Helpers
  module MockApiClient

    def prepare_mock_api_client
      visit 'about:blank'
      execute_script(JS_TEST_ENV)
    end

    def ajax_cors_test(url, token = '')
      execute_script("ajaxCorsTest('GET', '#{url}', '#{token}')")
      wait_until(10) { page.has_content?(JS_TEST_RESULT_MARKER) }
      text = page.find('#log').text
      index = text.rindex(JS_TEST_RESULT_MARKER) + JS_TEST_RESULT_MARKER.length
      JSON.parse(text[index...-1] + '}')['data']
    end

    JS_TEST_RESULT_MARKER = 'Result: '

    JS_TEST_ENV = <<-JS.strip_heredoc
      window.document.body.innerHTML = '<pre id="log"></pre>'

      function log (str) {
        var logEl = window.document.getElementById('log')
        var txt = logEl.innerHTML
        logEl.innerHTML = txt + str + '\\n'
      }

      function getResponse (a) {
        var res
        var msg = {}
        if (a && a.target && a.target) {
          res = a.target
          msg = {
            status: res.status,
            statusText: res.statusText,
            responseURL: res.responseURL,
            responseType: res.responseType
          }
          try {
            msg.body = JSON.parse(res.response)
          } catch (e) { msg.body = res.response }
        }
        return msg
      }

      window.ajaxCorsTest = function (method, url, token) {
        log('doing ajax cors request: ' + JSON.stringify({url: url, token: token}))
        var xhr = new XMLHttpRequest()
        xhr.open(method, url, true)

        xhr.onload = function(r) {
          log('Result: ' + (JSON.stringify({state: 'OK', data: getResponse(r)})))
        }

        xhr.onerror = function(r) {
          log('Result: ' + (JSON.stringify({state: 'Error', data: getResponse(r)})))
        };

        xhr.setRequestHeader('Accept', 'application/json')

        if (token) {
          xhr.setRequestHeader('Authorization', 'token ' + token)
        }
        xhr.send()
      }
    JS

  end
end
