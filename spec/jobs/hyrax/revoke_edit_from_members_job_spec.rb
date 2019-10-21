RSpec.describe Hyrax::RevokeEditFromMembersJob do
  let(:depositor) { create(:user) }


  context "when use_valkyrie is false" do
    let(:work) { build(:work) }
    let(:file_set_ids) { ['xyz123abc', 'abc789zyx'] }

    before do
      allow_any_instance_of(described_class).to receive(:file_set_ids).with(work).and_return(file_set_ids)
    end

    it 'loops over FileSet IDs, spawning a job for each' do
      file_set_ids.each do |file_set_id|
        expect(Hyrax::GrantReadJob).to receive(:perform_now).with(file_set_id, depositor.user_key, use_valkyre: false).once
      end
      described_class.perform_now(work, depositor.user_key, use_valkyrie: false)
    end
  end

  context "when use_valkyrie is true" do
    let(:file_set1) { valkyrie_create(:hyrax_file_set) }
    let(:file_set2) { valkyrie_create(:hyrax_file_set) }
    let(:work) { valkyrie_create(:hyrax_work, member_ids: [file_set1.id, file_set2.id]) }

    it 'loops over FileSet IDs, spawning a job for each' do
      work.member_ids.each do |file_set_id|
        expect(Hyrax::RevokeEditJob).to receive(:perform_now).with(file_set_id, depositor.user_key, use_valkyre: true).once
      end
      described_class.perform_now(work, depositor.user_key, use_valkyrie: true)
    end
  end
end
