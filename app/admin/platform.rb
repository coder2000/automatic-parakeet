ActiveAdmin.register Platform do
  permit_params :name, :slug

  index do
    selectable_column
    id_column
    column :name
    column :slug
    column :created_at
    column :updated_at
    actions
  end

  filter :name
  filter :slug
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :slug
    end
    f.actions
  end
end
