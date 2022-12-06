# frozen_string_literal: true

require "rails_helper"

RSpec.describe FindPairs do
  before do
    allow_any_instance_of( # rubocop:disable RSpec/AnyInstance
      FindPairs::GitHub::Api,
    ).to receive(:fetch_json).and_return({})
  end

  it "handles not finding the user" do
    expect(
      FindPairs.new.process("saramic"),
    ).to eq "user not found"
  end

  context "with a user returned by the API" do
    before do
      allow_any_instance_of( # rubocop:disable RSpec/AnyInstance
        FindPairs::GitHub::Api,
      ).to receive(:fetch_json).with(
        URI.parse("https://api.github.com/users/saramic"),
      ).and_return({
        "login" => "saramic",
        "id" => 278723,
        "name" => "Michael Milewski",
        "repos_url" => "https://api.github.com/users/saramic/repos",
        "type" => "User",
      })
      allow(User).to receive(:find_or_create_by).and_call_original
    end

    it "creates the user" do
      expect(
        FindPairs.new.process("saramic", options: {"password" => "password"}),
      ).to eq []
      expect(User).to have_received(:find_or_create_by).with(
        uid: 278723,
        provider: :github,
        name: "Michael Milewski",
        username: "saramic",
      )
    end

    context "with a repo" do
      let(:mock_git_remote) { instance_double(FindPairs::GitRemote) }

      before do
        allow(mock_git_remote).to receive(:process).and_return([])
        allow(FindPairs::GitRemote).to receive(:new).and_return(mock_git_remote)
        allow_any_instance_of( # rubocop:disable RSpec/AnyInstance
          FindPairs::GitHub::Api,
        ).to receive(:fetch_json).with(
          URI.parse("https://api.github.com/users/saramic/repos"),
        ).and_return([
          {
            id: 559114323,
            name: "100-days-of-code",
            full_name: "saramic/100-days-of-code",
            ssh_url: "git@github.com:saramic/100-days-of-code.git",
          },
        ])
        allow(User).to receive(:find_or_create_by).and_call_original
      end

      it "creates the user" do
        expect(
          FindPairs.new.process("saramic", options: {"password" => "password"}),
        ).to eq [nil]
      end

      context "with a repo with commits" do # rubocop:disable RSpec/NestedGroups
        before do
          allow(mock_git_remote).to receive(:process).and_return([
            {
              author: {name: "Michael Milewski", email: "saramic@gmail.com"},
              co_author: {name: "Selena Small", email: "selenawiththetattoo@gmail.com"},
            },
          ])
          allow_any_instance_of( # rubocop:disable RSpec/AnyInstance
            FindPairs::GitHub::Api,
          ).to receive(:fetch_json).with(
            URI.parse("https://api.github.com/users/SelenaSmall"),
          ).and_return({
            "login" => "SelenaSmall",
            "id" => 5399968,
            "name" => "Selena Small",
            "type" => "User",
          })
          allow_any_instance_of( # rubocop:disable RSpec/AnyInstance
            FindPairs::GitHub::Api,
          ).to receive(:fetch_json).with(
            URI.parse("https://api.github.com/search/users?q=Selena%20Small"),
          ).and_return({
            :total_count => 2,
            "items" => [
              {
                "login" => "SelenaSmall",
                :id => 5399968,
                :url => "https://api.github.com/users/SelenaSmall",
                "type" => "User",
              },
              {
                "login" => "failure-driven",
                :id => 45084673,
                :url => "https://api.github.com/users/failure-driven",
                "type" => "Organization",
              },
            ],
          })
        end

        it "creates the pair" do
          expect(
            FindPairs.new.process("saramic", options: {"password" => "password"}),
          ).to eq [nil]
          expect(User).to have_received(:find_or_create_by).with(
            uid: 278723,
            provider: :github,
            name: "Michael Milewski",
            username: "saramic",
          )
          expect(User).to have_received(:find_or_create_by).with(
            uid: 5399968,
            provider: :github,
            name: "Selena Small",
            username: "SelenaSmall",
          )
          author = User.find_by(username: "saramic")
          co_author = User.find_by(username: "SelenaSmall")
          expect(Pair.count).to eq 1
          expect(Pair.take.author).to eq author
          expect(Pair.take.co_author).to eq co_author
        end
      end
    end
  end
end
