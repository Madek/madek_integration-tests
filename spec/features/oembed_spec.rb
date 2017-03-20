require 'spec_helper'

# NOTE: uses personas data! (hardcoded expectations)
VIDEO_ENTRY = '/entries/924057ea-5f9a-4a81-85dc-aa067577d6f1'.freeze
PRIVATE_ENTRY = '/entries/c22b6f3f-55ff-4e56-86f9-233af6f4cdc8'.freeze

# NOTE: this should be in integration-tests,
# but it's only important once there are settings (in Admin UI)

BASE_URL = URI.parse(Capybara.app_host).freeze

feature 'App: Embedding' do
  # config:
  OEMBED_REQUIRED_KEYS = %i(type version height).freeze
  OEMBED_TYPES = %w(photo video link rich).freeze
  API_URL = BASE_URL.merge('/oembed').to_s.freeze

  example 'oEmbed discovery link from Resource detail page' do
    LINK_TYPE = 'application/json+oembed'.freeze
    EXPECTED_LINK = {
      rel: 'alternate',
      href: full_url('/oembed?url=%2Fentries%2F924057ea-5f9a-4a81-85dc-aa067577d6f1'),
      title: 'A public movie to test public viewing oEmbed Profile'
    }.freeze

    visit VIDEO_ENTRY
    node = find("head link[type=\"#{LINK_TYPE}\"]", visible: false)
    expect(node).to be
    link = [:rel, :href, :title].map { |prop| [prop, node[prop]] }.to_h

    expect(link).to eq(EXPECTED_LINK)
  end

  describe 'oEmbed API:' do
    # types:
    example '`video` type' do
      REQUIRED_KEYS = [:html, :width, :height, :title].freeze
      response = get_json(
        set_params_for_url(
          API_URL, url: full_url(VIDEO_ENTRY)))

      expect_valid_oembed_response(response)
      REQUIRED_KEYS.each do |key|
        expect(response[:body][key]).to be_present, "missing prop: #{key}"
      end
      expect(response[:body][:title]).to eq 'A public movie to test public viewing'
      expect(response[:body][:width]).to eq 620
      expect(response[:body][:height]).to eq 403
      expect(response[:body][:provider_name]).to eq 'Media Archive'
      expect(response[:body][:provider_url]).to eq full_url('')
      expect(response[:body][:html]).to include '</iframe>'
      expect(response[:body][:html]).to include 'src="' + full_url('/entries/924057ea-5f9a-4a81-85dc-aa067577d6f1/embedded?maxheight=403&maxwidth=620') + '"'
    end

    # example '`photo` type' # embed images?

    # example '`link` type' do
    #   use case: person links with name
    #   TODO: try out what wordpress does with this, ideally link with text.
    #   spec: "return any generic embed data (such as title and author_name)"
    #   *without providing either the url or html parameters*
    #   The consumer may then link to the resource,
    #   using the URL specified in the original request.
    # end

    # example '`rich` type' # use case? metadata listings?

    # params:

    # NOTE: more thorough sizing spec in `webapp`!
    it 'supports the `maxwidth` param' do
      max_width = 500
      response = get_json(
        set_params_for_url(
          API_URL, maxwidth: max_width, url: full_url(VIDEO_ENTRY)))

      expect_valid_oembed_response(response)
      expect(response[:body][:width]).to be <= max_width.to_i
    end

    it 'supports the `maxheight` param' do
      max_height = 500
      response = get_json(
        set_params_for_url(
          API_URL, maxheight: max_height, url: full_url(VIDEO_ENTRY)))

      expect_valid_oembed_response(response)
      expect(response[:body][:height]).to be <= max_height.to_i
    end

    it 'supports the `format` param' do
      response = get_json(
        set_params_for_url(
          API_URL, format: 'json', url: full_url(VIDEO_ENTRY)))

      expect_valid_oembed_response(response)
    end

    # errors:

    it 'returns error when URL in url `param` is not supported' do
      response = get_json(
        set_params_for_url(API_URL, url: '/my'))
      expect(response[:status]).to be 422
    end

    it 'returns error when resource is not found by url `param`' do
      response = get_json(
        set_params_for_url(API_URL, url: full_url('/entries/does_not_exist')))
      expect(response[:status]).to be 404
    end

    it 'only supports "public" resources, returns correct error' do
      response = get_json(
        set_params_for_url(API_URL, url: full_url(PRIVATE_ENTRY)))
      expect(response[:status]).to be 401
    end

    it 'does not support XML format, returns correct error' do
      response = get_json(
        set_params_for_url(
          API_URL, url: full_url(VIDEO_ENTRY), format: 'xml'))
      expect(response[:status]).to be 501
    end
  end

  private

  def expect_valid_oembed_response(response)
    expect(response[:status]).to be 200
    expect(response[:headers]['content-type']).to \
      match_array ['application/json; charset=utf-8']
    expect(response[:body][:version]).to eq '1.0'
    expect(OEMBED_TYPES).to include(response[:body][:type])
  end

  def get_json(url)
    res = Net::HTTP.get_response(URI.parse(url))
    {
      status: res.code.to_i,
      headers: res.to_hash,
      body: JSON.parse(res.body).deep_symbolize_keys
    }
  end

  def set_params_for_url(url, params)
    URI.parse(url)
      .tap { |u| u.query = CGI.parse(u.query || '').deep_merge(params).to_query }
      .to_s
  end

  def full_url(path)
    BASE_URL.merge(path).to_s
  end

end
