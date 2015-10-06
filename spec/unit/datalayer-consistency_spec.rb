require 'spec_helper'
require 'git'

describe 'The datalayer of the Webapp and the API' do
  def commit_id(path)
    sha = Git.open(path).object('HEAD').sha
    fail "'#{sha}' is not a valid object id" unless sha =~ /^[0-9a-fA-F]{40}$/
    sha
  end

  it 'Reference exactly the same commit' do
    expect(commit_id('../webapp/engines/datalayer')).to \
      be == commit_id('../api/datalayer')
  end
end
