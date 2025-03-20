# frozen_string_literal: true

RSpec.describe RungerReleaseAssistant do
  subject(:runger_release_assistant) { RungerReleaseAssistant.new }

  describe '#primary_branch' do
    subject(:primary_branch) { runger_release_assistant.send(:primary_branch) }

    context 'when a primary_branch option is not specified' do
      context 'when `git branch` is stubbed' do
        before do
          # rubocop:disable RSpec/AnyInstance
          expect_any_instance_of(Kernel).
            to receive(:`).
            with('git branch').
            and_return(git_branch_output)
          # rubocop:enable RSpec/AnyInstance
        end

        context "when there is a branch called 'main'" do
          let(:git_branch_output) do
            <<~GIT_BRANCH_OUTPUT
                main
              * safe
            GIT_BRANCH_OUTPUT
          end

          it "returns 'main'" do
            expect(primary_branch).to eq('main')
          end
        end

        context "when there is a branch called 'master'" do
          let(:git_branch_output) do
            <<~GIT_BRANCH_OUTPUT
              * flexible-primary-branch-name
                master
                safe
            GIT_BRANCH_OUTPUT
          end

          it "returns 'master'" do
            expect(primary_branch).to eq('master')
          end
        end

        context 'when there is no branch named main, master, or trunk' do
          let(:git_branch_output) do
            <<~GIT_BRANCH_OUTPUT
              * some-branch-name
                develop
                primary
            GIT_BRANCH_OUTPUT
          end

          it 'raises a RungerReleaseAssistant::UnknownPrimaryBranch exception' do
            expect { primary_branch }.to raise_error(
              RungerReleaseAssistant::UnknownPrimaryBranch,
              /Failed to automatically determine primary branch/,
            )
          end
        end
      end
    end
  end
end
