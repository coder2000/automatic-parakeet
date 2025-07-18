# == Schema Information
#
# Table name: media
#
#  id            :bigint           not null, primary key
#  description   :text
#  media_type    :string           not null
#  mediable_type :string           not null
#  position      :integer          default(0)
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  mediable_id   :bigint           not null
#
# Indexes
#
#  index_media_on_mediable                                      (mediable_type,mediable_id)
#  index_media_on_mediable_type_and_mediable_id_and_media_type  (mediable_type,mediable_id,media_type)
#  index_media_on_mediable_type_and_mediable_id_and_position    (mediable_type,mediable_id,position)
#

require 'rails_helper'

RSpec.describe Medium, type: :model do
  describe 'associations' do
    it { should belong_to(:mediable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:media_type) }
    it { should validate_presence_of(:position) }
    it { should validate_numericality_of(:position).is_greater_than_or_equal_to(0) }

    describe 'file attachment' do
      let(:game) { create(:game) }
      
      it 'validates file presence' do
        medium = build(:medium, :screenshot, mediable: game, file: nil)
        expect(medium).not_to be_valid
        expect(medium.errors[:file]).to include("can't be blank")
      end
    end

    describe 'file content type validation' do
      let(:game) { create(:game) }

      context 'for screenshots' do
        it 'accepts valid image formats' do
          %w[image/jpeg image/jpg image/png image/gif image/webp].each do |content_type|
            medium = build(:medium, :screenshot, mediable: game)
            allow(medium.file).to receive(:content_type).and_return(content_type)
            expect(medium).to be_valid
          end
        end

        it 'rejects invalid formats' do
          medium = build(:medium, :screenshot, mediable: game)
          allow(medium.file).to receive(:content_type).and_return('video/mp4')
          expect(medium).not_to be_valid
          expect(medium.errors[:file]).to include('must be JPEG, PNG, GIF, or WebP format for screenshots')
        end
      end

      context 'for videos' do
        it 'accepts valid video formats' do
          %w[video/mp4 video/webm video/ogg video/avi video/mov].each do |content_type|
            medium = build(:medium, :video, mediable: game)
            allow(medium.file).to receive(:content_type).and_return(content_type)
            expect(medium).to be_valid
          end
        end

        it 'rejects invalid formats' do
          medium = build(:medium, :video, mediable: game)
          allow(medium.file).to receive(:content_type).and_return('image/jpeg')
          expect(medium).not_to be_valid
          expect(medium.errors[:file]).to include('must be MP4, WebM, OGG, AVI, or MOV format for videos')
        end
      end
    end

    describe 'file size validation' do
      let(:game) { create(:game) }

      context 'for screenshots' do
        it 'accepts files under 10MB' do
          medium = build(:medium, :screenshot, mediable: game)
          allow(medium.file).to receive(:byte_size).and_return(9.megabytes)
          expect(medium).to be_valid
        end

        it 'rejects files over 10MB' do
          medium = build(:medium, :screenshot, mediable: game)
          allow(medium.file).to receive(:byte_size).and_return(11.megabytes)
          expect(medium).not_to be_valid
          expect(medium.errors[:file]).to include('must be less than 10MB for screenshots')
        end
      end

      context 'for videos' do
        it 'accepts files under 100MB' do
          medium = build(:medium, :video, mediable: game)
          allow(medium.file).to receive(:byte_size).and_return(99.megabytes)
          expect(medium).to be_valid
        end

        it 'rejects files over 100MB' do
          medium = build(:medium, :video, mediable: game)
          allow(medium.file).to receive(:byte_size).and_return(101.megabytes)
          expect(medium).not_to be_valid
          expect(medium.errors[:file]).to include('must be less than 100MB for videos')
        end
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:media_type).with_values(screenshot: 'screenshot', video: 'video') }
  end

  describe 'scopes' do
    let(:game) { create(:game) }
    let!(:screenshot1) { create(:medium, :screenshot, mediable: game, position: 2) }
    let!(:screenshot2) { create(:medium, :screenshot, mediable: game, position: 1) }
    let!(:video) { create(:medium, :video, mediable: game, position: 0) }

    describe '.ordered' do
      it 'orders by position then created_at' do
        expect(Medium.ordered).to eq([video, screenshot2, screenshot1])
      end
    end

    describe '.screenshots' do
      it 'returns only screenshots' do
        expect(Medium.screenshots).to contain_exactly(screenshot1, screenshot2)
      end
    end

    describe '.videos' do
      it 'returns only videos' do
        expect(Medium.videos).to contain_exactly(video)
      end
    end
  end

  describe 'callbacks' do
    describe 'set_default_position' do
      let(:game) { create(:game) }

      context 'when position is not set' do
        it 'sets position to 0 for first medium of type' do
          medium = create(:medium, :screenshot, mediable: game, position: nil)
          expect(medium.position).to eq(0)
        end

        it 'increments position for subsequent media of same type' do
          create(:medium, :screenshot, mediable: game, position: 0)
          medium = create(:medium, :screenshot, mediable: game, position: nil)
          expect(medium.position).to eq(1)
        end

        it 'handles different media types independently' do
          create(:medium, :screenshot, mediable: game, position: 0)
          video = create(:medium, :video, mediable: game, position: nil)
          expect(video.position).to eq(0)
        end
      end

      context 'when position is already set' do
        it 'does not change the position' do
          medium = create(:medium, :screenshot, mediable: game, position: 5)
          expect(medium.position).to eq(5)
        end
      end
    end
  end

  describe 'counter culture' do
    let(:game) { create(:game) }

    it 'updates screenshots_count when screenshot is created' do
      expect { create(:medium, :screenshot, mediable: game) }
        .to change { game.reload.screenshots_count }.by(1)
    end

    it 'updates videos_count when video is created' do
      expect { create(:medium, :video, mediable: game) }
        .to change { game.reload.videos_count }.by(1)
    end

    it 'decrements count when medium is destroyed' do
      medium = create(:medium, :screenshot, mediable: game)
      expect { medium.destroy }
        .to change { game.reload.screenshots_count }.by(-1)
    end
  end

  describe 'instance methods' do
    describe '#screenshot?' do
      it 'returns true for screenshot media' do
        medium = build(:medium, :screenshot)
        expect(medium.screenshot?).to be true
      end

      it 'returns false for video media' do
        medium = build(:medium, :video)
        expect(medium.screenshot?).to be false
      end
    end

    describe '#video?' do
      it 'returns true for video media' do
        medium = build(:medium, :video)
        expect(medium.video?).to be true
      end

      it 'returns false for screenshot media' do
        medium = build(:medium, :screenshot)
        expect(medium.video?).to be false
      end
    end

    describe '#display_title' do
      context 'when title is present' do
        it 'returns the title' do
          medium = build(:medium, :screenshot, title: 'Main Menu')
          expect(medium.display_title).to eq('Main Menu')
        end
      end

      context 'when title is blank' do
        it 'returns formatted media type with position' do
          medium = build(:medium, :screenshot, title: '', position: 2)
          expect(medium.display_title).to eq('Screenshot 3')
        end

        it 'handles video type' do
          medium = build(:medium, :video, title: nil, position: 0)
          expect(medium.display_title).to eq('Video 1')
        end
      end
    end
  end

  describe 'ransackable attributes' do
    it 'includes expected attributes' do
      expected_attributes = %w[media_type title description position created_at updated_at]
      expect(Medium.ransackable_attributes).to match_array(expected_attributes)
    end
  end

  describe 'ransackable associations' do
    it 'includes mediable association' do
      expect(Medium.ransackable_associations).to include('mediable')
    end
  end
end
