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
      params.permit(site_settings: [:logo, :logo_alt_text])
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

    f.actions do
      f.action :submit, label: "Update Site Settings"
      f.cancel_link
    end
  end

  # Custom routes since we're using singleton pattern
  collection_action :edit, method: :get do
    redirect_to edit_admin_site_settings_path(id: "main")
  end

  collection_action :show, method: :get do
    redirect_to admin_site_settings_path(id: "main")
  end

  # Override the index action to redirect to show
  collection_action :index do
    redirect_to admin_site_settings_path(id: "main")
  end
end
