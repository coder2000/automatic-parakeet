# == Schema Information
#
# Table name: downloads
#
#  id               :bigint           not null, primary key
#  count            :integer          default(0)
#  ip_address       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  download_link_id :bigint
#  user_id          :bigint
#
# Indexes
#
#  index_downloads_on_download_link_id  (download_link_id)
#  index_downloads_on_user_id           (user_id)
#
require 'rails_helper'

RSpec.describe Download, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
