# frozen_string_literal: true
RSpec.describe ContentDepositorChangeEventJob do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:mock_time) { Time.zone.at(1) }
  let(:event) do
    { action: "User <a href=\"/users/#{user.to_param}\">#{user.user_key}</a> " \
                          "has transferred <a href=\"/concern/generic_works/#{generic_work.id}\">BethsMac</a> " \
                          "to user <a href=\"/users/#{another_user.to_param}\">#{another_user.user_key}</a>",
      timestamp: '1' }
  end

  before do
    allow(Time).to receive(:now).at_least(:once).and_return(mock_time)
  end

  context "when use_valkyrie is false" do
    let(:generic_work) { create(:generic_work, title: ['BethsMac'], user: user) }

    it "logs the event to the proxy depositor's profile, the depositor's dashboard, and the FileSet" do
      expect { described_class.perform_now(generic_work, another_user) }
        .to change { user.profile_events.length }
        .by(1)
        .and change { another_user.events.length }
        .by(1)
        .and change { generic_work.events.length }
        .by(1)
      expect(user.profile_events.first).to eq(event)
      expect(another_user.events.first).to eq(event)
      expect(generic_work.events.first).to eq(event)
    end
  end

  context "when use_valkyrie is true" do
    let(:generic_work) { valkyrie_create(:hyrax_work, title: ['BethsMac'], depositor: user.user_key) }

    it "logs the event to the proxy depositor's profile, the depositor's dashboard, and the FileSet" do
      allow(subject).to receive(:hyrax_test_simple_work_path).and_return("/concern/generic_works/#{generic_work.id}")

      expect { subject.perform(generic_work, another_user) }
        .to change { user.profile_events.length }
        .by(1)
        .and change { another_user.events.length }
        .by(1)
        .and change { generic_work.events.length }
        .by(1)
      expect(user.profile_events.first).to eq(event)
      expect(another_user.events.first).to eq(event)
      expect(generic_work.events.first).to eq(event)
    end
  end
end
