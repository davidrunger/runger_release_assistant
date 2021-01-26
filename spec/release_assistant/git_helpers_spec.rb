# frozen_string_literal: true

RSpec.describe ReleaseAssistant::GitHelpers do
  subject(:git_helper) { ReleaseAssistant::GitHelpers.new }

  describe '#repo' do
    subject(:repo) { git_helper.repo }

    context 'when ReleaseAssistant::GitHelpers#repo is not stubbed' do
      # rubocop:disable RSpec/AnyInstance
      before { allow_any_instance_of(ReleaseAssistant::GitHelpers).to receive(:repo).and_call_original }
      # rubocop:enable RSpec/AnyInstance

      context 'when `git remote ...` indicates that the remote is davidrunger/release_assistant' do
        before do
          # rubocop:disable RSpec/AnyInstance
          expect_any_instance_of(Kernel).
            to receive(:`).
            with('git remote show origin').
            and_return(<<~GIT_REMOTE_OUTPUT)
              * remote origin
                Fetch URL: git@github.com:davidrunger/release_assistant.git
                Push  URL: git@github.com:davidrunger/release_assistant.git
                HEAD branch: master
                Remote branch:
                  master tracked
                Local branches configured for 'git pull':
                  add-spec-timing merges with remote master
                  master          merges with remote master
                  safe            merges with remote master
                Local ref configured for 'git push':
                  master pushes to master (up to date)
            GIT_REMOTE_OUTPUT
          # rubocop:enable RSpec/AnyInstance
        end

        it 'returns a string in form "username/repo" representing the repo' do
          expect(repo).to eq('davidrunger/release_assistant')
        end
      end
    end
  end
end
