# Shared examples for common test patterns

RSpec.shared_examples "a polymorphic mediable" do
  it "has polymorphic media association" do
    expect(subject).to have_many(:media).dependent(:destroy)
  end

  it "has screenshots association" do
    expect(subject).to have_many(:screenshots)
  end

  it "has videos association" do
    expect(subject).to have_many(:videos)
  end

  it "accepts nested attributes for media" do
    expect(subject).to accept_nested_attributes_for(:media).allow_destroy(true)
  end
end

RSpec.shared_examples "a model with counter culture" do |counter_field, association|
  it "updates counter when #{association} is added" do
    expect { create(association, mediable: subject) }
      .to change { subject.reload.send(counter_field) }.by(1)
  end

  it "decrements counter when #{association} is removed" do
    item = create(association, mediable: subject)
    expect { item.destroy }
      .to change { subject.reload.send(counter_field) }.by(-1)
  end
end

RSpec.shared_examples "a file attachment with validation" do |file_types, max_size|
  it "validates file presence" do
    subject.file = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:file]).to include("can't be blank")
  end

  it "validates file content type" do
    allow(subject.file).to receive(:content_type).and_return("invalid/type")
    expect(subject).not_to be_valid
    expect(subject.errors[:file]).to be_present
  end

  it "validates file size" do
    allow(subject.file).to receive(:byte_size).and_return(max_size + 1)
    expect(subject).not_to be_valid
    expect(subject.errors[:file]).to be_present
  end

  file_types.each do |content_type|
    it "accepts #{content_type} files" do
      allow(subject.file).to receive(:content_type).and_return(content_type)
      allow(subject.file).to receive(:byte_size).and_return(max_size - 1)
      expect(subject).to be_valid
    end
  end
end

RSpec.shared_examples "a Stimulus controller" do |controller_name|
  it "connects successfully" do
    expect(controller).to be_defined
  end

  it "has correct identifier" do
    expect(controller.identifier).to eq(controller_name)
  end

  it "responds to connect" do
    expect(controller).to respond_to(:connect)
  end

  it "responds to disconnect" do
    expect(controller).to respond_to(:disconnect)
  end
end

RSpec.shared_examples "a drag and drop controller" do
  it "has drop zone target" do
    expect(controller).to respond_to(:dropZoneTarget)
  end

  it "has file input target" do
    expect(controller).to respond_to(:fileInputTarget)
  end

  it "handles file input change" do
    expect(controller).to respond_to(:fileInputChanged)
  end

  it "handles file drop" do
    expect(controller).to respond_to(:handleDrop)
  end

  it "validates files" do
    expect(controller).to respond_to(:filterValidFiles)
  end

  it "shows errors" do
    expect(controller).to respond_to(:showError)
  end
end

RSpec.shared_examples "a responsive page" do
  it "works on desktop" do
    page.driver.browser.manage.window.resize_to(1400, 1000)
    visit subject
    expect(page).to have_content(expected_content)
  end

  it "works on tablet" do
    page.driver.browser.manage.window.resize_to(768, 1024)
    visit subject
    expect(page).to have_content(expected_content)
  end

  it "works on mobile" do
    page.driver.browser.manage.window.resize_to(375, 667)
    visit subject
    expect(page).to have_content(expected_content)
  end
end

RSpec.shared_examples "an authenticated page" do
  context "when user is not signed in" do
    it "redirects to sign in page" do
      visit subject
      expect(current_path).to eq(new_user_session_path)
    end
  end

  context "when user is signed in" do
    before { sign_in user }

    it "allows access" do
      visit subject
      expect(page).to have_http_status(:success)
    end
  end
end
