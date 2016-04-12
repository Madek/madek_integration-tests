require 'spec_helper'
require 'git'

describe 'The datalayer of the Webapp, Admin Webapp and the API' do
  def commit_id(path)
    sha = Git.open(path).object('HEAD').sha
    fail "'#{sha}' is not a valid object id" unless sha =~ /^[0-9a-fA-F]{40}$/
    sha
  end

  context 'Webapp & API' do
    it 'References exactly the same commit' do
      expect(commit_id('../webapp/datalayer')).to \
        be == commit_id('../api/datalayer')
    end
  end

  context 'Admin Webapp & API' do
    it 'References exactly the same commit' do
      expect(commit_id('../admin-webapp/datalayer')).to \
        be == commit_id('../api/datalayer')
    end
  end

  context 'Webapp & Admin Webapp' do
    it 'References exactly the same commit' do
      expect(commit_id('../webapp/datalayer')).to \
        be == commit_id('../admin-webapp/datalayer')
    end
  end
end
