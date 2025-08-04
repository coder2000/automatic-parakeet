# frozen_string_literal: true

ActiveAdmin.register SiteSettings do
  menu priority: 1, label: "Site Settings"

  # Since this is a singleton, we don't need index/new/destroy actions
  actions :show, :edit, :update

  # Custom controller to handle singleton pattern
  controller do
    private

    def resource
      @site_settings ||= SiteSettings.main
    end

    def permitted_params
      params.permit(site_settings: [:logo, :logo_alt_text, carousel_images: []])
    end
  end

  # Customize the show page
  show do
    attributes_table do
      row :logo do |settings|
        if settings.logo.attached?
          div do
            image_tag settings.logo_url, alt: settings.logo_alt_text,
              style: "max-width: 300px; max-height: 200px; object-fit: contain;"
          end
        else
          div do
            para "No custom logo uploaded. Using default logo from assets."
            image_tag "logo/logo.png", alt: settings.logo_alt_text,
              style: "max-width: 300px; max-height: 200px; object-fit: contain;"
          end
        end
      end

      row :logo_alt_text
      row :custom_logo? do |settings|
        settings.custom_logo? ? "Yes" : "No (using default)"
      end

      row :carousel_images do |settings|
        if settings.carousel_images?
          div do
            para "#{settings.carousel_images.count} carousel image(s) uploaded"
            settings.carousel_images.each_with_index do |image, index|
              div style: "margin: 10px 0; padding: 10px; border: 1px solid #ddd; border-radius: 4px;" do
                para "Image #{index + 1}:"
                image_tag Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true),
                  style: "max-width: 200px; max-height: 100px; object-fit: cover; border-radius: 4px;"
              end
            end
          end
        else
          "No carousel images uploaded"
        end
      end

      row :created_at
      row :updated_at
    end

    panel "Logo Preview" do
      div style: "padding: 20px; background: #0c1116; border-radius: 8px; margin: 10px 0;" do
        para "Logo as it appears in the navigation:"
        div style: "background: #0c1116; padding: 10px; border-radius: 4px;" do
          image_tag resource.logo_url, alt: resource.logo_alt_text,
            style: "max-height: 40px; object-fit: contain;"
        end
      end
    end

    if resource.carousel_images?
      panel "Carousel Preview" do
        div style: "padding: 20px; background: #f8f9fa; border-radius: 8px; margin: 10px 0;" do
          para "Carousel images as they appear on the homepage:"
          div style: "display: flex; gap: 10px; overflow-x: auto; padding: 10px;" do
            resource.carousel_images.each_with_index do |image, index|
              div style: "flex-shrink: 0;" do
                para "Image #{index + 1}", style: "margin: 0 0 5px 0; font-size: 12px; color: #666;"
                image_tag Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true),
                  style: "width: 300px; height: 200px; object-fit: cover; border-radius: 4px; border: 1px solid #ddd;"
              end
            end
          end
        end
      end
    end
  end

  # Customize the form
  form do |f|
    f.inputs "Website Logo Settings" do
      f.input :logo, as: :file,
        hint: "Upload a new logo image (JPEG, PNG, GIF, WebP, or SVG, max 5MB). Leave empty to keep current logo."

      if f.object.logo.attached?
        div class: "current-logo-preview" do
          para "Current logo:"
          image_tag f.object.logo_url, alt: f.object.logo_alt_text,
            style: "max-width: 200px; max-height: 100px; object-fit: contain; border: 1px solid #ddd; padding: 5px; margin: 5px 0;"
        end
      else
        div class: "current-logo-preview" do
          para "Currently using default logo:"
          image_tag "logo/logo.png", alt: f.object.logo_alt_text,
            style: "max-width: 200px; max-height: 100px; object-fit: contain; border: 1px solid #ddd; padding: 5px; margin: 5px 0;"
        end
      end

      f.input :logo_alt_text,
        hint: "Alt text for the logo (important for accessibility and SEO)"
    end

    f.inputs "Landing Page Carousel Images" do
      f.input :carousel_images, as: :file, input_html: {multiple: true, accept: "image/*"},
        hint: "Upload up to 5 carousel images (JPEG, PNG, GIF, or WebP, max 10MB each). These will be displayed in the homepage carousel. Leave empty to keep current images."

      if f.object.carousel_images?
        div class: "current-carousel-preview" do
          para "Current carousel images (#{f.object.carousel_images.count}/5):"
          div style: "display: flex; flex-wrap: wrap; gap: 10px; margin: 10px 0;" do
            f.object.carousel_images.each_with_index do |image, index|
              div style: "border: 1px solid #ddd; padding: 5px; border-radius: 4px;" do
                para "Image #{index + 1}", style: "margin: 0 0 5px 0; font-size: 12px; color: #666;"
                image_tag Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true),
                  style: "width: 150px; height: 100px; object-fit: cover; border-radius: 4px;"
              end
            end
          end
          para "Note: To remove specific images, you'll need to upload a new set. To keep some images, re-upload them along with any new ones.",
            style: "font-style: italic; color: #666; font-size: 12px;"
        end
      else
        div class: "no-carousel-images" do
          para "No carousel images uploaded yet. Upload up to 5 images to display in the homepage carousel.",
            style: "color: #666; font-style: italic;"
        end
      end
    end

    f.actions do
      f.action :submit, label: "Update Site Settings"
      f.cancel_link
    end
  end

  # Override the index action to redirect to show
  collection_action :index do
    redirect_to admin_site_settings_path(id: "main")
  end
end
